import 'package:flutter/foundation.dart';

/// Model data immutable untuk menampung parameter Lokasi GPS
@immutable
class HomeLocationData {
  final String address;
  final double latitude;
  final double longitude;

  const HomeLocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  /// Membuat instansi model dari data penyimpanan cache lokal SharedPreferences
  factory HomeLocationData.fromCache(Map<String, dynamic> map) {
    return HomeLocationData(
      address: map['address'] as String? ?? 'Lokasi tidak dikenal',
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
    );
  }

  /// Mengonversi objek model ke bentuk Map ntuk penyimpanan terpadu
  Map<String, dynamic> toCacheMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
