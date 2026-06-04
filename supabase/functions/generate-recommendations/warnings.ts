import { ScoredProduct } from "./formula.ts";

export function generateWarnings(
  uvIndex: number,
  uvCategory: string,
  allergyStatus: string,
  rankedResults: ScoredProduct[]
): string[] {
  const warnings: string[] = [];

  // Normalize allergy status to match 'unknown'
  const normalizedAllergyStatus =
    allergyStatus === 'unknown' || allergyStatus === 'unknown_ingredient' ? 'unknown' : allergyStatus;

  // Cek apakah ada sunscreen di hasil
  const hasSunscreen = rankedResults.some(
    r => r.product.category?.toLowerCase() === 'sunscreen'
  );

  // Peringatan UV tinggi tanpa sunscreen (UV >= 6)
  if (uvIndex >= 6 && !hasSunscreen) {
    warnings.push(
      "Tidak ditemukan sunscreen yang sesuai kondisi " +
      "kamu saat ini. Pertimbangkan tetap menggunakan " +
      "sunscreen SPF 50+ PA+++."
    );
  }

  // Peringatan wajib sunscreen saat UV tinggi
  if (uvIndex >= 6 && hasSunscreen) {
    warnings.push(
      "UV " + uvCategory + " — wajib gunakan sunscreen " +
      "SPF 50+ PA+++ sebelum beraktivitas di luar ruangan."
    );
  }

  // Peringatan patch test untuk allergy_status unknown
  if (normalizedAllergyStatus === 'unknown') {
    warnings.push(
      "Kamu memiliki riwayat alergi skincare. " +
      "Lakukan patch test 24 jam sebelum menggunakan " +
      "produk baru untuk menghindari reaksi yang " +
      "tidak diinginkan."
    );
  }

  return warnings;
}
