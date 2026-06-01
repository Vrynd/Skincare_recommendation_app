import 'package:shared_preferences/shared_preferences.dart';
import 'package:recommendation_app/features/home/models/home_location_data.dart';
import 'package:recommendation_app/features/home/models/home_uv_data.dart';

/// Layanan penyimpanan lokal tersentralisasi khusus untuk fitur Home.
/// Mengelola persistensi data lokasi GPS dan Indeks UV di SharedPreferences secara type-safe.
class HomeStorageService {
  static const String _keyAddress = 'cached_location_address';
  static const String _keyLat = 'cached_location_latitude';
  static const String _keyLng = 'cached_location_longitude';

  static const String _keyUvIndex = 'cached_uv_index';
  static const String _keyUvPeakTime = 'cached_uv_peak_time';
  static const String _keyUvSunburn = 'cached_uv_sunburn';
  static const String _keyUvSpf = 'cached_uv_spf';
  static const String _keyUvTimestamp = 'cached_uv_timestamp';

  /// Membaca data lokasi ter-cache secara aman dalam bentuk objek HomeLocationData
  Future<HomeLocationData?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = prefs.getString(_keyAddress);
      final lat = prefs.getDouble(_keyLat);
      final lng = prefs.getDouble(_keyLng);

      if (address != null && lat != null && lng != null) {
        return HomeLocationData(
          address: address,
          latitude: lat,
          longitude: lng,
        );
      }
    } catch (_) {
      // Menghindari kegagalan runtime jika SharedPreferences korup
    }
    return null;
  }

  /// Menyimpan data lokasi aktual ke penyimpanan lokal
  Future<void> saveLocationCache(HomeLocationData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAddress, data.address);
      await prefs.setDouble(_keyLat, data.latitude);
      await prefs.setDouble(_keyLng, data.longitude);
    } catch (_) {
      // Menghindari kegagalan runtime jika penyimpanan gagal ditulis
    }
  }

  /// Membaca data Indeks UV ter-cache secara aman dalam bentuk objek HomeUVData
  Future<HomeUVData?> getCachedUV() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uv = prefs.getDouble(_keyUvIndex);
      final peakTime = prefs.getString(_keyUvPeakTime);
      final sunburn = prefs.getString(_keyUvSunburn);
      final spf = prefs.getString(_keyUvSpf);
      final timestamp = prefs.getString(_keyUvTimestamp);

      if (uv != null && peakTime != null && sunburn != null && spf != null && timestamp != null) {
        return HomeUVData(
          uvIndex: uv,
          peakTime: peakTime,
          sunburnText: sunburn,
          spfText: spf,
          lastUpdated: DateTime.tryParse(timestamp) ?? DateTime.now(),
        );
      }
    } catch (_) {
      // Menghindari kegagalan runtime jika SharedPreferences korup
    }
    return null;
  }

  /// Menyimpan data Indeks UV aktual ke penyimpanan lokal
  Future<void> saveUVCache(HomeUVData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyUvIndex, data.uvIndex);
      await prefs.setString(_keyUvPeakTime, data.peakTime);
      await prefs.setString(_keyUvSunburn, data.sunburnText);
      await prefs.setString(_keyUvSpf, data.spfText);
      await prefs.setString(_keyUvTimestamp, data.lastUpdated.toIso8601String());
    } catch (_) {
      // Menghindari kegagalan runtime jika penyimpanan gagal ditulis
    }
  }
}
