export function isValidUuid(uuid: string): boolean {
  const pattern = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
  return pattern.test(uuid);
}

export function hasDuplicate(arr: string[]): boolean {
  return new Set(arr).size !== arr.length;
}

export function mapSkinTypeCode(codeOrName: string): string {
  const normalized = codeOrName.toLowerCase();
  if (normalized === 'st001' || normalized === 'oily' || normalized === 'berminyak') return 'oily';
  if (normalized === 'st002' || normalized === 'dry' || normalized === 'kering') return 'dry';
  if (normalized === 'st003' || normalized === 'combination' || normalized === 'kombinasi') return 'combination';
  if (normalized === 'st004' || normalized === 'normal') return 'normal';
  if (normalized === 'st005' || normalized === 'sensitive' || normalized === 'sensitif') return 'sensitive';
  return normalized;
}

export function mapConcernCode(codeOrName: string): string {
  const normalized = codeOrName.toLowerCase();
  if (normalized === 'sc001' || normalized === 'acne' || normalized === 'jerawat') return 'acne';
  if (normalized === 'sc002' || normalized === 'hyperpigmentation' || normalized.includes('hiperpigmentasi') || normalized.includes('kusam')) return 'hyperpigmentation';
  if (normalized === 'sc003' || normalized === 'sensitive_irritation' || normalized.includes('irritation') || normalized.includes('sensitif') || normalized.includes('iritasi')) return 'sensitive_irritation';
  if (normalized === 'sc004' || normalized === 'aging' || normalized.includes('penuaan')) return 'aging';
  return normalized;
}

export function paToNumber(pa: string): number {
  const normalized = pa.toUpperCase().replace(/\s+/g, '');
  if (normalized.includes('PA++++')) return 4;
  if (normalized.includes('PA+++')) return 3;
  if (normalized.includes('PA++')) return 2;
  if (normalized.includes('PA+')) return 1;
  return 0;
}

export function comparePaGrade(productPa: string, minimumPa: string): boolean {
  return paToNumber(productPa) >= paToNumber(minimumPa);
}
