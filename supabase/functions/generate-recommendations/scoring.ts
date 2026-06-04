function getPaScore(pa: string | null | undefined): number {
  if (!pa) return 0;
  const clean = pa.toUpperCase();
  if (clean.includes('++++')) return 4;
  if (clean.includes('+++')) return 3;
  if (clean.includes('++')) return 2;
  if (clean.includes('+')) return 1;
  return 0;
}

function parseSpfValue(spf: string | null | undefined): number {
  if (!spf) return 0;
  const num = parseInt(spf.replace(/[^0-9]/g, ''), 10);
  return isNaN(num) ? 0 : num;
}

function mapUsageTimeValue(val: string | null | undefined): string {
  if (!val) return 'Pagi & Malam';
  const clean = val.toLowerCase();
  if (clean === 'morning_day' || clean === 'pagi' || clean.includes('pagi hari')) return 'Pagi';
  if (clean === 'night' || clean === 'malam' || clean.includes('malam hari')) return 'Malam';
  return 'Pagi & Malam';
}

// ─────────────────────────────────────────────────────────────
// S1 — Jenis kulit (bobot 30%)
// Biner: 100 jika cocok, 0 jika tidak
// ─────────────────────────────────────────────────────────────
export function calculateS1(product: any, skin_type_id: string): number {
  const productSkinTypeIds = product.product_skin_types?.map((st: any) => st.skin_type_id) ?? [];

  if (productSkinTypeIds.includes(skin_type_id)) {
    return 100;
  }
  return 0;
}

// ─────────────────────────────────────────────────────────────
// S2 — Masalah kulit (bobot 35%)
// Rata-rata sederhana semua masalah yang dipilih
// ─────────────────────────────────────────────────────────────
export function calculateS2(product: any, selectedConcernIds: string[]): number {
  if (!selectedConcernIds || selectedConcernIds.length === 0) {
    return 0;
  }

  let totalSkor = 0;
  const jumlahMasalah = selectedConcernIds.length;

  for (const concernId of selectedConcernIds) {
    // Cek apakah produk mengatasi masalah ini
    const hasConcern = product.product_skin_concerns?.some(
      (c: any) => c.skin_concern_id === concernId
    );

    const skorMasalah = hasConcern ? 100 : 0;
    totalSkor += skorMasalah;
  }

  const s2 = totalSkor / jumlahMasalah;
  return parseFloat(s2.toFixed(2));
}

// ─────────────────────────────────────────────────────────────
// S3 — Indeks UV (bobot 20% atau 25% jika bobot dinamis)
// Berbeda untuk sunscreen dan non-sunscreen
// ─────────────────────────────────────────────────────────────
export function calculateS3(product: any, uvIndex: number): number {
  const category = product.category ? product.category.toLowerCase() : '';

  if (category === 'sunscreen') {
    const spf = parseSpfValue(product.spf_value);
    const paGrade = product.pa_grade;
    return calculateS3Sunscreen(spf, paGrade, uvIndex);
  } else {
    return calculateS3NonSunscreen(uvIndex);
  }
}

function calculateS3Sunscreen(spfValue: number, paGrade: string | null | undefined, uvIndex: number): number {
  const paScore = getPaScore(paGrade);

  // UV Rendah (0–2)
  if (uvIndex >= 0 && uvIndex <= 2) {
    if (spfValue >= 15) return 100;
    return 60;
  }

  // UV Sedang (3–5)
  if (uvIndex >= 3 && uvIndex <= 5) {
    if (spfValue >= 30) return 100;
    if (spfValue >= 15) return 60;
    return 20;
  }

  // UV Tinggi (6–7)
  if (uvIndex >= 6 && uvIndex <= 7) {
    if (spfValue >= 50) return 100;
    if (spfValue >= 30) return 60;
    return 20;
  }

  // UV Sangat Tinggi (8–10)
  if (uvIndex >= 8 && uvIndex <= 10) {
    if (spfValue >= 50 && paScore >= 3) return 100; // PA+++ or PA++++
    if (spfValue >= 50 && paScore < 3) return 60;
    if (spfValue >= 30) return 30;
    return 10;
  }

  // UV Ekstrem (11+)
  if (uvIndex >= 11) {
    if (spfValue >= 50 && paScore === 4) return 100; // PA++++
    if (spfValue >= 50 && paScore === 3) return 60; // PA+++
    return 20;
  }

  return 0;
}

function calculateS3NonSunscreen(uvIndex: number): number {
  if (uvIndex >= 0 && uvIndex <= 2) return 100;
  if (uvIndex >= 3 && uvIndex <= 5) return 80;
  if (uvIndex >= 6 && uvIndex <= 7) return 60;
  if (uvIndex >= 8 && uvIndex <= 10) return 40;
  return 20; // 11+
}

// ─────────────────────────────────────────────────────────────
// S4 — Waktu pakai (bobot 15%)
// Semi-biner: 100 / 70 / 0
// ─────────────────────────────────────────────────────────────
export function calculateS4(product: any, usageTimePengguna: string): number {
  const usageTimeProdukMapped = mapUsageTimeValue(product.usage_time);
  const usageTimePenggunaMapped = mapUsageTimeValue(usageTimePengguna);

  if (usageTimePenggunaMapped === 'Pagi') {
    if (['Pagi', 'Pagi & Malam'].includes(usageTimeProdukMapped)) {
      return 100;
    }
    return 0;
  }

  if (usageTimePenggunaMapped === 'Malam') {
    if (['Malam', 'Pagi & Malam'].includes(usageTimeProdukMapped)) {
      return 100;
    }
    return 0;
  }

  if (usageTimePenggunaMapped === 'Pagi & Malam') {
    if (usageTimeProdukMapped === 'Pagi & Malam') {
      return 100;
    }
    if (['Pagi', 'Malam'].includes(usageTimeProdukMapped)) {
      return 70;
    }
    return 0;
  }

  return 0;
}
