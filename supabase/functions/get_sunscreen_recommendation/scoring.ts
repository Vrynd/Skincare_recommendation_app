import { similarity, texture_match } from "./constants.ts";
import { paToNumber } from "./utils.ts";

/**
 * Memvalidasi apakah suatu produk melanggar riwayat alergi atau filter keamanan otomatis
 */
export function isAllergyOrSafetyBlocked(
  userSkinCode: string,
  allergyStatus: string,
  avoidedIngredientIds: string[],
  productIngredientCodes: string[],
  productIngredientIds: string[],
  autoAvoidIds: string[]
): boolean {
  // A. Safety Auto-Filter berdasarkan Tipe Kulit (Kandungan Iritan)
  const isSensitiveCondition = userSkinCode === 'sensitive';
  if (isSensitiveCondition) {
    const hasSensitiveIrritants = productIngredientCodes.includes('fragrance') ||
                                  productIngredientCodes.includes('oxybenzone') ||
                                  productIngredientCodes.includes('benzophenone_3') ||
                                  productIngredientCodes.includes('geranium_oil') ||
                                  productIngredientCodes.includes('flavour') ||
                                  productIngredientIds.some((id: string) => autoAvoidIds.includes(id));
    if (hasSensitiveIrritants) return true;
  }

  if (userSkinCode === 'dry') {
    const hasDryIrritants = productIngredientCodes.includes('alcohol') ||
                            productIngredientCodes.includes('alcohol_denat') ||
                            productIngredientCodes.includes('t_butyl_alcohol') ||
                            productIngredientCodes.includes('ethanol');
    if (hasDryIrritants) return true;
  }

  // B. Filter Alergi Manual (sebagai cadangan/input langsung API)
  if (allergyStatus === 'unknown_ingredient') {
    const hasAutoAvoid = productIngredientCodes.includes('oxybenzone') ||
                         productIngredientCodes.includes('benzophenone_3') ||
                         productIngredientCodes.includes('fragrance') ||
                         productIngredientIds.some((id: string) => autoAvoidIds.includes(id));
    if (hasAutoAvoid) return true;
  } else if (allergyStatus === 'known_ingredient') {
    const hasAvoided = productIngredientIds.some((id: string) => avoidedIngredientIds.includes(id));
    if (hasAvoided) return true;
  }

  return false;
}

/**
 * Menghitung skor tipe kulit berdasarkan kecocokan matriks similarity (0 - 25)
 */
export function calculateSkinTypeScore(userSkinCode: string, productSkinCodes: string[]): number {
  let maxSkinTypeScore = 0;
  for (const pSkinCode of productSkinCodes) {
    const lookupScore = similarity[userSkinCode]?.[pSkinCode] ?? 0;
    if (lookupScore > maxSkinTypeScore) {
      maxSkinTypeScore = lookupScore;
    }
  }
  // Skala dari 30 ke 25
  return Math.round(maxSkinTypeScore * 25 / 30);
}

/**
 * Menghitung skor masalah kulit (Jerawat / Kulit Kusam) (0 - 20)
 */
export function calculateSkinConcernScore(
  userConcernCodes: string[],
  productConcernCodes: string[],
  product: any
): number {
  if (!userConcernCodes || userConcernCodes.length === 0) {
    // Jika user tidak memilih masalah kulit, dianggap default/netral (aman untuk semua produk)
    return 20;
  }

  let hasMatch = false;

  for (const code of userConcernCodes) {
    if (code === 'acne') {
      if (
        productConcernCodes.includes('acne') || 
        product.is_non_comedogenic === true || 
        product.is_oil_free === true
      ) {
        hasMatch = true;
      }
    } else if (code === 'hyperpigmentation') {
      if (productConcernCodes.includes('hyperpigmentation')) {
        hasMatch = true;
      }
    }
  }

  return hasMatch ? 20 : 5;
}

/**
 * Menghitung skor aktivitas harian berdasarkan jenis aktivitas dan tekstur produk (0 - 25)
 */
export function calculateActivityScore(activity: string, product: any): number {
  const texture = product.texture;
  if (activity === 'indoor') {
    if (['gel', 'serum', 'watery', 'mist'].includes(texture)) return 25;
    if (['lotion', 'milk'].includes(texture)) return 20;
    if (texture === 'cream') return 15;
    return 10;
  }
  
  if (activity === 'outdoor_light') {
    if (product.is_water_resistant) return 25;
    if (['gel', 'lotion', 'serum', 'watery'].includes(texture)) return 20;
    return 15;
  }
  
  if (activity === 'outdoor_intense') {
    if (product.is_water_resistant && ['gel', 'serum', 'lotion', 'watery'].includes(texture)) return 25;
    if (product.is_water_resistant) return 20;
    return 0;
  }
  
  if (activity === 'sport') {
    if (product.is_water_resistant && ['gel', 'serum', 'watery'].includes(texture)) return 25;
    if (product.is_water_resistant && ['lotion', 'milk'].includes(texture)) return 18;
    if (product.is_water_resistant) return 10;
    return 0;
  }
  
  if (activity === 'swim') {
    if (product.is_very_water_resistant) return 25;
    if (product.is_water_resistant) return 10;
    return 0;
  }

  return 0;
}

/**
 * Menghitung skor preferensi tekstur (0 - 15)
 */
export function calculateTextureScore(
  texturePreference: string | null,
  productTexture: string,
  userSkinCode: string
): number {
  if (!texturePreference) {
    // Penentuan default dinamis berbasis jenis kulit demi kenyamanan maksimal jika tidak memilih
    if (userSkinCode === 'oily' || userSkinCode === 'combination') {
      if (['gel', 'serum', 'watery'].includes(productTexture)) return 15;
      if (['lotion', 'milk', 'mist'].includes(productTexture)) return 10;
      return 4;
    } else if (userSkinCode === 'dry') {
      if (['cream', 'lotion', 'milk'].includes(productTexture)) return 15;
      if (['serum', 'gel', 'watery'].includes(productTexture)) return 8;
      return 4;
    } else {
      return 10;
    }
  }
  return texture_match[texturePreference]?.[productTexture] ?? 0;
}

/**
 * Menghitung skor hasil akhir (0 - 15)
 */
export function calculateFinishScore(
  userFinishPref: string | null,
  productFinish: string,
  userSkinCode: string
): number {
  if (!userFinishPref) {
    // Default otomatis berdasarkan tipe kulit
    if (userSkinCode === 'oily' || userSkinCode === 'combination') {
      if (productFinish === 'matte') return 15;
      if (productFinish === 'natural') return 10;
      return 5;
    } else if (userSkinCode === 'dry') {
      if (productFinish === 'dewy') return 15;
      if (productFinish === 'natural') return 10;
      return 5;
    } else {
      if (productFinish === 'natural') return 15;
      return 10;
    }
  }

  if (userFinishPref === productFinish) {
    return 15;
  }

  // Semi-cocok
  if (userFinishPref === 'matte' && productFinish === 'natural') return 10;
  if (userFinishPref === 'dewy' && productFinish === 'natural') return 10;
  if (userFinishPref === 'natural' && (productFinish === 'matte' || productFinish === 'dewy')) return 10;

  return 5;
}

/**
 * Menghitung akumulasi denda / penalti (pengurangan skor) berdasarkan ketidaksesuaian rules
 */
export function calculatePenalty(userSkinCode: string, activity: string, product: any): number {
  let penalty = 0;
  if (userSkinCode === 'sensitive' && product.sunscreen_type === 'chemical') {
    penalty += 10;
  }
  if (activity === 'outdoor_intense' && !product.is_water_resistant) {
    penalty += 8;
  }
  if (activity === 'sport' && !product.is_water_resistant) {
    penalty += 8;
  }
  if (activity === 'swim' && !product.is_very_water_resistant) {
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
  return penalty;
}
