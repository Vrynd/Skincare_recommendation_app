import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/ingredient_model.dart';

class RecommendationFormProvider extends ChangeNotifier {
  SkinTypeModel? _selectedSkinType;
  List<SkinConcernModel> _selectedSkinProblems = [];
  String? _selectedUsageTime;
  String? _selectedAllergyStatus;
  List<IngredientModel> _selectedIngredients = [];
  bool _isConfirmed = false;

  SkinTypeModel? get selectedSkinType => _selectedSkinType;
  List<SkinConcernModel> get selectedSkinProblems => _selectedSkinProblems;
  String? get selectedUsageTime => _selectedUsageTime;
  String? get selectedAllergyStatus => _selectedAllergyStatus;
  List<IngredientModel> get selectedIngredients => _selectedIngredients;
  bool get isConfirmed => _isConfirmed;

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

  /// Melakukan pembersihan/reset seluruh data pilihan pada formulir ke kondisi semula
  void resetForm() {
    _selectedSkinType = null;
    _selectedSkinProblems = [];
    _selectedUsageTime = null;
    _selectedAllergyStatus = null;
    _selectedIngredients = [];
    _isConfirmed = false;
    notifyListeners();
  }

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
