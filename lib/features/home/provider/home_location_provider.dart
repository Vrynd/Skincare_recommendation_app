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

  /// Memulai pendeteksian lokasi GPS secara realtime
  Future<void> fetchLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Periksa izin dan status GPS
      final hasAccess = await _locationService.checkPermissionAndServices();
      _hasPermissions = hasAccess;

      if (!hasAccess) {
        // Tentukan jenis kendala untuk feedback UI
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _readableAddress = 'Aktifkan GPS Perangkat';
          _errorMessage =
              'Layanan lokasi (GPS) dinonaktifkan pada perangkat Anda.';
        } else {
          _readableAddress = 'Izin Lokasi Ditolak';
          _errorMessage = 'Izin akses lokasi ditolak oleh pengguna.';
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Ambil koordinat posisi GPS
      final position = await _locationService.getCurrentLocation();
      _currentPosition = position;

      // 3. Lakukan reverse-geocoding untuk alamat ramah pengguna
      try {
        final address = await _locationService.getReadableAddress(
          position.latitude,
          position.longitude,
        );
        _readableAddress = address;
      } catch (geocodingError) {
        debugPrint('Geocoding error fallback to coordinates: $geocodingError');
        _readableAddress =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _errorMessage = 'Geocoding gagal: ${geocodingError.toString()}';
      }
    } catch (e) {
      debugPrint('GPS fetchLocation error: $e');
      _errorMessage = 'Gagal mengakses GPS: ${e.toString()}';
      _readableAddress = 'Gagal memuat lokasi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
