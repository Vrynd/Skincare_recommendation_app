// @ts-nocheck
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";
import { corsHeaders } from "./cors.ts";
import {
  mapSkinTypeCode,
  mapConcernCode,
} from "./utils.ts";
import {
  evaluateProduct,
} from "./scoring.ts";
import {
  TARGET_ROUTINE,
  WEIGHTS,
} from "./constants.ts";
import {
  validateRequestBody,
  validateUsageTimePreference,
} from "./validation.ts";
import { getUvDataAndThresholds } from "./uv_service.ts";
import {
  fetchSkinProfile,
  fetchActiveProducts,
  fetchAllSkinTypesMap,
  fetchAllSkinConcernsMap,
  saveRecommendationTransaction,
} from "./db_service.ts";

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

    // --- Validate Request Body ---
    const validation = validateRequestBody(body);
    if (validation.error) {
      return new Response(JSON.stringify({ error: validation.error }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const lat = Number(body.latitude);
    const lon = Number(body.longitude);

    // --- Retrieve UV Index from Open-Meteo & Thresholds ---
    let uvData;
    try {
      uvData = await getUvDataAndThresholds(lat, lon, body.usage_time_preference);
    } catch (err: any) {
      return new Response(JSON.stringify({ error: err.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const {
      uvIndex,
      uvRiskLevel,
      spfMinimum,
      paMinimum,
      usageTimePref,
      isForecast,
      isNight
    } = uvData;

    // --- Validate Sunscreen Usage Time Preference (Night flow checking) ---
    const usageTimeValidation = validateUsageTimePreference(body.usage_time_preference, isNight);
    if (usageTimeValidation.error) {
      return new Response(JSON.stringify({ error: usageTimeValidation.error }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // --- Initialize Database Client ---
    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // --- Fetch Skin Type Details & Skin Concerns Details ---
    const skinProfile = await fetchSkinProfile(adminClient, body.skin_type_id, body.skin_concern_ids);
    if (skinProfile.error) {
      return new Response(JSON.stringify({ error: skinProfile.error }), {
        status: skinProfile.statusCode || 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const { skinTypeData, skinConcernsData } = skinProfile;
    const userSkinCode = mapSkinTypeCode(skinTypeData.skin_type_code || skinTypeData.skin_type_name);
    const userConcernCodes = (skinConcernsData || []).map(item => mapConcernCode(item.skin_concern_code || item.skin_concern_name));

    // --- Fetch Active Products with Relations ---
    const activeProductsRes = await fetchActiveProducts(adminClient);
    if (activeProductsRes.error) {
      return new Response(JSON.stringify({ error: activeProductsRes.error }), {
        status: activeProductsRes.statusCode || 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const products = activeProductsRes.products!;

    // Map all skin types & concerns for ID-to-code lookup
    const skinTypeMap = await fetchAllSkinTypesMap(adminClient);
    const skinConcernMap = await fetchAllSkinConcernsMap(adminClient);

    // --- Evaluasi Skor Produk Sunscreen untuk Kedua Mode (Murni 6 Kriteria Berbobot) ---
    const routineCandidates = [];
    const todayCandidates = [];

    for (const product of products) {

      const productSkinCodes = product.product_skin_types
        ?.map((pst: any) => skinTypeMap.get(pst.skin_type_id))
        .filter(Boolean) || [];

      const productConcernCodes = product.product_skin_concerns
        ?.map((psc: any) => skinConcernMap.get(psc.skin_concern_id))
        .filter(Boolean) || [];

      // ─────────────────────────────────────
      // MODE 1: REKOMENDASI PRODUK (5 Kriteria Aktif: C2, C3, C4, C5, C6)
      // Mengabaikan C1 (Proteksi UV), dinormalisasi dengan total bobot aktif 0.75
      // ─────────────────────────────────────
      const evalRoutine = evaluateProduct(
        product,
        userSkinCode,
        userConcernCodes,
        body.activity,
        body.texture_preference,
        body.finish_preference,
        null,
        null,
        productSkinCodes,
        productConcernCodes,
        'routine'
      );

      routineCandidates.push({
        product,
        eval: evalRoutine,
        finalScore: evalRoutine.finalScore,
        isEligible: evalRoutine.isEligible,
      });

      // ─────────────────────────────────────
      // MODE 2: REKOMENDASI HARI INI (5 Kriteria Aktif: C1, C2, C3, C4, C6)
      // Mengabaikan C5 (Tekstur), C1 dihitung berdasarkan target UV cuaca Open-Meteo,
      // dinormalisasi dengan total bobot aktif 0.90
      // ─────────────────────────────────────
      const evalToday = evaluateProduct(
        product,
        userSkinCode,
        userConcernCodes,
        body.activity,
        null,
        body.finish_preference,
        spfMinimum,
        paMinimum,
        productSkinCodes,
        productConcernCodes,
        'today'
      );

      todayCandidates.push({
        product,
        eval: evalToday,
        finalScore: evalToday.finalScore,
        isEligible: evalToday.isEligible,
      });
    }

    // --- Ranking untuk Kedua Mode ---
    routineCandidates.sort((a, b) => (b.isEligible ? 1 : 0) - (a.isEligible ? 1 : 0) || b.finalScore - a.finalScore || a.product.product_name.localeCompare(b.product.product_name));
    todayCandidates.sort((a, b) => (b.isEligible ? 1 : 0) - (a.isEligible ? 1 : 0) || b.finalScore - a.finalScore || a.product.product_name.localeCompare(b.product.product_name));

    const allRoutine = routineCandidates.map((item, index) => ({
      ...item,
      rank_position: index + 1,
    }));

    const allToday = todayCandidates.map((item, index) => ({
      ...item,
      rank_position: index + 1,
    }));

    if (allRoutine.length === 0 && allToday.length === 0) {
      return new Response(JSON.stringify({ error: "Rekomendasi yang sesuai belum tersedia untuk kondisi saat ini." }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // Helper formatter untuk output produk
    const formatProductOutput = (item: any, mode: 'routine' | 'today') => ({
      rank_position: item.rank_position,
      mode: mode,
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
      match_score: item.eval.finalScore,
      recommendation_category: item.eval.category,
      // Nilai Derajat Kecocokan Kriteria (s_ij)
      s_uv: mode === 'today' ? item.eval.s_uv : 0,
      s_skin: item.eval.s_skin,
      s_activity: item.eval.s_activity,
      s_concern: item.eval.s_concern,
      s_texture: mode === 'routine' ? item.eval.s_texture : 0,
      s_finish: item.eval.s_finish,
      // Persentase Kontribusi Relatif K_ij (Persamaan 2 - Total 100%)
      contributions: item.eval.contributions,
      // Skor Kriteria Terbobot
      uv_score: mode === 'today' ? Math.round(item.eval.s_uv * (WEIGHTS.uv / 0.90) * 100) : 0,
      skin_type_score: mode === 'routine'
        ? Math.round(item.eval.s_skin * (WEIGHTS.skinType / 0.75) * 100)
        : Math.round(item.eval.s_skin * (WEIGHTS.skinType / 0.90) * 100),
      activity_score: mode === 'routine'
        ? Math.round(item.eval.s_activity * (WEIGHTS.activity / 0.75) * 100)
        : Math.round(item.eval.s_activity * (WEIGHTS.activity / 0.90) * 100),
      skin_concern_score: mode === 'routine'
        ? Math.round(item.eval.s_concern * (WEIGHTS.skinConcern / 0.75) * 100)
        : Math.round(item.eval.s_concern * (WEIGHTS.skinConcern / 0.90) * 100),
      texture_score: mode === 'routine'
        ? Math.round(item.eval.s_texture * (WEIGHTS.texture / 0.75) * 100)
        : 0,
      finish_score: mode === 'routine'
        ? Math.round(item.eval.s_finish * (WEIGHTS.finish / 0.75) * 100)
        : Math.round(item.eval.s_finish * (WEIGHTS.finish / 0.90) * 100),
      penalty: 0,
    });

    const routineFormatted = allRoutine.map(item => formatProductOutput(item, 'routine'));
    const todayFormatted = allToday.map(item => formatProductOutput(item, 'today'));

    // Primary results to save in DB transaction (prioritaskan mode aktif dari body.mode, simpan top 10 eligible)
    const activeCandidates = body.mode === 'routine' ? allRoutine : allToday;
    const fallbackCandidates = body.mode === 'routine' ? allToday : allRoutine;
    const primaryForTransaction = (activeCandidates.length > 0 ? activeCandidates : fallbackCandidates).filter(x => x.isEligible).slice(0, 10);

    // --- Save to Database via PL/pgSQL Transaction RPC ---
    const transaction = await saveRecommendationTransaction(adminClient, {
      userId: body.user_id,
      skinTypeId: body.skin_type_id,
      activity: body.activity,
      texturePreference: body.texture_preference,
      finishPreference: body.finish_preference || null,
      allergyStatus: body.allergy_status,
      usageTimePreference: usageTimePref,
      locationName: body.location_name,
      latitude: lat,
      longitude: lon,
      uvIndex: uvIndex,
      skinConcernIds: body.skin_concern_ids || [],
      avoidedIngredientIds: body.avoided_ingredient_ids || [],
      rankedProducts: primaryForTransaction.map(item => ({
        product: item.product,
        finalScore: item.eval.finalScore,
        category: item.eval.category,
        rank_position: item.rank_position,
        maxSkinTypeScore: Math.round(item.eval.s_skin * 25),
        activityScore: Math.round(item.eval.s_activity * 20),
        skinConcernScore: Math.round(item.eval.s_concern * 10),
        textureScore: Math.round(item.eval.s_texture * 10),
        finishScore: Math.round(item.eval.s_finish * 10),
        penalty: 0,
      }))
    });

    let sessionResponse = { session_id: null, recommendation_code: null };
    if (!transaction.error && transaction.transactionRes) {
      sessionResponse = transaction.transactionRes;
    }

    // --- Format Response Payload Lengkap (Dual Mode) ---
    const responsePayload = {
      recommendation_session_id: sessionResponse.session_id,
      recommendation_code: sessionResponse.recommendation_code,
      uv_data: {
        uv_index: uvIndex,
        uv_risk_level: uvRiskLevel,
        spf_minimum: spfMinimum,
        pa_minimum: paMinimum,
        routine_spf_target: TARGET_ROUTINE.spf,
        routine_pa_target: TARGET_ROUTINE.pa,
        usage_time_preference: usageTimePref,
        is_forecast: isForecast
      },
      routine_results: routineFormatted,
      today_results: todayFormatted,
      // Fallback backward-compatibility untuk client lama
      results: body.mode === 'routine' ? routineFormatted : (todayFormatted.length > 0 ? todayFormatted : routineFormatted),
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
