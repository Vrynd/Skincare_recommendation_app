import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/models/recommendation_model.dart';
import 'package:recommendation_app/features/rekomendasi/services/rekomendasi_service.dart';

// Bertanggung jawab mengelola status pemuatan data dan riwayat rekomendasi.
class RecommendationProvider extends ChangeNotifier {
  final RekomendasiService _rekomendasiService = RekomendasiService();

  Map<String, int> _categoryCounts = {
    'Cleanser': 0,
    'Toner': 0,
    'Serum': 0,
    'Moisture': 0,
    'Sunscreen': 0,
  };
  List<RecommendationModel> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, int> get categoryCounts => _categoryCounts;
  List<RecommendationModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Memperbarui jumlah produk unik per kategori dan riwayat rekomendasi dengan mengambil data terbaru
  Future<void> fetchCategoryCounts(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Jalankan query secara paralel agar performa muatan data maksimal
      final results = await Future.wait([
        _rekomendasiService.fetchCategoryCounts(userId),
        _rekomendasiService.fetchRecommendations(userId),
      ]);

      _categoryCounts = results[0] as Map<String, int>;
      _recommendations = results[1] as List<RecommendationModel>;
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat rekomendasi.';
      debugPrint('RekomendasiProvider fetchCategoryCounts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
