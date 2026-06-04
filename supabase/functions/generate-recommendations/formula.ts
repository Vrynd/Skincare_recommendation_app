// ─────────────────────────────────────────────────────────────
// Skor akhir dengan bobot dinamis
// ─────────────────────────────────────────────────────────────
export function calculateTotalScore(
  s1: number,
  s2: number,
  s3: number,
  s4: number,
  selectedConcernNames: string[]
): number {
  // Cek apakah ada masalah yang memicu bobot dinamis S3
  const UVSensitiveCodes = ['dark_spot', 'wrinkle'];

  const hasUvSensitive = selectedConcernNames.some(name =>
    UVSensitiveCodes.includes(name)
  );

  let bobotS1 = 0.30;
  let bobotS2 = 0.35;
  let bobotS3 = 0.20;
  let bobotS4 = 0.15;

  if (hasUvSensitive) {
    // Bobot dinamis — S3 naik, S1 turun
    bobotS1 = 0.25;
    bobotS2 = 0.35;
    bobotS3 = 0.25;
    bobotS4 = 0.15;
  }

  const total = (s1 * bobotS1) + (s2 * bobotS2) + (s3 * bobotS3) + (s4 * bobotS4);

  return parseFloat(total.toFixed(2));
}

// ─────────────────────────────────────────────────────────────
// Ranking per kategori produk
// ─────────────────────────────────────────────────────────────
export interface ScoredProduct {
  product: any;
  score_s1: number;
  score_s2: number;
  score_s3: number;
  score_s4: number;
  total_score: number;
  rank?: number;
  rank_position?: number;
}

export function rankByCategory(scoredProducts: ScoredProduct[]): ScoredProduct[] {
  const CATEGORIES = [
    'Cleanser', 'Toner', 'Serum', 
    'Moisturizer', 'Sunscreen'
  ];

  const rankedResults: ScoredProduct[] = [];

  for (const category of CATEGORIES) {
    // Filter produk kategori ini
    const categoryProducts = scoredProducts.filter(p => {
      const prodCat = p.product.category ? p.product.category.toLowerCase() : '';
      const targetCat = category.toLowerCase();
      // Handle alias for moisturizer
      if (targetCat === 'moisturizer') {
        return prodCat === 'moisturizer' || prodCat === 'moisture';
      }
      return prodCat === targetCat;
    });

    if (categoryProducts.length === 0) {
      continue; // tidak ada produk lolos kategori ini
    }

    // Urutkan: skor tertinggi dulu
    categoryProducts.sort((a, b) => b.total_score - a.total_score);

    // Ambil top 1 (produk dengan skor tertinggi)
    const top1 = categoryProducts.slice(0, 1);

    // Beri rank per kategori
    top1.forEach((item, index) => {
      item.rank = index + 1;
      item.rank_position = index + 1;
      rankedResults.push(item);
    });
  }

  return rankedResults;
}

// ─────────────────────────────────────────────────────────────
// Simpan hasil ke recommendation_results
// ─────────────────────────────────────────────────────────────
export async function saveRecommendationResults(
  adminClient: any,
  recommendationId: string,
  rankedResults: ScoredProduct[]
) {
  if (rankedResults.length === 0) return;

  const resultsToInsert = rankedResults.map(res => ({
    recommendation_session_id: recommendationId,
    product_id: res.product.product_id,
    match_score: res.total_score,
    rank_position: res.rank_position
  }));

  const { error } = await adminClient
    .from('recommendation_results')
    .insert(resultsToInsert);

  if (error) {
    throw new Error(`Failed to save recommendation results: ${error.message}`);
  }
}
