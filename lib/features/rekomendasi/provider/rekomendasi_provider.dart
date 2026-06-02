import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/services/rekomendasi_service.dart';

// Bertanggung jawab mengelola status pemuatan data dan riwayat rekomendasi.
class RekomendasiProvider extends ChangeNotifier {
  final RekomendasiService _rekomendasiService = RekomendasiService();

  Map<String, int> _categoryCounts = {
    'Cleanser': 0,
    'Toner': 0,
    'Serum': 0,
    'Moisture': 0,
    'Sunscreen': 0,
  };
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, int> get categoryCounts => _categoryCounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Memperbarui jumlah produk unik per kategori dengan mengambil data terbaru
  Future<void> fetchCategoryCounts(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categoryCounts = await _rekomendasiService.fetchCategoryCounts(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat rekomendasi.';
      debugPrint('RekomendasiProvider fetchCategoryCounts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
