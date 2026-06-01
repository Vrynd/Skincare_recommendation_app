import 'package:flutter/foundation.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';

/// Model data immutable untuk menampung parameter Indeks UV
@immutable
class HomeUVData {
  final double uvIndex;
  final String peakTime;
  final String sunburnText;
  final String spfText;
  final DateTime lastUpdated;

  const HomeUVData({
    required this.uvIndex,
    required this.peakTime,
    required this.sunburnText,
    required this.spfText,
    required this.lastUpdated,
  });

  /// Mengambil tingkat risiko UV berdasarkan nilai indeks UV secara dinamis
  UVRiskLevel get riskLevel => UVRiskLevel.fromIndex(uvIndex);
  int get recommendedSpf => riskLevel.recommendedSpf;

  /// Membuat instansi model baru hasil respons API cuaca Open-Meteo
  factory HomeUVData.fromApi({
    required double uvIndex,
    required String peakTime,
    required String sunburnText,
    required String spfText,
  }) {
    return HomeUVData(
      uvIndex: uvIndex,
      peakTime: peakTime,
      sunburnText: sunburnText,
      spfText: spfText,
      lastUpdated: DateTime.now(),
    );
  }

  /// Membuat instansi model dari data penyimpanan cache lokal SharedPreferences
  factory HomeUVData.fromCache(Map<String, dynamic> map) {
    return HomeUVData(
      uvIndex: (map['uv_index'] as num? ?? 0.0).toDouble(),
      peakTime: map['peak_time'] as String? ?? '12:00',
      sunburnText: map['sunburn_text'] as String? ?? 'Aman',
      spfText: map['spf_text'] as String? ?? '15+ SPF',
      lastUpdated: DateTime.tryParse(map['last_updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Mengonversi objek model ke bentuk Map untuk penyimpanan terpadu
  Map<String, dynamic> toCacheMap() {
    return {
      'uv_index': uvIndex,
      'peak_time': peakTime,
      'sunburn_text': sunburnText,
      'spf_text': spfText,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  /// Memeriksa apakah data cache UV ini telah berusia lebih dari 1 jam (kedaluwarsa)
  bool get isExpired {
    final diff = DateTime.now().difference(lastUpdated);
    return diff.inHours >= 1;
  }
}
