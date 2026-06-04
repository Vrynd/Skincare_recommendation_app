export function generateAvoidedInfo(
  skinTypeCode: string,
  concernCodes: string[]
): string[] {
  const avoidedList: string[] = [];

  // Normalize inputs to lowercase
  const typeCode = skinTypeCode.toLowerCase();
  const normalizedConcerns = concernCodes.map(c => c.toLowerCase());

  // ── Aturan berdasarkan jenis kulit ──────────────────────
  if (['oily', 'combination'].includes(typeCode)) {
    avoidedList.push('Coconut Oil', 'Isopropyl Myristate', 'Lanolin');
  }

  // ── Aturan berdasarkan masalah kulit ────────────────────
  if (normalizedConcerns.includes('acne')) {
    avoidedList.push('Heavy Silicone', 'Algae Extract', 'Sodium Lauryl Sulfate');
  }

  if (normalizedConcerns.includes('blackhead')) {
    avoidedList.push('Petroleum Berat', 'Shea Butter (konsentrasi tinggi)');
  }

  if (normalizedConcerns.includes('irritation')) {
    avoidedList.push('Fragrance / Parfum', 'Alkohol Denat', 'Menthol', 'Essential Oil');
  }

  if (normalizedConcerns.includes('dehydration')) {
    avoidedList.push('Alkohol Denat', 'Astringen Kuat');
  }

  if (normalizedConcerns.includes('large_pores')) {
    avoidedList.push('Heavy Oil', 'Thick Emollient');
  }

  if (typeCode === 'sensitive') {
    avoidedList.push('Fragrance / Parfum', 'SLS / SLES', 'Alkohol Denat', 'Essential Oil', 'Menthol');
  }

  // ── Catatan khusus flek & kerutan ───────────────────────
  if (normalizedConcerns.includes('dark_spot') || normalizedConcerns.includes('wrinkle')) {
    avoidedList.push(
      "Catatan: Selalu gunakan sunscreen setiap pagi untuk mencegah flek hitam dan kerutan memburuk akibat paparan UV."
    );
  }

  // Hapus duplikat secara case-sensitive atau case-insensitive? Case-sensitive is fine.
  const uniqueList = Array.from(new Set(avoidedList));

  return uniqueList;
}
