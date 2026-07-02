// @ts-nocheck
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";
import { corsHeaders } from "./cors.ts";
import {
  mapSkinTypeCode,
  mapConcernCode,
  comparePaGrade,
} from "./utils.ts";
import {
  isAllergyOrSafetyBlocked,
  calculateSkinTypeScore,
  calculateSkinConcernScore,
  calculateActivityScore,
  calculateTextureScore,
  calculateFinishScore,
  calculatePenalty,
} from "./scoring.ts";
import {
  validateRequestBody,
  validateUsageTimePreference,
} from "./validation.ts";
import { getUvDataAndThresholds } from "./uv_service.ts";
import {
  fetchSkinProfile,
  fetchAutoAvoidIngredientIds,
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
    const userConcernCodes = skinConcernsData!.map(item => mapConcernCode(item.skin_concern_code || item.skin_concern_name));

    // Get auto-avoided ingredient IDs for sensitive skin / unknown allergen history
    const autoAvoidIds = await fetchAutoAvoidIngredientIds(adminClient);

    // --- Fetch Active Products with Relations ---
    const activeProductsRes = await fetchActiveProducts(adminClient);
    if (activeProductsRes.error) {
      return new Response(JSON.stringify({ error: activeProductsRes.error }), {
        status: activeProductsRes.statusCode || 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const products = activeProductsRes.products!;

    // Map all skin types for ID-to-code lookup
    const skinTypeMap = await fetchAllSkinTypesMap(adminClient);
    const skinConcernMap = await fetchAllSkinConcernsMap(adminClient);

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
      const isBlocked = isAllergyOrSafetyBlocked(
        userSkinCode,
        body.allergy_status,
        body.avoided_ingredient_ids || [],
        productIngredientCodes,
        productIngredientIds,
        autoAvoidIds
      );

      if (isBlocked) continue;

      // ─────────────────────────────────────
      // HARD FILTER 2: SPF DAN PA MINIMUM
      // ─────────────────────────────────────
      if (product.spf < spfMinimum) continue;
      if (!comparePaGrade(product.pa_grade, paMinimum)) continue;

      // ─────────────────────────────────────
      // SCORING
      // ─────────────────────────────────────
      const productSkinCodes = product.product_skin_types
        ?.map((pst: any) => skinTypeMap.get(pst.skin_type_id))
        .filter(Boolean) || [];

      // A. Skin Type Score
      const maxSkinTypeScore = calculateSkinTypeScore(userSkinCode, productSkinCodes);

      // B. Skin Concern Score
      const productConcernCodes = product.product_skin_concerns
        ?.map((psc: any) => skinConcernMap.get(psc.skin_concern_id))
        .filter(Boolean) || [];
      const skinConcernScore = calculateSkinConcernScore(userConcernCodes, productConcernCodes, product);

      // C. Activity Score
      const activityScore = calculateActivityScore(body.activity, product);

      // D. Texture Score
      const textureScore = calculateTextureScore(body.texture_preference, product.texture, userSkinCode);

      // E. Finish Score
      const finishScore = calculateFinishScore(body.finish_preference, product.finish, userSkinCode);

      const totalRaw = maxSkinTypeScore + skinConcernScore + activityScore + textureScore + finishScore;

      // F. Penalty Calculation
      const penalty = calculatePenalty(userSkinCode, body.activity, product);

      const finalScore = Math.max(0, totalRaw - penalty);

      if (finalScore >= 40) {
        qualifiedScoredProducts.push({
          product,
          maxSkinTypeScore,
          skinConcernScore,
          activityScore,
          textureScore,
          finishScore,
          totalRaw,
          penalty,
          finalScore
        });
      }
    }

    // --- Ranking & Top 3 Selection ---
    qualifiedScoredProducts.sort((a, b) => b.finalScore - a.finalScore || a.product.product_name.localeCompare(b.product.product_name));
    const topProducts = qualifiedScoredProducts.slice(0, 3);

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
      rankedProducts: ranked
    });

    if (transaction.error) {
      return new Response(JSON.stringify({ error: transaction.error }), {
        status: transaction.statusCode || 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const { transactionRes } = transaction;

    // --- Format Response Payload ---
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
        recommendation_category: item.category,
        skin_type_score: item.maxSkinTypeScore,
        activity_score: item.activityScore,
        skin_concern_score: item.skinConcernScore,
        texture_score: item.textureScore,
        finish_score: item.finishScore,
        penalty: item.penalty
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
