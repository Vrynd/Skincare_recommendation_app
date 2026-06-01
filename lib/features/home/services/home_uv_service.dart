import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recommendation_app/features/home/models/home_uv_data.dart';

class HomeUVService {
  /// Mengambil data indeks UV dari Open-Meteo untuk koordinat tertentu
  Future<HomeUVData?> fetchUVData(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&hourly=uv_index'
      '&timezone=auto'
    );

    try {
      debugPrint('Open-Meteo GET: $url');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hourly = data['hourly'];
        if (hourly == null) return null;

        final times = hourly['time'] as List<dynamic>;
        final uvIndexes = hourly['uv_index'] as List<dynamic>;

        final now = DateTime.now();
        final todayPrefix = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        final nowLocalHourPrefix = "${todayPrefix}T${now.hour.toString().padLeft(2, '0')}";

        // 1. Mencari indeks UV riil untuk jam saat ini
        int currentIndex = -1;
        for (int i = 0; i < times.length; i++) {
          if (times[i].toString().startsWith(nowLocalHourPrefix)) {
            currentIndex = i;
            break;
          }
        }

        double currentUv = 0.0;
        if (currentIndex != -1 && currentIndex < uvIndexes.length) {
          currentUv = (uvIndexes[currentIndex] as num).toDouble();
        } else {
          // Fallback jika pencarian jam tepat gagal, ambil jam pertama hari ini
          currentUv = _getFallbackCurrentUV(times, uvIndexes, todayPrefix);
        }

        // 2. Mencari Jam Puncak UV (Peak Hour) hari ini
        double maxUvToday = 0.0;
        String peakTime = '12:00';

        for (int i = 0; i < times.length; i++) {
          final timeStr = times[i].toString();
          if (timeStr.startsWith(todayPrefix)) {
            final uvVal = (uvIndexes[i] as num).toDouble();
            if (uvVal > maxUvToday) {
              maxUvToday = uvVal;
              final parts = timeStr.split('T');
              if (parts.length == 2) {
                peakTime = parts[1];
              }
            }
          }
        }

        // 3. Menghitung Batas Sunburn (Kulit Terbakar) berdasarkan formula ilmiah WHO
        final sunburnMinutes = _calculateSunburnMinutes(currentUv);
        final sunburnText = currentUv < 0.5 ? 'Aman' : '$sunburnMinutes Menit';

        // 4. Menentukan Rekomendasi Proteksi SPF sesuai standar medis
        final spfText = _recommendSPF(currentUv);

        return HomeUVData.fromApi(
          uvIndex: currentUv,
          peakTime: peakTime,
          sunburnText: sunburnText,
          spfText: spfText,
        );
      } else {
        debugPrint('Open-Meteo error status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Open-Meteo request failed: $e');
    }
    return null;
  }

  /// Menghitung durasi menit sunburn menggunakan standar referensi (160 / UV Index)
  int _calculateSunburnMinutes(double uvIndex) {
    if (uvIndex <= 0) return 360; // 6 Jam (Aman)
    // Formula standard referensi: 160 / uv_index
    return (160 / uvIndex).round();
  }

  /// Rekomendasi SPF medis berdasarkan nilai indeks UV saat ini
  String _recommendSPF(double uvIndex) {
    if (uvIndex <= 2.0) return '15+ SPF'; // Rendah
    if (uvIndex <= 5.0) return '15+ SPF'; // Sedang
    if (uvIndex <= 7.0) return '30+ SPF'; // Tinggi
    if (uvIndex <= 10.0) return '30+ SPF'; // Sangat Tinggi
    return '50+ SPF'; // Ekstrem
  }

  /// Fallback mengambil jam terdekat hari ini jika pencarian jam tepat terlewat
  double _getFallbackCurrentUV(List<dynamic> times, List<dynamic> uvIndexes, String todayPrefix) {
    for (int i = 0; i < times.length; i++) {
      if (times[i].toString().startsWith(todayPrefix)) {
        return (uvIndexes[i] as num).toDouble();
      }
    }
    return 0.0;
  }
}
