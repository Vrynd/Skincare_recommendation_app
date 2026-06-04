import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";
import { saveRecommendationSession, fetchAllActiveProducts, getSkinTypeCode, getConcernCodes } from "./db.ts";
import { runFilterF1 } from "./filter.ts";
import { calculateS1, calculateS2, calculateS3, calculateS4 } from "./scoring.ts";
import { calculateTotalScore, rankByCategory } from "./formula.ts";
import { saveRecommendationResults } from "./formula.ts";
import { generateWarnings } from "./warnings.ts";
import { generateAvoidedInfo } from "./avoided-info.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // ── Validasi method ──────────────────────────────────────
    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // ── Ambil body request ───────────────────────────────────
    const body = await req.json().catch(() => ({}));

    // ── Ambil JWT auth / User ID ─────────────────────────────
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

    // Fallback untuk Postman / API testing tanpa JWT
    if (!userId) {
      userId = body.user_id || 'a9edf4f2-5027-4c71-93a0-040c34327533'; // Default ke Salman
    }
    body.user_id = userId;

    // ── Penyelarasan / Normalisasi parameter input ────────────
    const selected_concern_ids = body.selected_concern_ids || body.skin_concern_ids || [];
    body.selected_concern_ids = selected_concern_ids;

    const avoided_ingredient_ids = body.avoided_ingredient_ids || [];
    body.avoided_ingredient_ids = avoided_ingredient_ids;

    let allergy_status = body.allergy_status;
    if (allergy_status === 'known_ingredient') allergy_status = 'known';
    if (allergy_status === 'unknown_ingredient') allergy_status = 'unknown';
    body.allergy_status = allergy_status;

    const uv_category = body.uv_category || body.uv_risk_level || '';
    body.uv_category = uv_category;

    const uv_index = body.uv_index !== undefined && body.uv_index !== null ? Number(body.uv_index) : null;
    body.uv_index = uv_index;

    // ── Validasi field wajib ─────────────────────────────────
    if (!body.user_id) {
      return new Response(JSON.stringify({ error: "user_id wajib diisi" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!body.skin_type_id) {
      return new Response(JSON.stringify({ error: "skin_type_id wajib diisi" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!body.selected_concern_ids || body.selected_concern_ids.length === 0) {
      return new Response(JSON.stringify({ error: "Minimal 1 masalah kulit harus dipilih" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!body.usage_time) {
      return new Response(JSON.stringify({ error: "usage_time wajib diisi" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (body.uv_index === null) {
      return new Response(JSON.stringify({ error: "uv_index wajib diisi" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!body.uv_category) {
      return new Response(JSON.stringify({ error: "uv_category wajib diisi" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!['none', 'unknown', 'known'].includes(body.allergy_status)) {
      return new Response(JSON.stringify({ error: "allergy_status tidak valid" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (body.allergy_status === 'known' && (!body.avoided_ingredient_ids || body.avoided_ingredient_ids.length === 0)) {
      return new Response(JSON.stringify({ error: "avoided_ingredient_ids wajib diisi jika allergy_status = known" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // Inisialisasi Admin Client untuk bypass RLS pada transaksi tulis database
    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // ── Simpan sesi rekomendasi ke 3 tabel ─────────────────────
    const recommendation_id = await saveRecommendationSession(adminClient, body);

    // ── Ambil semua produk aktif beserta relasinya ───────────
    const products = await fetchAllActiveProducts(adminClient);

    if (!products || products.length === 0) {
      return new Response(JSON.stringify({ error: "Tidak ada produk yang tersedia" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // Ambil kode tekstual (name) dari database untuk evaluasi aturan khusus
    const skinTypeCode = await getSkinTypeCode(adminClient, body.skin_type_id);
    const concernCodes = await getConcernCodes(adminClient, body.selected_concern_ids);

    // ── Jalankan Rule-Based Scoring ──────────────────────────
    const scored_products = [];

    for (const product of products) {
      // Layer 1 — Filter F1 (hanya jika known)
      if (body.allergy_status === 'known') {
        const isSafe = runFilterF1(product, body.avoided_ingredient_ids);
        if (!isSafe) {
          continue; // skip, tidak masuk scoring
        }
      }

      // Layer 2 — Scoring S1, S2, S3, S4
      const s1 = calculateS1(product, body.skin_type_id);
      const s2 = calculateS2(product, body.selected_concern_ids);
      const s3 = calculateS3(product, body.uv_index);
      const s4 = calculateS4(product, body.usage_time);

      // Layer 3 — Hitung skor akhir dengan bobot dinamis
      const total = calculateTotalScore(s1, s2, s3, s4, concernCodes);

      // Hanya masukkan produk skor >= 50
      if (total >= 50) {
        scored_products.push({
          product: product,
          score_s1: s1,
          score_s2: s2,
          score_s3: s3,
          score_s4: s4,
          total_score: total
        });
      }
    }

    // ── Ranking per kategori ─────────────────────────────────
    const ranked_results = rankByCategory(scored_products);

    // ── Simpan hasil ke recommendation_results ───────────────
    await saveRecommendationResults(adminClient, recommendation_id, ranked_results);

    // ── Generate peringatan kontekstual ──────────────────────
    const warnings = generateWarnings(
      body.uv_index,
      body.uv_category,
      body.allergy_status,
      ranked_results
    );

    // ── Generate info bahan yang harus dihindari ─────────────
    const avoided_info = generateAvoidedInfo(skinTypeCode, concernCodes);

    // ── Return response ke Flutter ───────────────────────────
    return new Response(JSON.stringify({
      session_id: recommendation_id, // Flutter compatibility
      recommendation_id: recommendation_id,
      created_at: new Date().toISOString(),
      uv_index: body.uv_index,
      uv_category: body.uv_category,
      location_name: body.location_name || null,
      results: ranked_results,
      warnings: warnings,
      avoided_ingredients_info: avoided_info
    }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
});
