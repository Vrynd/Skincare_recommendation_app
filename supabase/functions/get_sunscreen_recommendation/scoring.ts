import { WEIGHTS, TEXTURE_GROUPS, FINISH_NEIGHBORS } from "./constants.ts";
import { comparePaGrade } from "./utils.ts";


/**
 * C1: Evaluasi Derajat Kecocokan Proteksi UV (s_i1)
 * Nilai: 1.0 jika SPF dan PA memenuhi target; 0.0 jika salah satu atau keduanya tidak memenuhi
 */
export function calculateUvProtectionScore(
  productSpf: number,
  productPa: string,
  targetSpf: number,
  targetPa: string
): number {
  const isSpfMet = productSpf >= targetSpf;
  const isPaMet = comparePaGrade(productPa, targetPa);
  return (isSpfMet && isPaMet) ? 1.0 : 0.0;
}

/**
 * C2: Evaluasi Derajat Kecocokan Jenis Kulit (s_i2)
 * Nilai:
 * - 1.0 jika klaim spesifik produk cocok dengan jenis kulit pengguna
 * - 0.6 jika produk memiliki klaim untuk semua jenis kulit (netral/normal)
 * - 0.0 jika tidak ada kecocokan yang terverifikasi
 */
export function calculateSkinTypeScore(
  userSkinCode: string,
  productSkinCodes: string[]
): number {
  if (productSkinCodes.includes(userSkinCode)) {
    return 1.0;
  }
  // Formula netral / untuk semua jenis kulit
  if (productSkinCodes.includes('normal') || productSkinCodes.includes('all_skin_types') || userSkinCode === 'normal') {
    return 0.6;
  }
  return 0.0;
}

/**
 * C3: Evaluasi Derajat Kecocokan Aktivitas Harian (s_i3)
 * Nilai:
 * - 1.0 untuk indoor & outdoor ringan (tanpa syarat ketahanan air)
 * - 1.0 untuk outdoor intensif & olahraga JIKA produk water-resistant; 0.0 jika tidak
 * - Untuk renang: 1.0 jika very water-resistant; 0.5 jika water-resistant biasa; 0.0 jika tidak
 */
export function calculateActivityScore(
  activity: string,
  product: { is_water_resistant?: boolean; is_very_water_resistant?: boolean }
): number {
  if (activity === 'indoor' || activity === 'outdoor_light') {
    return 1.0;
  }

  if (activity === 'outdoor_intense' || activity === 'sport') {
    return (product.is_water_resistant || product.is_very_water_resistant) ? 1.0 : 0.0;
  }

  if (activity === 'swim') {
    if (product.is_very_water_resistant) return 1.0;
    if (product.is_water_resistant) return 0.5;
    return 0.0;
  }

  return 0.0;
}

/**
 * C4: Evaluasi Derajat Kecocokan Masalah Kulit (s_i4)
 * Nilai:
 * - 1.0 jika seluruh masalah yang dipilih memiliki klaim pendukung atau tidak ada masalah khusus
 * - 0.5 jika sebagian masalah yang dipilih memiliki klaim pendukung
 * - 0.0 jika tidak ada klaim pendukung yang sesuai
 */
export function calculateSkinConcernScore(
  userConcernCodes: string[],
  productConcernCodes: string[],
  product: { is_non_comedogenic?: boolean; is_oil_free?: boolean }
): number {
  const activeConcerns = (userConcernCodes || []).filter(c => c && c !== 'none');
  if (activeConcerns.length === 0) {
    return 1.0;
  }

  let matchCount = 0;
  for (const concern of activeConcerns) {
    if (concern === 'acne') {
      if (
        productConcernCodes.includes('acne') ||
        product.is_non_comedogenic === true ||
        product.is_oil_free === true
      ) {
        matchCount++;
      }
    } else if (concern === 'hyperpigmentation') {
      if (productConcernCodes.includes('hyperpigmentation')) {
        matchCount++;
      }
    } else {
      if (productConcernCodes.includes(concern)) {
        matchCount++;
      }
    }
  }

  if (matchCount === activeConcerns.length) return 1.0;
  if (matchCount > 0) return 0.5;
  return 0.0;
}

/**
 * C5: Evaluasi Derajat Kecocokan Preferensi Tekstur (s_i5)
 * Nilai:
 * - 1.0 jika tekstur persis sesuai preferensi
 * - 0.5 jika tekstur berada dalam kelompok sediaan sejenis (gel-serum-watery, cream-lotion-milk, spray-mist, stick)
 * - 0.0 jika berada pada kelompok berbeda
 */
export function calculateTextureScore(
  texturePreference: string | null,
  productTexture: string
): number {
  if (!texturePreference) {
    return 1.0;
  }

  const pTex = (productTexture || '').toLowerCase();
  const uTex = texturePreference.toLowerCase();

  if (pTex === uTex) {
    return 1.0;
  }

  // Cek apakah satu kelompok serumpun
  for (const group of TEXTURE_GROUPS) {
    if (group.includes(uTex) && group.includes(pTex)) {
      return 0.5;
    }
  }

  return 0.0;
}

/**
 * C6: Evaluasi Derajat Kecocokan Hasil Akhir / Finish (s_i6)
 * Nilai:
 * - 1.0 jika hasil akhir persis sesuai preferensi
 * - 0.5 jika karakteristik berdekatan (matte <-> natural, natural <-> dewy)
 * - 0.0 jika tidak sesuai / tone-up terpisah
 */
export function calculateFinishScore(
  finishPreference: string | null,
  productFinish: string
): number {
  if (!finishPreference) {
    return 1.0;
  }

  const pFinish = (productFinish || '').toLowerCase();
  const uFinish = finishPreference.toLowerCase();

  if (pFinish === uFinish) {
    return 1.0;
  }

  const neighbors = FINISH_NEIGHBORS[uFinish] || [];
  if (neighbors.includes(pFinish)) {
    return 0.5;
  }

  return 0.0;
}

export interface EvaluationResult {
  s_uv: number;
  s_skin: number;
  s_activity: number;
  s_concern: number;
  s_texture: number;
  s_finish: number;
  finalScore: number;
  category: 'highly_recommended' | 'recommended' | 'fairly_suitable' | 'not_suitable';
  isEligible: boolean;
  contributions: {
    uv: number;
    skinType: number;
    activity: number;
    skinConcern: number;
    texture: number;
    finish: number;
  };
}

/**
 * Evaluasi Lengkap 5 Langkah untuk Satu Produk
 */
export function evaluateProduct(
  product: any,
  userSkinCode: string,
  userConcernCodes: string[],
  activity: string,
  texturePreference: string | null,
  finishPreference: string | null,
  targetSpf: number,
  targetPa: string,
  productSkinCodes: string[],
  productConcernCodes: string[]
): EvaluationResult {
  // 1. Hitung s_ij untuk keenam kriteria
  const s_uv = calculateUvProtectionScore(product.spf, product.pa_grade, targetSpf, targetPa);
  const s_skin = calculateSkinTypeScore(userSkinCode, productSkinCodes);
  const s_activity = calculateActivityScore(activity, product);
  const s_concern = calculateSkinConcernScore(userConcernCodes, productConcernCodes, product);
  const s_texture = calculateTextureScore(texturePreference, product.texture);
  const s_finish = calculateFinishScore(finishPreference, product.finish);

  // 2. Perhitungan Skor Akhir Terbobot: Final Score = 100 * sum(w_j * s_ij)
  const weightedSum =
    WEIGHTS.uv * s_uv +
    WEIGHTS.skinType * s_skin +
    WEIGHTS.activity * s_activity +
    WEIGHTS.skinConcern * s_concern +
    WEIGHTS.texture * s_texture +
    WEIGHTS.finish * s_finish;

  // Konversi ke skala 0 - 100 (dibulatkan ke integer)
  const finalScore = Math.round(weightedSum * 100);

  // 3. Kategori Kesesuaian (Tabel 4)
  let category: EvaluationResult['category'] = 'not_suitable';
  if (finalScore >= 80) {
    category = 'highly_recommended';
  } else if (finalScore >= 60) {
    category = 'recommended';
  } else if (finalScore >= 40) {
    category = 'fairly_suitable';
  }

  // 4. Seleksi Kelayakan Kandidat (Langkah 5): Skor Akhir >= 40 (Kategori Cukup Sesuai ke atas)
  const isEligible = finalScore >= 40;

  // 5. Persentase Kontribusi Relatif K_ij (Persamaan 2)
  let contributions = {
    uv: 0,
    skinType: 0,
    activity: 0,
    skinConcern: 0,
    texture: 0,
    finish: 0,
  };

  if (weightedSum > 0) {
    contributions = {
      uv: Math.round(((WEIGHTS.uv * s_uv) / weightedSum) * 1000) / 10,
      skinType: Math.round(((WEIGHTS.skinType * s_skin) / weightedSum) * 1000) / 10,
      activity: Math.round(((WEIGHTS.activity * s_activity) / weightedSum) * 1000) / 10,
      skinConcern: Math.round(((WEIGHTS.skinConcern * s_concern) / weightedSum) * 1000) / 10,
      texture: Math.round(((WEIGHTS.texture * s_texture) / weightedSum) * 1000) / 10,
      finish: Math.round(((WEIGHTS.finish * s_finish) / weightedSum) * 1000) / 10,
    };
  }

  return {
    s_uv,
    s_skin,
    s_activity,
    s_concern,
    s_texture,
    s_finish,
    finalScore,
    category,
    isEligible,
    contributions,
  };
}
