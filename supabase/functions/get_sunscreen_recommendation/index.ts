// @ts-nocheck
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// --- Similarity Matrices and Helper Maps ---
const similarity: Record<string, Record<string, number>> = {
  "oily": {
    "oily": 30,
    "combination": 20,
    "normal": 10,
    "dry": 5,
    "sensitive": 0
  },
  "dry": {
    "dry": 30,
    "normal": 20,
    "combination": 10,
    "oily": 5,
    "sensitive": 5
  },
  "normal": {
    "normal": 30,
    "combination": 15,
    "dry": 10,
    "oily": 10,
    "sensitive": 5
  },
  "combination": {
    "combination": 30,
    "oily": 20,
    "normal": 10,
    "dry": 5,
    "sensitive": 0
  },
  "sensitive": {
    "sensitive": 30,
    "normal": 10,
    "dry": 10,
    "oily": 0,
    "combination": 0
  }
};

const texture_match: Record<string, Record<string, number>> = {
  "gel":    {"gel":15, "serum":10, "watery":8, "lotion":5, "milk":3, "mist":3, "cream":0, "stick":0, "spray":0},
  "cream":  {"cream":15, "lotion":10, "milk":8, "serum":5, "gel":3, "watery":3, "mist":0, "stick":0, "spray":0},
  "lotion": {"lotion":15, "milk":12, "cream":8, "gel":8, "serum":8, "watery":5, "mist":3, "stick":0, "spray":0},
  "serum":  {"serum":15, "gel":10, "watery":8, "lotion":5, "milk":3, "mist":3, "cream":0, "stick":0, "spray":0},
  "milk":   {"milk":15, "lotion":12, "cream":8, "serum":5, "gel":3, "watery":3, "mist":0, "stick":0, "spray":0},
  "watery": {"watery":15, "gel":12, "serum":10, "mist":8, "lotion":5, "milk":3, "cream":0, "stick":0, "spray":0},
  "stick":  {"stick":15, "spray":10, "lotion":5, "gel":3, "serum":3, "watery":3, "cream":0, "milk":0, "mist":0},
  "spray":  {"spray":15, "stick":10, "mist":8, "lotion":5, "gel":3, "watery":3, "cream":0, "milk":0, "serum":0},
  "mist":   {"mist":15, "spray":10, "watery":8, "gel":5, "serum":5, "lotion":3, "cream":0, "milk":0, "stick":0}
};

// --- Helper Functions ---
function isValidUuid(uuid: string): boolean {
  const pattern = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
  return pattern.test(uuid);
}

function hasDuplicate(arr: string[]): boolean {
  return new Set(arr).size !== arr.length;
}

function mapSkinTypeCode(codeOrName: string): string {
  const normalized = codeOrName.toLowerCase();
  if (normalized === 'st001' || normalized === 'oily' || normalized === 'berminyak') return 'oily';
  if (normalized === 'st002' || normalized === 'dry' || normalized === 'kering') return 'dry';
  if (normalized === 'st003' || normalized === 'combination' || normalized === 'kombinasi') return 'combination';
  if (normalized === 'st004' || normalized === 'normal') return 'normal';
  if (normalized === 'st005' || normalized === 'sensitive' || normalized === 'sensitif') return 'sensitive';
  return normalized;
}

function mapConcernCode(codeOrName: string): string {
  const normalized = codeOrName.toLowerCase();
  if (normalized === 'sc001' || normalized === 'acne' || normalized === 'jerawat') return 'acne';
  if (normalized === 'sc002' || normalized === 'hyperpigmentation' || normalized.includes('hiperpigmentasi') || normalized.includes('kusam')) return 'hyperpigmentation';
  if (normalized === 'sc003' || normalized === 'sensitive_irritation' || normalized.includes('irritation') || normalized.includes('sensitif') || normalized.includes('iritasi')) return 'sensitive_irritation';
  if (normalized === 'sc004' || normalized === 'aging' || normalized.includes('penuaan')) return 'aging';
  return normalized;
}

function paToNumber(pa: string): number {
  const normalized = pa.toUpperCase().replace(/\s+/g, '');
  if (normalized.includes('PA++++')) return 4;
  if (normalized.includes('PA+++')) return 3;
  if (normalized.includes('PA++')) return 2;
  if (normalized.includes('PA+')) return 1;
  return 0;
}

function comparePaGrade(productPa: string, minimumPa: string): boolean {
  return paToNumber(productPa) >= paToNumber(minimumPa);
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const body = await req.json().catch(() => ({}));

    // --- Authentication / User ID ---
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    let userId = '';
    const authHeader = req.headers.get('Authorization');
    
    if (authHeader && authHeader !== `Bearer ${supabaseAnonKey}`) {
      const token = authHeader.replace('Bearer ', '');
      const userClient = createClient(supabaseUrl, supabaseAnonKey, {
        global: { headers: { Authorization: authHeader } }
      });

      const { data: { user }, error: authError } = await userClient.auth.getUser(token);
      if (!authError && user) {
        userId = user.id;
      }
    }

    // Postman / API testing fallback
    if (!userId) {
      userId = body.user_id;
    }
    body.user_id = userId;

    // --- General Field Validations ---
    if (!body.user_id || !isValidUuid(body.user_id)) {
      return new Response(JSON.stringify({ error: "user_id wajib diisi dengan format UUID yang valid" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!body.skin_type_id || !isValidUuid(body.skin_type_id)) {
      return new Response(JSON.stringify({ error: "skin_type_id wajib diisi dengan format UUID yang valid" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!body.skin_concern_ids || !Array.isArray(body.skin_concern_ids) || body.skin_concern_ids.length === 0) {
      return new Response(JSON.stringify({ error: "Masalah kulit wajib dipilih (minimal 1)" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (body.skin_concern_ids.length > 4) {
      return new Response(JSON.stringify({ error: "Maksimal masalah kulit yang dipilih adalah 4 kategori" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (hasDuplicate(body.skin_concern_ids)) {
      return new Response(JSON.stringify({ error: "Masalah kulit tidak boleh duplikat" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    for (const id of body.skin_concern_ids) {
      if (!isValidUuid(id)) {
        return new Response(JSON.stringify({ error: "Format skin_concern_id tidak valid" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    const validActivities = ['indoor', 'outdoor_light', 'outdoor_intense', 'sport', 'swim'];
    if (!body.activity || !validActivities.includes(body.activity)) {
      return new Response(JSON.stringify({ error: `Aktivitas harian wajib dipilih dan harus berupa salah satu dari: ${validActivities.join(', ')}` }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const validTextures = ['gel', 'cream', 'lotion', 'serum', 'milk', 'watery', 'stick', 'spray', 'mist'];
    if (body.texture_preference && !validTextures.includes(body.texture_preference)) {
      return new Response(JSON.stringify({ error: "Nilai preferensi tekstur tidak valid" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const validAllergyStatuses = ['none', 'unknown_ingredient', 'known_ingredient'];
    if (!body.allergy_status || !validAllergyStatuses.includes(body.allergy_status)) {
      return new Response(JSON.stringify({ error: `Status alergi wajib diisi dan harus berupa salah satu dari: ${validAllergyStatuses.join(', ')}` }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (body.allergy_status === 'known_ingredient' && (!body.avoided_ingredient_ids || !Array.isArray(body.avoided_ingredient_ids) || body.avoided_ingredient_ids.length === 0)) {
      return new Response(JSON.stringify({ error: "Bahan yang dihindari wajib dipilih jika status alergi diketahui" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (body.avoided_ingredient_ids && Array.isArray(body.avoided_ingredient_ids)) {
      if (hasDuplicate(body.avoided_ingredient_ids)) {
        return new Response(JSON.stringify({ error: "Bahan yang dihindari tidak boleh duplikat" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }

      for (const id of body.avoided_ingredient_ids) {
        if (!isValidUuid(id)) {
          return new Response(JSON.stringify({ error: "Format avoided_ingredient_id tidak valid" }), {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" }
          });
        }
      }
    }

    if (body.latitude === undefined || body.latitude === null || body.longitude === undefined || body.longitude === null) {
      return new Response(JSON.stringify({ error: "Lokasi (latitude & longitude) tidak dapat diakses atau kosong" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const lat = Number(body.latitude);
    const lon = Number(body.longitude);

    if (isNaN(lat) || lat < -90 || lat > 90) {
      return new Response(JSON.stringify({ error: "Latitude tidak valid (harus antara -90 dan 90)" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (isNaN(lon) || lon < -180 || lon > 180) {
      return new Response(JSON.stringify({ error: "Longitude tidak valid (harus antara -180 dan 180)" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // --- Retrieve UV Index from Open-Meteo ---
    const openMeteoUrl = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=uv_index&forecast_days=2&timezone=auto`;
    const openMeteoRes = await fetch(openMeteoUrl);
    if (!openMeteoRes.ok) {
      return new Response(JSON.stringify({ error: "Gagal mengambil data indeks UV dari Open-Meteo" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const openMeteoData = await openMeteoRes.json();
    const utcOffsetSeconds = openMeteoData.utc_offset_seconds || 0;
    const uvIndexArr = openMeteoData.hourly?.uv_index;
    if (!uvIndexArr || uvIndexArr.length < 48) {
      return new Response(JSON.stringify({ error: "Format data UV Open-Meteo tidak valid" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // Calculate current local hour at coordinate
    const now = new Date();
    const localTime = new Date(now.getTime() + utcOffsetSeconds * 1000);
    const currentLocalHour = localTime.getUTCHours();

    // --- Validate Waktu Penggunaan Sunscreen ---
    const isNight = currentLocalHour >= 18 || currentLocalHour < 6;
    if (isNight) {
      if (!body.usage_time_preference) {
        return new Response(JSON.stringify({ error: "Waktu penggunaan sunscreen wajib dipilih saat malam hari" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }

      if (!['morning', 'afternoon', 'evening'].includes(body.usage_time_preference)) {
        return new Response(JSON.stringify({ error: "Waktu penggunaan sunscreen malam hari tidak valid (harus morning, afternoon, atau evening)" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    } else {
      if (body.usage_time_preference && !['realtime', 'morning', 'afternoon', 'evening'].includes(body.usage_time_preference)) {
        return new Response(JSON.stringify({ error: "Waktu penggunaan sunscreen tidak valid" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    // --- Determine UV Index & Forecast Status ---
    let uvIndex = 0;
    let isForecast = false;
    let usageTimePref = body.usage_time_preference || 'realtime';

    if (!isNight && usageTimePref === 'realtime') {
      uvIndex = Number(uvIndexArr[currentLocalHour] || 0);
      isForecast = false;
    } else {
      isForecast = true;
      if (usageTimePref === 'realtime') {
        // Fallback if daytime but somehow fell here (shouldn't under correct flow, but safe fallback)
        usageTimePref = 'morning'; 
      }

      const tomorrowUv = uvIndexArr.slice(24, 48); // index 24 to 47
      let hourIndices: number[] = [];
      if (usageTimePref === 'morning') {
        hourIndices = [6, 7, 8, 9];
      } else if (usageTimePref === 'afternoon') {
        hourIndices = [10, 11, 12, 13];
      } else if (usageTimePref === 'evening') {
        hourIndices = [14, 15, 16, 17];
      }

      const values = hourIndices.map(h => tomorrowUv[h] || 0);
      uvIndex = Math.max(...values);
    }

    // --- SPF Minimum, PA Minimum & Risk Level ---
    let spfMinimum = 15;
    if (uvIndex <= 2) spfMinimum = 15;
    else if (uvIndex <= 5) spfMinimum = 30;
    else spfMinimum = 50;

    let paMinimum = 'PA+';
    if (uvIndex <= 2) paMinimum = 'PA+';
    else if (uvIndex <= 5) paMinimum = 'PA++';
    else if (uvIndex <= 10) paMinimum = 'PA+++';
    else paMinimum = 'PA++++';

    let uvRiskLevel = 'low';
    if (uvIndex <= 2) uvRiskLevel = 'low';
    else if (uvIndex <= 5) uvRiskLevel = 'moderate';
    else if (uvIndex <= 7) uvRiskLevel = 'high';
    else if (uvIndex <= 10) uvRiskLevel = 'very_high';
    else uvRiskLevel = 'extreme';

    // --- Initialize Database Client ---
    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // --- Fetch Skin Type Details & Skin Concerns Details ---
    const { data: skinTypeData, error: skinTypeError } = await adminClient
      .from('skin_types')
      .select('skin_type_code, skin_type_name')
      .eq('skin_type_id', body.skin_type_id)
      .single();

    if (skinTypeError || !skinTypeData) {
      return new Response(JSON.stringify({ error: "Jenis kulit tidak ditemukan di database" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const { data: skinConcernsData, error: skinConcernsError } = await adminClient
      .from('skin_concerns')
      .select('skin_concern_id, skin_concern_code, skin_concern_name')
      .in('skin_concern_id', body.skin_concern_ids);

    if (skinConcernsError || !skinConcernsData || skinConcernsData.length === 0) {
      return new Response(JSON.stringify({ error: "Masalah kulit tidak ditemukan di database" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const userSkinCode = mapSkinTypeCode(skinTypeData.skin_type_code || skinTypeData.skin_type_name);
    const userConcernCodes = skinConcernsData.map(item => mapConcernCode(item.skin_concern_code || item.skin_concern_name));

    // Get auto-avoided ingredient IDs for 'unknown_ingredient' and sensitive skin
    const { data: autoAvoidData } = await adminClient
      .from('ingredients')
      .select('ingredient_id, ingredient_code')
      .in('ingredient_code', ['oxybenzone', 'benzophenone_3', 'fragrance']);
    const autoAvoidIds = (autoAvoidData || []).map(item => item.ingredient_id);

    // --- Fetch Active Products with Relations ---
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
      return new Response(JSON.stringify({ error: "Tidak ada produk aktif yang tersedia di database" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // Map all skin types for ID-to-code lookup
    const { data: allSkinTypes } = await adminClient
      .from('skin_types')
      .select('skin_type_id, skin_type_code, skin_type_name');
    const skinTypeMap = new Map<string, string>();
    if (allSkinTypes) {
      for (const st of allSkinTypes) {
        skinTypeMap.set(st.skin_type_id, mapSkinTypeCode(st.skin_type_code || st.skin_type_name));
      }
    }

    // --- Filter & Score Sunscreen Products ---
    const qualifiedScoredProducts = [];

    for (const product of products) {
      const productIngredientCodes = product.product_ingredients
        ?.map((pi: any) => pi.ingredients?.ingredient_code?.toLowerCase())
        .filter(Boolean) || [];
      const productIngredientIds = product.product_ingredients?.map((pi: any) => pi.ingredient_id) || [];

      // ─────────────────────────────────────
      // HARD FILTER 1: RIWAYAT ALERGI & SAFETY AUTO-FILTER
      // ─────────────────────────────────────
      let passAllergy = true;

      // A. Safety Auto-Filter berdasarkan Tipe Kulit dan Masalah Kulit
      // Tipe Kulit Sensitif ATAU Masalah Kulit Sensitif/Iritasi
      const isSensitiveCondition = userSkinCode === 'sensitive' || userConcernCodes.includes('sensitive_irritation');
      if (isSensitiveCondition) {
        const hasSensitiveIrritants = productIngredientCodes.includes('fragrance') ||
                                      productIngredientCodes.includes('oxybenzone') ||
                                      productIngredientCodes.includes('benzophenone_3') ||
                                      productIngredientCodes.includes('geranium_oil') ||
                                      productIngredientCodes.includes('flavour') ||
                                      productIngredientIds.some((id: string) => autoAvoidIds.includes(id));
        if (hasSensitiveIrritants) {
          passAllergy = false;
        }
      }

      // Tipe Kulit Kering
      if (userSkinCode === 'dry') {
        const hasDryIrritants = productIngredientCodes.includes('alcohol') ||
                                productIngredientCodes.includes('alcohol_denat') ||
                                productIngredientCodes.includes('t_butyl_alcohol') ||
                                productIngredientCodes.includes('ethanol');
        if (hasDryIrritants) {
          passAllergy = false;
        }
      }

      // B. Filter Alergi Manual (sebagai cadangan/input langsung API)
      if (body.allergy_status === 'unknown_ingredient') {
        const hasAutoAvoid = productIngredientCodes.includes('oxybenzone') ||
                             productIngredientCodes.includes('benzophenone_3') ||
                             productIngredientCodes.includes('fragrance') ||
                             productIngredientIds.some((id: string) => autoAvoidIds.includes(id));
        if (hasAutoAvoid) {
          passAllergy = false;
        }
      } else if (body.allergy_status === 'known_ingredient') {
        const avoidedIds = body.avoided_ingredient_ids || [];
        const hasAvoided = productIngredientIds.some((id: string) => avoidedIds.includes(id));
        if (hasAvoided) {
          passAllergy = false;
        }
      }

      if (!passAllergy) continue;

      // ─────────────────────────────────────
      // HARD FILTER 2: SPF DAN PA MINIMUM
      // ─────────────────────────────────────
      if (product.spf < spfMinimum) continue;
      if (!comparePaGrade(product.pa_grade, paMinimum)) continue;

      // ─────────────────────────────────────
      // SCORING
      // ─────────────────────────────────────
      
      // A. Skin Type Score (0-30)
      const productSkinCodes = product.product_skin_types
        ?.map((pst: any) => skinTypeMap.get(pst.skin_type_id))
        .filter(Boolean) || [];

      let maxSkinTypeScore = 0;
      for (const pSkinCode of productSkinCodes) {
        const lookupScore = similarity[userSkinCode]?.[pSkinCode] ?? 0;
        if (lookupScore > maxSkinTypeScore) {
          maxSkinTypeScore = lookupScore;
        }
      }

      // B. Skin Concern Score (0-30)
      const scoreAcne = (p: any) => {
        if (p.is_non_comedogenic && p.is_oil_free) return 30;
        if (p.is_non_comedogenic) return 20;
        if (p.is_oil_free) return 15;
        return 0;
      };

      const scoreHyperpigmentation = (p: any, codes: string[]) => {
        const hasBrightening = codes.includes('niacinamide') || codes.includes('vitamin_c');
        const paVal = paToNumber(p.pa_grade);
        if (paVal >= 4 && hasBrightening) return 30;
        if (paVal >= 3 && hasBrightening) return 25;
        if (paVal >= 4) return 20;
        if (paVal >= 3) return 15;
        return 0;
      };

      const scoreSensitiveIrritation = (p: any, codes: string[]) => {
        const isPhys = p.sunscreen_type === 'physical';
        const isHyb = p.sunscreen_type === 'hybrid';
        const fragFree = !codes.includes('fragrance');
        const alcFree = !codes.includes('alcohol_denat') && !codes.includes('ethanol');
        const eoFree = !codes.includes('essential_oil');

        if (isPhys && fragFree && alcFree && eoFree) return 30;
        if (isPhys && fragFree && alcFree) return 25;
        if (isPhys) return 20;
        if (isHyb && fragFree && alcFree) return 15;
        return 0;
      };

      const scoreAging = (p: any, codes: string[]) => {
        const hasAnti = codes.includes('vitamin_c') || codes.includes('peptide') || codes.includes('tocopherol');
        const paVal = paToNumber(p.pa_grade);
        if (paVal >= 4 && hasAnti) return 30;
        if (paVal >= 4) return 20;
        if (paVal >= 3 && hasAnti) return 15;
        if (paVal >= 3) return 10;
        return 0;
      };

      const concernScores: number[] = [];
      for (const concernCode of userConcernCodes) {
        if (concernCode === 'acne') concernScores.push(scoreAcne(product));
        else if (concernCode === 'hyperpigmentation') concernScores.push(scoreHyperpigmentation(product, productIngredientCodes));
        else if (concernCode === 'sensitive_irritation') concernScores.push(scoreSensitiveIrritation(product, productIngredientCodes));
        else if (concernCode === 'aging') concernScores.push(scoreAging(product, productIngredientCodes));
      }
      const avgConcernScore = concernScores.length > 0
        ? Math.ceil(concernScores.reduce((a, b) => a + b, 0) / concernScores.length)
        : 0;

      // C. Activity Score (0-25)
      let activityScore = 0;
      const act = body.activity;
      if (act === 'indoor') {
        if (['gel', 'serum', 'watery', 'mist'].includes(product.texture)) activityScore = 25;
        else if (['lotion', 'milk'].includes(product.texture)) activityScore = 20;
        else if (product.texture === 'cream') activityScore = 15;
        else activityScore = 10;
      } else if (act === 'outdoor_light') {
        if (product.is_water_resistant) activityScore = 25;
        else if (['gel', 'lotion', 'serum', 'watery'].includes(product.texture)) activityScore = 20;
        else activityScore = 15;
      } else if (act === 'outdoor_intense') {
        if (product.is_water_resistant && ['gel', 'serum', 'lotion', 'watery'].includes(product.texture)) activityScore = 25;
        else if (product.is_water_resistant) activityScore = 20;
        else activityScore = 0;
      } else if (act === 'sport') {
        if (product.is_water_resistant && ['gel', 'serum', 'watery'].includes(product.texture)) activityScore = 25;
        else if (product.is_water_resistant && ['lotion', 'milk'].includes(product.texture)) activityScore = 18;
        else if (product.is_water_resistant) activityScore = 10;
        else activityScore = 0;
      } else if (act === 'swim') {
        if (product.is_very_water_resistant) activityScore = 25;
        else if (product.is_water_resistant) activityScore = 10;
        else activityScore = 0;
      }

      // D. Texture Score (0-15)
      let textureScore = 10;
      if (body.texture_preference) {
        textureScore = texture_match[body.texture_preference]?.[product.texture] ?? 0;
      }

      const totalRaw = maxSkinTypeScore + avgConcernScore + activityScore + textureScore;

      // ─────────────────────────────────────
      // PENALTY
      // ─────────────────────────────────────
      let penalty = 0;
      if (userSkinCode === 'sensitive' && product.sunscreen_type === 'chemical') {
        penalty += 10;
      }
      if (act === 'outdoor_intense' && !product.is_water_resistant) {
        penalty += 8;
      }
      if (act === 'sport' && !product.is_water_resistant) {
        penalty += 8;
      }
      if (act === 'swim' && !product.is_very_water_resistant) {
        penalty += 10;
      }
      if (userSkinCode === 'oily' && product.texture === 'cream') {
        penalty += 5;
      }
      if (userSkinCode === 'oily' && product.finish === 'dewy') {
        penalty += 3;
      }
      if (userSkinCode === 'oily' && product.finish === 'tone_up') {
        penalty += 3;
      }

      const finalScore = Math.max(0, totalRaw - penalty);

      if (finalScore >= 40) {
        qualifiedScoredProducts.push({
          product,
          maxSkinTypeScore,
          avgConcernScore,
          activityScore,
          textureScore,
          totalRaw,
          penalty,
          finalScore
        });
      }
    }

    // --- Ranking & Top 5 Selection ---
    qualifiedScoredProducts.sort((a, b) => b.finalScore - a.finalScore || a.product.product_name.localeCompare(b.product.product_name));
    const topProducts = qualifiedScoredProducts.slice(0, 5);

    if (topProducts.length === 0) {
      return new Response(JSON.stringify({ error: "Tidak ada produk yang cukup sesuai dengan kondisi kulit dan UV saat ini (Skor minimal 40)" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const ranked = topProducts.map((item, index) => {
      let category = 'fairly_suitable';
      if (item.finalScore >= 80) category = 'highly_recommended';
      else if (item.finalScore >= 60) category = 'recommended';

      return {
        ...item,
        rank_position: index + 1,
        category
      };
    });

    // --- Save to Database via PL/pgSQL Transaction RPC ---
    const { data: transactionRes, error: transactionError } = await adminClient.rpc('save_recommendation_transaction', {
      p_user_id: body.user_id,
      p_skin_type_id: body.skin_type_id,
      p_activity: body.activity,
      p_texture_preference: body.texture_preference || null,
      p_allergy_status: body.allergy_status,
      p_usage_time_preference: usageTimePref,
      p_location_name: body.location_name || null,
      p_latitude: lat,
      p_longitude: lon,
      p_uv_index: uvIndex,
      p_skin_concern_ids: body.skin_concern_ids,
      p_avoided_ingredient_ids: body.avoided_ingredient_ids || [],
      p_results: ranked.map(item => ({
        product_id: item.product.product_id,
        match_score: item.finalScore,
        recommendation_category: item.category,
        rank_position: item.rank_position
      }))
    });

    if (transactionError || !transactionRes) {
      return new Response(JSON.stringify({ error: `Gagal menyimpan hasil rekomendasi: ${transactionError?.message || 'Unknown error'}` }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // --- Format Response ---
    const responsePayload = {
      recommendation_session_id: transactionRes.session_id,
      recommendation_code: transactionRes.recommendation_code,
      uv_data: {
        uv_index: uvIndex,
        uv_risk_level: uvRiskLevel,
        spf_minimum: spfMinimum,
        pa_minimum: paMinimum,
        usage_time_preference: usageTimePref,
        is_forecast: isForecast
      },
      results: ranked.map(item => ({
        rank_position: item.rank_position,
        product_id: item.product.product_id,
        product_code: item.product.product_code,
        brand_name: item.product.brand_name,
        product_name: item.product.product_name,
        bpom_number: item.product.bpom_number,
        spf: item.product.spf,
        pa_grade: item.product.pa_grade,
        sunscreen_type: item.product.sunscreen_type,
        texture: item.product.texture,
        finish: item.product.finish,
        match_score: item.finalScore,
        recommendation_category: item.category
      }))
    };

    return new Response(JSON.stringify(responsePayload), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message || "Terjadi kesalahan internal pada server" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
});
