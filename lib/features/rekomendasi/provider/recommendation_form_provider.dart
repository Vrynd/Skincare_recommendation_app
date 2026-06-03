import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/ingredient_model.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';

class RecommendationFormProvider extends ChangeNotifier {
  SkinTypeModel? _selectedSkinType;
  List<SkinConcernModel> _selectedSkinProblems = [];
  String? _selectedUsageTime;
  String? _selectedAllergyStatus;
  List<IngredientModel> _selectedIngredients = [];
  bool _isConfirmed = false;

  // State Otomatis Lokasi & UV (bagian dari payload formulir)
  String? _locationName;
  double? _latitude;
  double? _longitude;
  double? _uvIndex;
  String? _uvRiskLevel;

  SkinTypeModel? get selectedSkinType => _selectedSkinType;
  List<SkinConcernModel> get selectedSkinProblems => _selectedSkinProblems;
  String? get selectedUsageTime => _selectedUsageTime;
  String? get selectedAllergyStatus => _selectedAllergyStatus;
  List<IngredientModel> get selectedIngredients => _selectedIngredients;
  bool get isConfirmed => _isConfirmed;

  // Getters Lokasi & UV
  String? get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  double? get uvIndex => _uvIndex;
  String? get uvRiskLevel => _uvRiskLevel;

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

  /// Mengatur pilihan waktu penggunaan skincare
  void setSelectedUsageTime(String? value) {
    _selectedUsageTime = value;
    _isConfirmed = false;
    notifyListeners();
  }

  void setSelectedAllergyStatus(String? value) {
    _selectedAllergyStatus = value;
    if (value != 'Pernah Alergi terhadap Bahan Tertentu') {
      _selectedIngredients = [];
    }
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan bahan kimia yang dihindari (multi-selection)
  void setSelectedIngredients(List<IngredientModel> values) {
    _selectedIngredients = values;
    _isConfirmed = false;
    notifyListeners();
  }

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
    _selectedUsageTime = null;
    _selectedAllergyStatus = null;
    _selectedIngredients = [];
    _isConfirmed = false;

    // Bersihkan juga data lokasi & UV
    _locationName = null;
    _latitude = null;
    _longitude = null;
    _uvIndex = null;
    _uvRiskLevel = null;

    notifyListeners();
  }

  /// Memetakan label waktu penggunaan ke format enum database Supabase
  String get mappedUsageTime => switch (_selectedUsageTime) {
    'Pagi Hari' => 'morning_day',
    'Pagi & Malam Hari' => 'morning_and_night',
    'Malam Hari' => 'night',
    _ => 'morning_and_night',
  };

  /// Memetakan label riwayat alergi ke format enum database Supabase
  String get mappedAllergyStatus => switch (_selectedAllergyStatus) {
    'Tidak Ada Riwayat Alergi' => 'none',
    'Pernah Alergi, tapi Tidak Tahu Bahannya' => 'unknown_ingredient',
    'Pernah Alergi terhadap Bahan Tertentu' => 'known_ingredient',
    _ => 'none',
  };

  bool get isFormValid {
    final isAllergyWithIngredients =
        _selectedAllergyStatus == 'Pernah Alergi terhadap Bahan Tertentu';
    final hasInvalidAllergy =
        isAllergyWithIngredients && _selectedIngredients.isEmpty;

    return _selectedSkinType != null &&
        _selectedSkinProblems.isNotEmpty &&
        _selectedUsageTime != null &&
        _selectedAllergyStatus != null &&
        !hasInvalidAllergy;
  }
}
