import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

export function mapAllergyStatus(allergyStatus: string): string {
  if (allergyStatus === 'known' || allergyStatus === 'known_ingredient') {
    return 'known_ingredient';
  }
  if (allergyStatus === 'unknown' || allergyStatus === 'unknown_ingredient') {
    return 'unknown_ingredient';
  }
  return 'none';
}

export function mapUsageTime(usageTime: string): string {
  if (usageTime === 'Pagi' || usageTime === 'morning_day') {
    return 'morning_day';
  }
  if (usageTime === 'Malam' || usageTime === 'night') {
    return 'night';
  }
  return 'morning_and_night';
}

export function mapUvRiskLevel(uvIndex: number | null, inputRisk: string | null): string {
  if (inputRisk) {
    const lower = inputRisk.toLowerCase();
    if (lower.includes('low') || lower.includes('rendah')) return 'low';
    if (lower.includes('moderate') || lower.includes('sedang')) return 'moderate';
    if (lower.includes('very') || lower.includes('sangat')) return 'very_high';
    if (lower.includes('high') || lower.includes('tinggi')) return 'high';
    if (lower.includes('extreme') || lower.includes('ekstrem')) return 'extreme';
  }
  if (uvIndex !== null && uvIndex !== undefined) {
    const val = Number(uvIndex);
    if (val <= 2) return 'low';
    if (val <= 5) return 'moderate';
    if (val <= 7) return 'high';
    if (val <= 10) return 'very_high';
    return 'extreme';
  }
  return 'low';
}

export async function saveRecommendationSession(adminClient: any, body: any) {
  const dbAllergyStatus = mapAllergyStatus(body.allergy_status);
  const dbUsageTime = mapUsageTime(body.usage_time);
  const dbUvRiskLevel = mapUvRiskLevel(body.uv_index, body.uv_category);

  // 1. Insert to recommendation_sessions
  const { data: session, error: sessionError } = await adminClient
    .from('recommendation_sessions')
    .insert({
      id_user: body.user_id,
      skin_type_id: body.skin_type_id,
      usage_time: dbUsageTime,
      allergy_status: dbAllergyStatus,
      location_name: body.location_name || null,
      latitude: body.latitude || null,
      longitude: body.longitude || null,
      uv_index: body.uv_index !== null ? Number(body.uv_index) : null,
      uv_risk_level: dbUvRiskLevel
    })
    .select('recommendation_session_id')
    .single();

  if (sessionError || !session) {
    throw new Error(`Failed to save recommendation session: ${sessionError?.message}`);
  }

  const recommendationId = session.recommendation_session_id;

  // 2. Insert selected skin concerns
  const selectedConcernIds = body.selected_concern_ids || [];
  if (selectedConcernIds.length > 0) {
    const concernsToInsert = selectedConcernIds.map((concernId: string) => ({
      recommendation_session_id: recommendationId,
      skin_concern_id: concernId
    }));

    const { error: concernsError } = await adminClient
      .from('recommendation_concerns')
      .insert(concernsToInsert);

    if (concernsError) {
      throw new Error(`Failed to save skin concerns: ${concernsError.message}`);
    }
  }

  // 3. Insert avoided ingredients (only if allergy_status = known and avoided_ingredient_ids is not empty)
  const isKnownAllergy = body.allergy_status === 'known' || body.allergy_status === 'known_ingredient';
  const avoidedIngredientIds = body.avoided_ingredient_ids || [];
  if (isKnownAllergy && avoidedIngredientIds.length > 0) {
    const avoidedToInsert = avoidedIngredientIds.map((ingredientId: string) => ({
      recommendation_session_id: recommendationId,
      ingredient_id: ingredientId
    }));

    const { error: avoidedError } = await adminClient
      .from('avoided_ingredients')
      .insert(avoidedToInsert);

    if (avoidedError) {
      throw new Error(`Failed to save avoided ingredients: ${avoidedError.message}`);
    }
  }

  return recommendationId;
}

export async function fetchAllActiveProducts(adminClient: any) {
  const { data: products, error } = await adminClient
    .from('products')
    .select(`
      product_id,
      brand_name,
      product_name,
      category,
      usage_time,
      spf_value,
      pa_grade,
      is_active,
      product_skin_types (skin_type_id),
      product_skin_concerns (skin_concern_id),
      product_ingredients (ingredient_id)
    `)
    .eq('is_active', true);

  if (error || !products) {
    throw new Error(`Failed to fetch active products: ${error?.message}`);
  }

  return products;
}

export async function getSkinTypeCode(adminClient: any, skinTypeId: string): Promise<string> {
  const { data, error } = await adminClient
    .from('skin_types')
    .select('skin_type_name')
    .eq('skin_type_id', skinTypeId)
    .single();

  if (error || !data) {
    return '';
  }
  return data.skin_type_name; // oily, dry, combination, normal, sensitive
}

export async function getConcernCode(adminClient: any, concernId: string): Promise<string> {
  const { data, error } = await adminClient
    .from('skin_concerns')
    .select('skin_concern_name')
    .eq('skin_concern_id', concernId)
    .single();

  if (error || !data) {
    return '';
  }
  return data.skin_concern_name; // acne, blackhead, dark_spot, dull, irritation, dehydration, wrinkle, uneven_tone
}

export async function getConcernCodes(adminClient: any, concernIds: string[]): Promise<string[]> {
  const codes = await Promise.all(
    concernIds.map(id => getConcernCode(adminClient, id))
  );
  return codes.filter(c => c !== '');
}
