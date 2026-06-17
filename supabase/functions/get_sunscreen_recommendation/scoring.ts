import { similarity, texture_match } from "./constants.ts";
import { paToNumber } from "./utils.ts";

/**
 * Memvalidasi apakah suatu produk melanggar riwayat alergi atau filter keamanan otomatis
 */
export function isAllergyOrSafetyBlocked(
  userSkinCode: string,
  userConcernCodes: string[],
  allergyStatus: string,
  avoidedIngredientIds: string[],
  productIngredientCodes: string[],
  productIngredientIds: string[],
  autoAvoidIds: string[]
): boolean {
  // A. Safety Auto-Filter berdasarkan Tipe Kulit dan Masalah Kulit
  const isSensitiveCondition = userSkinCode === 'sensitive' || userConcernCodes.includes('sensitive_irritation');
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
 * Menghitung skor tipe kulit berdasarkan kecocokan matriks similarity (0 - 30)
 */
export function calculateSkinTypeScore(userSkinCode: string, productSkinCodes: string[]): number {
  let maxSkinTypeScore = 0;
  for (const pSkinCode of productSkinCodes) {
    const lookupScore = similarity[userSkinCode]?.[pSkinCode] ?? 0;
    if (lookupScore > maxSkinTypeScore) {
      maxSkinTypeScore = lookupScore;
    }
  }
  return maxSkinTypeScore;
}

/**
 * Menghitung skor masalah kulit tertentu untuk suatu produk (0 - 30)
 */
export function calculateSingleConcernScore(concernCode: string, product: any, productIngredientCodes: string[]): number {
  if (concernCode === 'acne') {
    if (product.is_non_comedogenic && product.is_oil_free) return 30;
    if (product.is_non_comedogenic) return 20;
    if (product.is_oil_free) return 15;
    return 0;
  }
  
  if (concernCode === 'hyperpigmentation') {
    const hasBrightening = productIngredientCodes.includes('niacinamide') || productIngredientCodes.includes('vitamin_c');
    const paVal = paToNumber(product.pa_grade);
    if (paVal >= 4 && hasBrightening) return 30;
    if (paVal >= 3 && hasBrightening) return 25;
    if (paVal >= 4) return 20;
    if (paVal >= 3) return 15;
    return 0;
  }
  
  if (concernCode === 'sensitive_irritation') {
    const isPhys = product.sunscreen_type === 'physical';
    const isHyb = product.sunscreen_type === 'hybrid';
    const fragFree = !productIngredientCodes.includes('fragrance');
    const alcFree = !productIngredientCodes.includes('alcohol_denat') && !productIngredientCodes.includes('ethanol');
    const eoFree = !productIngredientCodes.includes('essential_oil');

    if (isPhys && fragFree && alcFree && eoFree) return 30;
    if (isPhys && fragFree && alcFree) return 25;
    if (isPhys) return 20;
    if (isHyb && fragFree && alcFree) return 15;
    return 0;
  }
  
  if (concernCode === 'aging') {
    const hasAnti = productIngredientCodes.includes('vitamin_c') || productIngredientCodes.includes('peptide') || productIngredientCodes.includes('tocopherol');
    const paVal = paToNumber(product.pa_grade);
    if (paVal >= 4 && hasAnti) return 30;
    if (paVal >= 4) return 20;
    if (paVal >= 3 && hasAnti) return 15;
    if (paVal >= 3) return 10;
    return 0;
  }

  return 0;
}

/**
 * Menghitung skor rata-rata masalah kulit (0 - 30)
 */
export function calculateAvgConcernScore(userConcernCodes: string[], product: any, productIngredientCodes: string[]): number {
  const concernScores: number[] = [];
  for (const concernCode of userConcernCodes) {
    concernScores.push(calculateSingleConcernScore(concernCode, product, productIngredientCodes));
  }
  return concernScores.length > 0
    ? Math.ceil(concernScores.reduce((a, b) => a + b, 0) / concernScores.length)
    : 0;
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
export function calculateTextureScore(texturePreference: string | null, productTexture: string): number {
  if (!texturePreference) return 10;
  return texture_match[texturePreference]?.[productTexture] ?? 0;
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
