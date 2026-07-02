import { mapSkinTypeCode } from "./utils.ts";

export interface SkinProfileResult {
  skinTypeData?: any;
  skinConcernsData?: any[];
  error?: string;
  statusCode?: number;
}

export async function fetchSkinProfile(
  adminClient: any,
  skinTypeId: string,
  skinConcernIds: string[]
): Promise<SkinProfileResult> {
  const { data: skinTypeData, error: skinTypeError } = await adminClient
    .from('skin_types')
    .select('skin_type_code, skin_type_name')
    .eq('skin_type_id', skinTypeId)
    .single();

  if (skinTypeError || !skinTypeData) {
    return {
      error: "Jenis kulit tidak ditemukan di database",
      statusCode: 400
    };
  }

  let skinConcernsData: any[] = [];
  if (skinConcernIds && skinConcernIds.length > 0) {
    const { data: concernsData, error: skinConcernsError } = await adminClient
      .from('skin_concerns')
      .select('skin_concern_id, skin_concern_code, skin_concern_name')
      .in('skin_concern_id', skinConcernIds);

    if (skinConcernsError || !concernsData) {
      return {
        error: "Gagal mengambil data masalah kulit dari database",
        statusCode: 400
      };
    }
    skinConcernsData = concernsData;
  }

  return { skinTypeData, skinConcernsData };
}

export async function fetchAutoAvoidIngredientIds(adminClient: any): Promise<string[]> {
  const { data: autoAvoidData } = await adminClient
    .from('ingredients')
    .select('ingredient_id, ingredient_code')
    .in('ingredient_code', ['oxybenzone', 'benzophenone_3', 'fragrance']);
  return (autoAvoidData || []).map((item: any) => item.ingredient_id);
}

export interface ActiveProductsResult {
  products?: any[];
  error?: string;
  statusCode?: number;
}

export async function fetchActiveProducts(adminClient: any): Promise<ActiveProductsResult> {
  const { data: products, error: productsError } = await adminClient
    .from('products')
    .select(`
      *,
      product_skin_types (skin_type_id),
      product_skin_concerns (skin_concern_id),
      product_ingredients (
        ingredient_id,
        ingredients (ingredient_code)
      )
    `)
    .eq('is_active', true);

  if (productsError || !products || products.length === 0) {
    return {
      error: "Tidak ada produk aktif yang tersedia di database",
      statusCode: 404
    };
  }
  return { products };
}

export async function fetchAllSkinTypesMap(adminClient: any): Promise<Map<string, string>> {
  const { data: allSkinTypes } = await adminClient
    .from('skin_types')
    .select('skin_type_id, skin_type_code, skin_type_name');
  const skinTypeMap = new Map<string, string>();
  if (allSkinTypes) {
    for (const st of allSkinTypes) {
      skinTypeMap.set(st.skin_type_id, mapSkinTypeCode(st.skin_type_code || st.skin_type_name));
    }
  }
  return skinTypeMap;
}

export async function fetchAllSkinConcernsMap(adminClient: any): Promise<Map<string, string>> {
  const { data: allConcerns } = await adminClient
    .from('skin_concerns')
    .select('skin_concern_id, skin_concern_code');
  const concernMap = new Map<string, string>();
  if (allConcerns) {
    for (const sc of allConcerns) {
      concernMap.set(sc.skin_concern_id, sc.skin_concern_code);
    }
  }
  return concernMap;
}

export interface TransactionResult {
  transactionRes?: any;
  error?: string;
  statusCode?: number;
}

export async function saveRecommendationTransaction(
  adminClient: any,
  params: {
    userId: string;
    skinTypeId: string;
    activity: string;
    texturePreference?: string | null;
    finishPreference?: string | null;
    allergyStatus: string;
    usageTimePreference: string;
    locationName?: string | null;
    latitude: number;
    longitude: number;
    uvIndex: number;
    skinConcernIds: string[];
    avoidedIngredientIds: string[];
    rankedProducts: any[];
  }
): Promise<TransactionResult> {
  const { data: transactionRes, error: transactionError } = await adminClient.rpc('save_recommendation_transaction', {
    p_user_id: params.userId,
    p_skin_type_id: params.skinTypeId,
    p_activity: params.activity,
    p_texture_preference: params.texturePreference || null,
    p_finish_preference: params.finishPreference || null,
    p_allergy_status: params.allergyStatus,
    p_usage_time_preference: params.usageTimePreference,
    p_location_name: params.locationName || null,
    p_latitude: params.latitude,
    p_longitude: params.longitude,
    p_uv_index: params.uvIndex,
    p_skin_concern_ids: params.skinConcernIds,
    p_avoided_ingredient_ids: params.avoidedIngredientIds || [],
    p_results: params.rankedProducts.map(item => ({
      product_id: item.product.product_id,
      match_score: item.finalScore,
      recommendation_category: item.category,
      rank_position: item.rank_position,
      skin_type_score: item.maxSkinTypeScore,
      activity_score: item.activityScore,
      skin_concern_score: item.skinConcernScore,
      texture_score: item.textureScore,
      finish_score: item.finishScore,
      penalty: item.penalty
    }))
  });

  if (transactionError || !transactionRes) {
    return {
      error: `Gagal menyimpan hasil rekomendasi: ${transactionError?.message || 'Unknown error'}`,
      statusCode: 500
    };
  }

  return { transactionRes };
}
