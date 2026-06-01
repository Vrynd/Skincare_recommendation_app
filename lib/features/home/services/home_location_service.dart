import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeLocationService {
  static const String _keyAddress = 'cached_location_address';
  static const String _keyLat = 'cached_location_latitude';
  static const String _keyLng = 'cached_location_longitude';

  /// Membaca data lokasi yang tersimpan di cache lokal SharedPreferences
  Future<Map<String, dynamic>?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = prefs.getString(_keyAddress);
      final lat = prefs.getDouble(_keyLat);
      final lng = prefs.getDouble(_keyLng);

      if (address != null && lat != null && lng != null) {
        return {
          'address': address,
          'latitude': lat,
          'longitude': lng,
        };
      }
    } catch (_) {
      // Abaikan jika preferensi lokal gagal
    }
    return null;
  }

  /// Menyimpan data lokasi aktual ke cache lokal SharedPreferences
  Future<void> saveLocationCache({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAddress, address);
      await prefs.setDouble(_keyLat, latitude);
      await prefs.setDouble(_keyLng, longitude);
    } catch (_) {
      // Abaikan jika preferensi lokal gagal
    }
  }
  /// Memeriksa apakah GPS aktif dan meminta izin akses lokasi jika belum diberikan
  Future<bool> checkPermissionAndServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Periksa apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 2. Periksa izin lokasi saat ini
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Mengambil koordinat GPS terkini dengan tingkat akurasi rendah untuk menghemat baterai
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, // Rendah sudah cukup untuk tingkat Kota/Kecamatan & Indeks UV
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Melakukan reverse geocoding untuk menerjemahkan koordinat GPS menjadi nama daerah
  Future<String> getReadableAddress(double latitude, double longitude) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return 'Lokasi tidak terdeteksi';
      }

      final place = placemarks.first;
      final subLocality = place.subLocality?.trim() ?? '';
      final locality = place.locality?.trim() ?? '';
      final subAdminArea = place.subAdministrativeArea?.trim() ?? '';
      final country = place.country?.trim() ?? '';

      // Tentukan prioritas kombinasi nama lokasi yang valid
      final combinations = [
        [subLocality, locality],  // Prioritas 1: Kelurahan, Kecamatan
        [locality, subAdminArea], // Prioritas 2: Kecamatan, Kota
        [subAdminArea, country],  // Prioritas 3: Kota, Negara
      ];

      for (final pair in combinations) {
        if (pair[0].isNotEmpty && pair[1].isNotEmpty) {
          return '${pair[0]}, ${pair[1]}';
        }
      }

      // Fallback: Gabungkan semua bagian yang terdeteksi
      final fallbackParts = [subLocality, locality, subAdminArea, country]
          .where((part) => part.isNotEmpty);

      return fallbackParts.isNotEmpty
          ? fallbackParts.join(', ')
          : 'Lokasi tidak dikenal';
    } catch (e) {
      return 'Gagal memuat alamat';
    }
  }
}
