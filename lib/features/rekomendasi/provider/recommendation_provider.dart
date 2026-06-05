import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/models/recommendation_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/ingredient_model.dart';
import 'package:recommendation_app/features/rekomendasi/services/recommendation_service.dart';

/// Provider yang mengelola status state untuk formulir dan riwayat rekomendasi skincare.
class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();

  // State Pilihan Formulir (Dinamis)
  List<SkinTypeModel> _skinTypes = [];
  List<SkinConcernModel> _skinConcerns = [];
  List<IngredientModel> _ingredients = [];

  // State Riwayat Rekomendasi
  Map<String, int> _categoryCounts = {
    'Cleanser': 0,
    'Toner': 0,
    'Serum': 0,
    'Moisture': 0,
    'Sunscreen': 0,
  };
  List<RecommendationModel> _recommendations = [];

  // State Hasil Rekomendasi Sesi Terkini
  Map<String, dynamic>? _currentSessionDetails;
  List<Map<String, dynamic>> _currentSessionResults = [];

  // State Sunscreen Aktif dari DB untuk kalkulasi UV protection
  List<Map<String, dynamic>> _dbSunscreens = [];

  // State Umum Pemuatan & Error
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Getters Opsi Formulir
  List<SkinTypeModel> get skinTypes => _skinTypes;
  List<SkinConcernModel> get skinConcerns => _skinConcerns;
  List<IngredientModel> get ingredients => _ingredients;

  // Getters Riwayat & Status
  Map<String, int> get categoryCounts => _categoryCounts;
  List<RecommendationModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // Getters Hasil Rekomendasi Sesi Terkini
  Map<String, dynamic>? get currentSessionDetails => _currentSessionDetails;
  List<Map<String, dynamic>> get currentSessionResults => _currentSessionResults;
  List<Map<String, dynamic>> get dbSunscreens => _dbSunscreens;

  /// Memuat semua data master opsi formulir (dengan caching RAM)
  Future<void> loadFormOptions({bool force = false}) async {
    // Jika tidak force refresh dan data sudah ada di RAM, langsung return
    if (!force &&
        _skinTypes.isNotEmpty &&
        _skinConcerns.isNotEmpty &&
        _ingredients.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _recommendationService.fetchSkinTypes(),
        _recommendationService.fetchSkinConcerns(),
        _recommendationService.fetchIngredients(),
      ]);

      _skinTypes = results[0] as List<SkinTypeModel>;
      _skinConcerns = results[1] as List<SkinConcernModel>;
      _ingredients = results[2] as List<IngredientModel>;
    } catch (e) {
      _errorMessage = 'Gagal memuat pilihan formulir rekomendasi.';
      debugPrint('RecommendationProvider loadFormOptions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengirimkan data formulir rekomendasi terpilih pengguna
  Future<String?> submitRecommendation({
    required String userId,
    required String skinTypeId,
    required String usageTime,
    required String allergyStatus,
    required List<String> selectedConcernIds,
    required List<String> avoidedIngredientIds,
    String? locationName,
    double? latitude,
    double? longitude,
    double? uvIndex,
    String? uvRiskLevel,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionId = await _recommendationService.submitRecommendations(
        userId: userId,
        skinTypeId: skinTypeId,
        usageTime: usageTime,
        allergyStatus: allergyStatus,
        selectedConcernIds: selectedConcernIds,
        avoidedIngredientIds: avoidedIngredientIds,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        uvIndex: uvIndex,
        uvRiskLevel: uvRiskLevel,
      );

      // Perbarui riwayat rekomendasi dan jumlah kategori di background
      await fetchCategoryCounts(userId);

      return sessionId;
    } catch (e) {
      _errorMessage = 'Gagal mengirim formulir rekomendasi Anda.';
      debugPrint('RecommendationProvider submitRecommendation error: $e');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Memperbarui jumlah produk unik per kategori dan riwayat rekomendasi dengan mengambil data terbaru
  Future<void> fetchCategoryCounts(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recs = await _recommendationService.fetchRecommendations(userId);
      _recommendations = recs;

      final counts = {
        'Cleanser': 0,
        'Toner': 0,
        'Serum': 0,
        'Moisture': 0,
        'Sunscreen': 0,
      };

      for (final rec in recs) {
        final cat = rec.category.toLowerCase();
        if (cat == 'cleanser') counts['Cleanser'] = (counts['Cleanser'] ?? 0) + 1;
        if (cat == 'toner') counts['Toner'] = (counts['Toner'] ?? 0) + 1;
        if (cat == 'serum') counts['Serum'] = (counts['Serum'] ?? 0) + 1;
        if (cat == 'moisturizer' || cat == 'moisture') {
          counts['Moisture'] = (counts['Moisture'] ?? 0) + 1;
        }
        if (cat == 'sunscreen') counts['Sunscreen'] = (counts['Sunscreen'] ?? 0) + 1;
      }

      _categoryCounts = counts;

      // Ambil produk sunscreen aktif dari database untuk integrasi UV protection
      final suns = await _recommendationService.fetchActiveSunscreens();
      _dbSunscreens = suns;
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat rekomendasi.';
      debugPrint('RecommendationProvider fetchCategoryCounts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat hasil rekomendasi untuk sesi tertentu
  Future<void> loadSessionResults(String sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentSessionDetails = null;
    _currentSessionResults = [];
    notifyListeners();

    try {
      final results = await Future.wait([
        _recommendationService.fetchSessionDetails(sessionId),
        _recommendationService.fetchSessionResults(sessionId),
      ]);

      _currentSessionDetails = results[0] as Map<String, dynamic>?;
      _currentSessionResults = results[1] as List<Map<String, dynamic>>;
    } catch (e) {
      _errorMessage = 'Gagal memuat hasil rekomendasi.';
      debugPrint('RecommendationProvider loadSessionResults error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menghapus item hasil rekomendasi dan memuat ulang status kategori
  Future<bool> deleteRecommendation(String resultId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recommendationService.deleteRecommendationResult(resultId);
      // Panggil fetchCategoryCounts untuk sinkronisasi data riwayat terbaru
      await fetchCategoryCounts(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus riwayat rekomendasi.';
      debugPrint('RecommendationProvider deleteRecommendation error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
