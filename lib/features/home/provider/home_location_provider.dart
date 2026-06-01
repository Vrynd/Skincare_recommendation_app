import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:recommendation_app/features/home/services/home_location_service.dart';

class HomeLocationProvider extends ChangeNotifier {
  final HomeLocationService _locationService = HomeLocationService();

  Position? _currentPosition;
  String _readableAddress = 'Mencari lokasi...';
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermissions = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  String get readableAddress => _readableAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPermissions => _hasPermissions;

  /// Memulai pendeteksian lokasi GPS secara realtime dengan mekanisme Caching Stale-While-Revalidate (SWR)
  Future<void> fetchLocation() async {
    _errorMessage = null;

    // 1. Ambil lokasi ter-cache dari penyimpanan lokal terlebih dahulu untuk render instan
    final cached = await _locationService.getCachedLocation();
    if (cached != null) {
      _readableAddress = cached['address'] as String;
      final lat = cached['latitude'] as double;
      final lng = cached['longitude'] as double;
      _currentPosition = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      _isLoading = false;
      notifyListeners(); // Render instan tanpa transisi loading yang lambat!
    } else {
      // Jika belum ada cache sama sekali, tampilkan loading spinner di UI
      _isLoading = true;
      _readableAddress = 'Mencari lokasi...';
      notifyListeners();
    }

    // 2. Lakukan validasi senyap (Silent Revalidation) di latar belakang
    try {
      final hasAccess = await _locationService.checkPermissionAndServices();
      _hasPermissions = hasAccess;

      if (!hasAccess) {
        // Tampilkan error hanya jika tidak ada data cache cadangan
        if (cached == null) {
          final serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            _readableAddress = 'Aktifkan GPS Perangkat';
            _errorMessage = 'Layanan lokasi (GPS) dinonaktifkan pada perangkat Anda.';
          } else {
            _readableAddress = 'Izin Lokasi Ditolak';
            _errorMessage = 'Izin akses lokasi ditolak oleh pengguna.';
          }
          _isLoading = false;
          notifyListeners();
        }
        return;
      }

      // Ambil koordinat GPS terkini
      final position = await _locationService.getCurrentLocation();

      // Terjemahkan koordinat menjadi alamat ramah pengguna
      String newAddress;
      try {
        newAddress = await _locationService.getReadableAddress(
          position.latitude,
          position.longitude,
        );
      } catch (geocodingError) {
        debugPrint('Geocoding error fallback to coordinates: $geocodingError');
        newAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _errorMessage = 'Geocoding gagal: ${geocodingError.toString()}';
      }

      // 3. Bandingkan dengan data cache saat ini
      final hasChanged = cached == null ||
          cached['address'] != newAddress ||
          cached['latitude'] != position.latitude ||
          cached['longitude'] != position.longitude;

      if (hasChanged) {
        _currentPosition = position;
        _readableAddress = newAddress;

        // Simpan pembaruan lokasi ke cache lokal SharedPreferences
        await _locationService.saveLocationCache(
          address: newAddress,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      debugPrint('GPS fetchLocation error: $e');
      _errorMessage = 'Gagal mengakses GPS: ${e.toString()}';
      // Tampilkan error hanya jika tidak ada cache yang bisa dijadikan fallback penyelamat
      if (cached == null) {
        _readableAddress = 'Gagal memuat lokasi';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
