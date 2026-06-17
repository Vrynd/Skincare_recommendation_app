export interface UvDataResult {
  uvIndex: number;
  uvRiskLevel: string;
  spfMinimum: number;
  paMinimum: string;
  usageTimePref: string;
  isForecast: boolean;
  currentLocalHour: number;
  isNight: boolean;
}

export async function getUvDataAndThresholds(
  lat: number,
  lon: number,
  usageTimePrefInput?: string
): Promise<UvDataResult> {
  const openMeteoUrl = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=uv_index&forecast_days=2&timezone=auto`;
  const openMeteoRes = await fetch(openMeteoUrl);
  if (!openMeteoRes.ok) {
    throw new Error("Gagal mengambil data indeks UV dari Open-Meteo");
  }

  const openMeteoData = await openMeteoRes.json();
  const utcOffsetSeconds = openMeteoData.utc_offset_seconds || 0;
  const uvIndexArr = openMeteoData.hourly?.uv_index;
  if (!uvIndexArr || uvIndexArr.length < 48) {
    throw new Error("Format data UV Open-Meteo tidak valid");
  }

  // Calculate current local hour at coordinate
  const now = new Date();
  const localTime = new Date(now.getTime() + utcOffsetSeconds * 1000);
  const currentLocalHour = localTime.getUTCHours();
  const isNight = currentLocalHour >= 18 || currentLocalHour < 6;

  let uvIndex = 0;
  let isForecast = false;
  let usageTimePref = usageTimePrefInput || 'realtime';

  if (!isNight && usageTimePref === 'realtime') {
    uvIndex = Number(uvIndexArr[currentLocalHour] || 0);
    isForecast = false;
  } else {
    isForecast = true;
    if (usageTimePref === 'realtime') {
      usageTimePref = 'morning'; 
    }

    const tomorrowUv = uvIndexArr.slice(24, 48); // index 24 to 47
    let hourIndices: number[] = [];
    if (usageTimePref === 'morning') {
      hourIndices = [6, 7, 8, 9];
    } else if (usageTimePref === 'afternoon') {
      hourIndices = [10, 11, 12, 13];
    } else if (usageTimePref === 'evening') {
      hourIndices = [14, 15, 16, 17];
    }

    const values = hourIndices.map(h => tomorrowUv[h] || 0);
    uvIndex = Math.max(...values);
  }

  // --- SPF Minimum, PA Minimum & Risk Level ---
  let spfMinimum = 15;
  if (uvIndex <= 2) spfMinimum = 15;
  else if (uvIndex <= 5) spfMinimum = 30;
  else spfMinimum = 50;

  let paMinimum = 'PA+';
  if (uvIndex <= 2) paMinimum = 'PA+';
  else if (uvIndex <= 5) paMinimum = 'PA++';
  else if (uvIndex <= 10) paMinimum = 'PA+++';
  else paMinimum = 'PA++++';

  let uvRiskLevel = 'low';
  if (uvIndex <= 2) uvRiskLevel = 'low';
  else if (uvIndex <= 5) uvRiskLevel = 'moderate';
  else if (uvIndex <= 7) uvRiskLevel = 'high';
  else if (uvIndex <= 10) uvRiskLevel = 'very_high';
  else uvRiskLevel = 'extreme';

  return {
    uvIndex,
    uvRiskLevel,
    spfMinimum,
    paMinimum,
    usageTimePref,
    isForecast,
    currentLocalHour,
    isNight
  };
}
