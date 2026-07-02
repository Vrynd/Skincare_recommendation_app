import { isValidUuid, hasDuplicate } from "./utils.ts";

export interface ValidationResult {
  error?: string;
}

export function validateRequestBody(body: any): ValidationResult {
  // --- General Field Validations ---
  if (!body.user_id || !isValidUuid(body.user_id)) {
    return { error: "user_id wajib diisi dengan format UUID yang valid" };
  }

  if (!body.skin_type_id || !isValidUuid(body.skin_type_id)) {
    return { error: "skin_type_id wajib diisi dengan format UUID yang valid" };
  }

  if (body.skin_concern_ids) {
    if (!Array.isArray(body.skin_concern_ids)) {
      return { error: "Format skin_concern_ids harus berupa array" };
    }
    if (body.skin_concern_ids.length > 2) {
      return { error: "Maksimal masalah kulit yang dipilih adalah 2 kategori" };
    }
    if (hasDuplicate(body.skin_concern_ids)) {
      return { error: "Masalah kulit tidak boleh duplikat" };
    }
    for (const id of body.skin_concern_ids) {
      if (!isValidUuid(id)) {
        return { error: "Format skin_concern_id tidak valid" };
      }
    }
  }

  const validActivities = ['indoor', 'outdoor_light', 'outdoor_intense', 'sport', 'swim'];
  if (!body.activity || !validActivities.includes(body.activity)) {
    return { error: `Aktivitas harian wajib dipilih dan harus berupa salah satu dari: ${validActivities.join(', ')}` };
  }

  const validTextures = ['gel', 'cream', 'lotion', 'serum', 'milk', 'watery', 'stick', 'spray', 'mist'];
  if (body.texture_preference && !validTextures.includes(body.texture_preference)) {
    return { error: "Nilai preferensi tekstur tidak valid" };
  }

  const validFinishes = ['matte', 'dewy', 'natural', 'tone_up'];
  if (body.finish_preference && !validFinishes.includes(body.finish_preference)) {
    return { error: "Nilai preferensi hasil akhir tidak valid" };
  }

  const validAllergyStatuses = ['none', 'unknown_ingredient', 'known_ingredient'];
  if (!body.allergy_status || !validAllergyStatuses.includes(body.allergy_status)) {
    return { error: `Status alergi wajib diisi dan harus berupa salah satu dari: ${validAllergyStatuses.join(', ')}` };
  }

  if (body.allergy_status === 'known_ingredient' && (!body.avoided_ingredient_ids || !Array.isArray(body.avoided_ingredient_ids) || body.avoided_ingredient_ids.length === 0)) {
    return { error: "Bahan yang dihindari wajib dipilih jika status alergi diketahui" };
  }

  if (body.avoided_ingredient_ids && Array.isArray(body.avoided_ingredient_ids)) {
    if (hasDuplicate(body.avoided_ingredient_ids)) {
      return { error: "Bahan yang dihindari tidak boleh duplikat" };
    }

    for (const id of body.avoided_ingredient_ids) {
      if (!isValidUuid(id)) {
        return { error: "Format avoided_ingredient_id tidak valid" };
      }
    }
  }

  if (body.latitude === undefined || body.latitude === null || body.longitude === undefined || body.longitude === null) {
    return { error: "Lokasi (latitude & longitude) tidak dapat diakses atau kosong" };
  }

  const lat = Number(body.latitude);
  const lon = Number(body.longitude);

  if (isNaN(lat) || lat < -90 || lat > 90) {
    return { error: "Latitude tidak valid (harus antara -90 dan 90)" };
  }

  if (isNaN(lon) || lon < -180 || lon > 180) {
    return { error: "Longitude tidak valid (harus antara -180 dan 180)" };
  }

  return {};
}

export function validateUsageTimePreference(usageTimePref: any, isNight: boolean): ValidationResult {
  if (isNight) {
    if (!usageTimePref) {
      return { error: "Waktu penggunaan sunscreen wajib dipilih saat malam hari" };
    }

    if (!['morning', 'afternoon', 'evening'].includes(usageTimePref)) {
      return { error: "Waktu penggunaan sunscreen malam hari tidak valid (harus morning, afternoon, atau evening)" };
    }
  } else {
    if (usageTimePref && !['realtime', 'morning', 'afternoon', 'evening'].includes(usageTimePref)) {
      return { error: "Waktu penggunaan sunscreen tidak valid" };
    }
  }
  return {};
}
