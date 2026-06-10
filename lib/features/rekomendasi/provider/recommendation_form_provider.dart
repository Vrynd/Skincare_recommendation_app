import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';

class RecommendationFormProvider extends ChangeNotifier {
  SkinTypeModel? _selectedSkinType;
  List<SkinConcernModel> _selectedSkinProblems = [];
  String? _selectedActivity;
  String? _selectedTexture;
  String? _selectedUsageTime;
  bool _isConfirmed = false;

  // State Otomatis Lokasi & UV (bagian dari payload formulir)
  String? _locationName;
  double? _latitude;
  double? _longitude;
  double? _uvIndex;
  String? _uvRiskLevel;

  SkinTypeModel? get selectedSkinType => _selectedSkinType;
  List<SkinConcernModel> get selectedSkinProblems => _selectedSkinProblems;
  String? get selectedActivity => _selectedActivity;
  String? get selectedTexture => _selectedTexture;
  String? get selectedUsageTime => _selectedUsageTime;
  bool get isConfirmed => _isConfirmed;

  // Getters Lokasi & UV
  String? get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  double? get uvIndex => _uvIndex;
  String? get uvRiskLevel => _uvRiskLevel;

  /// Memeriksa apakah waktu saat ini adalah malam hari (jam lokal perangkat >= 18 atau < 6)
  bool get isNight {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour < 6;
  }

  /// Mengatur pilihan tipe kulit
  void setSelectedSkinType(SkinTypeModel? value) {
    _selectedSkinType = value;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan masalah-masalah kulit (multi-selection)
  void setSelectedSkinProblems(List<SkinConcernModel> values) {
    _selectedSkinProblems = values;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan aktivitas harian
  void setSelectedActivity(String? value) {
    _selectedActivity = value;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan preferensi tekstur
  void setSelectedTexture(String? value) {
    _selectedTexture = value;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan waktu penggunaan skincare
  void setSelectedUsageTime(String? value) {
    _selectedUsageTime = value;
    _isConfirmed = false;
    notifyListeners();
  }

  // Logika alergi ditiadakan di UI karena sudah di-handle otomatis oleh Safety Auto-Filter di backend

  /// Mengubah status konfirmasi data formulir
  void setIsConfirmed(bool value) {
    _isConfirmed = value;
    notifyListeners();
  }

  /// Menyalin dan memetakan data lokasi dan UV dari HomeLocationProvider ke dalam state formulir
  void updateLocationAndUv(HomeLocationProvider locationProvider) {
    final position = locationProvider.currentPosition;
    final address = locationProvider.readableAddress;

    // Set ke null jika statusnya masih berupa placeholder pencarian awal atau gagal
    final isSearching =
        address == 'Mencari lokasi...' || address == 'Gagal memuat lokasi';
    _locationName = isSearching ? null : address;

    _latitude = position?.latitude;
    _longitude = position?.longitude;
    _uvIndex = locationProvider.uvIndex;

    // Memetakan tingkat risiko UV dari enum model ke string enum database
    _uvRiskLevel = switch (locationProvider.uvRiskLevel) {
      UVRiskLevel.low => 'low',
      UVRiskLevel.moderate => 'moderate',
      UVRiskLevel.high => 'high',
      UVRiskLevel.veryHigh => 'very_high',
      UVRiskLevel.extreme => 'extreme',
    };

    notifyListeners();
  }

  /// Melakukan pembersihan/reset seluruh data pilihan pada formulir ke kondisi semula
  void resetForm() {
    _selectedSkinType = null;
    _selectedSkinProblems = [];
    _selectedActivity = null;
    _selectedTexture = null;
    _selectedUsageTime = null;
    _isConfirmed = false;

    // Bersihkan juga data lokasi & UV
    _locationName = null;
    _latitude = null;
    _longitude = null;
    _uvIndex = null;
    _uvRiskLevel = null;

    notifyListeners();
  }

  /// Memetakan aktivitas ke nilai database
  String get mappedActivity => switch (_selectedActivity) {
    'Dalam Ruangan (Indoor)' => 'indoor',
    'Luar Ruangan Ringan' => 'outdoor_light',
    'Luar Ruangan Intens' => 'outdoor_intense',
    'Olahraga / Sport' => 'sport',
    'Berenang / Aktivitas Air' => 'swim',
    _ => 'indoor',
  };

  /// Memetakan tekstur ke nilai database
  String? get mappedTexture => switch (_selectedTexture) {
    'Gel' => 'gel',
    'Cream' => 'cream',
    'Lotion' => 'lotion',
    'Serum' => 'serum',
    'Milk' => 'milk',
    'Watery' => 'watery',
    'Stick' => 'stick',
    'Spray' => 'spray',
    'Mist' => 'mist',
    _ => null,
  };

  /// Memetakan label waktu penggunaan ke format enum database Supabase
  String get mappedUsageTime {
    if (!isNight) return 'realtime';
    return switch (_selectedUsageTime) {
      'Pagi Hari' => 'morning',
      'Siang Hari' => 'afternoon',
      'Malam Hari' => 'evening',
      _ => 'morning',
    };
  }

  /// Memetakan label riwayat alergi ke format enum database Supabase (selalu 'none' karena di-handle otomatis di backend)
  String get mappedAllergyStatus => 'none';

  bool get isFormValid {
    final requiresUsageTime = isNight;
    final hasInvalidUsageTime = requiresUsageTime && _selectedUsageTime == null;

    return _selectedSkinType != null &&
        _selectedSkinProblems.isNotEmpty &&
        _selectedActivity != null &&
        _selectedTexture != null &&
        !hasInvalidUsageTime;
  }
}
