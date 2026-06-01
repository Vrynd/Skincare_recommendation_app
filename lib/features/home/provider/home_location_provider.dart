import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:recommendation_app/features/home/models/home_location_data.dart';
import 'package:recommendation_app/features/home/models/home_uv_data.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';
import 'package:recommendation_app/features/home/services/home_location_service.dart';
import 'package:recommendation_app/features/home/services/home_storage_service.dart';
import 'package:recommendation_app/features/home/services/home_uv_service.dart';

class HomeLocationProvider extends ChangeNotifier {
  final HomeLocationService _locationService = HomeLocationService();
  final HomeUVService _uvService = HomeUVService();
  final HomeStorageService _storageService = HomeStorageService();

  Position? _currentPosition;
  String _readableAddress = 'Mencari lokasi...';
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermissions = false;

  // State Indeks UV Riil dari Open-Meteo
  double _uvIndex = 6.0;
  String _peakTimeRange = '11:00 - 13:00';
  String _uvDurationText = '2.5 Jam';
  String _spfText = '15+ SPF';
  bool _isUvLoading = false;

  // Getters Lokasi
  Position? get currentPosition => _currentPosition;
  String get readableAddress => _readableAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPermissions => _hasPermissions;

  // Getters Indeks UV
  double get uvIndex => _uvIndex;
  String get peakTimeRange => _peakTimeRange;
  String get uvDurationText => _uvDurationText;
  String get spfText => _spfText;
  bool get isUvLoading => _isUvLoading;
  UVRiskLevel get uvRiskLevel => UVRiskLevel.fromIndex(_uvIndex);

  /// Memulai pendeteksian lokasi GPS secara realtime dengan mekanisme Caching Stale-While-Revalidate (SWR)
  Future<void> fetchLocation() async {
    _errorMessage = null;

    // 1. Ambil lokasi ter-cache dari penyimpanan lokal terlebih dahulu untuk render instan
    final HomeLocationData? cached = await _storageService.getCachedLocation();
    final HomeUVData? cachedUv = await _storageService.getCachedUV();

    if (cached != null) {
      _readableAddress = cached.address;
      _currentPosition = Position(
        latitude: cached.latitude,
        longitude: cached.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Muat data UV dari cache lokal jika ada
      if (cachedUv != null) {
        _uvIndex = cachedUv.uvIndex;
        _peakTimeRange = cachedUv.peakTime;
        _uvDurationText = cachedUv.sunburnText;
        _spfText = cachedUv.spfText;
      }

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
            _errorMessage =
                'Layanan lokasi (GPS) dinonaktifkan pada perangkat Anda.';
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
        newAddress =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _errorMessage = 'Geocoding gagal: ${geocodingError.toString()}';
      }

      // 3. Bandingkan dengan data cache saat ini
      final hasChanged =
          cached == null ||
          cached.address != newAddress ||
          cached.latitude != position.latitude ||
          cached.longitude != position.longitude;

      if (hasChanged) {
        _currentPosition = position;
        _readableAddress = newAddress;

        // Simpan pembaruan lokasi ke cache lokal SharedPreferences
        await _storageService.saveLocationCache(
          HomeLocationData(
            address: newAddress,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      }

      // 4. Integrasi Penjemputan Data Indeks UV API cuaca Open-Meteo
      final shouldFetchUv = cachedUv == null || cachedUv.isExpired;
      if (shouldFetchUv || hasChanged) {
        _isUvLoading = true;
        notifyListeners();

        final uvData = await _uvService.fetchUVData(
          position.latitude,
          position.longitude,
        );
        if (uvData != null) {
          _uvIndex = uvData.uvIndex;
          _peakTimeRange = uvData.peakTime;
          _uvDurationText = uvData.sunburnText;
          _spfText = uvData.spfText;

          // Simpan pembaruan data UV ke cache lokal SharedPreferences
          await _storageService.saveUVCache(uvData);
        }
        _isUvLoading = false;
      }
    } catch (e) {
      debugPrint('GPS fetchLocation error: $e');
      _errorMessage = 'Gagal mengakses GPS: ${e.toString()}';
      if (cached == null) {
        _readableAddress = 'Gagal memuat lokasi';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
