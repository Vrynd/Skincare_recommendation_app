/**
 * Konstanta Pembobotan dan Parameter Operasional Rule-Based Scoring 5 Langkah (Dual-Mode)
 */

// Vektor Bobot Kriteria Master (W): Total = 1.00 (100%)
export const WEIGHTS = {
  uv: 0.25,          // C1: Proteksi UV (25%)
  skinType: 0.25,    // C2: Jenis Kulit (25%)
  activity: 0.20,    // C3: Aktivitas Harian (20%)
  skinConcern: 0.10, // C4: Masalah Kulit (10%)
  texture: 0.10,     // C5: Preferensi Tekstur (10%)
  finish: 0.10,      // C6: Hasil Akhir (10%)
};

// Jumlah Bobot Kriteria Aktif Berdasarkan Mode Rekomendasi (Dynamic Normalization)
export const ACTIVE_WEIGHT_SUM = {
  routine: 0.75, // C2(0.25) + C3(0.20) + C4(0.10) + C5(0.10) + C6(0.10)
  today: 0.90,   // C1(0.25) + C2(0.25) + C3(0.20) + C4(0.10) + C6(0.10)
};

// Target Proteksi Rutin (Penggunaan Berulang / Standar Tropis Statis)
export const TARGET_ROUTINE = {
  spf: 30,
  pa: 'PA+++',
};

// Target Proteksi Hari Ini Berdasarkan Kategori Risiko Indeks UV (Tabel 3 Metodologi)
export function getTodayTarget(uvIndex: number): { spf: number; pa: string } {
  if (uvIndex < 6) {
    // 0 <= UV < 3 (Rendah) dan 3 <= UV < 6 (Sedang)
    return { spf: 30, pa: 'PA+++' };
  } else if (uvIndex < 8) {
    // 6 <= UV < 8 (Tinggi)
    return { spf: 50, pa: 'PA+++' };
  } else {
    // UV >= 8 (Sangat Tinggi & Ekstrem)
    return { spf: 50, pa: 'PA++++' };
  }
}

// Kelompok Sediaan Tekstur Serumpun (C5)
export const TEXTURE_GROUPS: string[][] = [
  ['gel', 'serum', 'watery'],
  ['cream', 'lotion', 'milk'],
  ['spray', 'mist'],
  ['stick'],
];

// Pasangan Hasil Akhir Bertetangga pada Spektrum Kosmetik (C6)
export const FINISH_NEIGHBORS: Record<string, string[]> = {
  'matte': ['natural'],
  'natural': ['matte', 'dewy'],
  'dewy': ['natural'],
  'tone_up': [], // Tone-Up berdiri sebagai kategori tersendiri
};
