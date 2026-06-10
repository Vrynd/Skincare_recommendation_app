import 'package:flutter/material.dart';
import 'package:recommendation_app/features/history/models/history_item.dart';
import 'package:recommendation_app/features/history/service/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  List<HistoryItem> _historyItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Mengembalikan list item yang sudah difilter berdasarkan query pencarian
  List<HistoryItem> get historyItems {
    if (_searchQuery.isEmpty) return _historyItems;
    final query = _searchQuery.toLowerCase();
    return _historyItems.where((item) {
      return item.productName.toLowerCase().contains(query) ||
             item.brandName.toLowerCase().contains(query) ||
             item.recommendationCode.toLowerCase().contains(query);
    }).toList();
  }

  /// Mengembalikan total riwayat secara keseluruhan (unfiltered)
  String get totalHistory => _historyItems.length.toString();

  /// Mengembalikan rata-rata match score dari seluruh riwayat (unfiltered)
  String get averageMatch {
    if (_historyItems.isEmpty) return '0%';
    final sum = _historyItems.fold<double>(0.0, (acc, item) => acc + item.matchScore);
    final avg = sum / _historyItems.length;
    return '${avg.round()}%';
  }

  /// Mengelompokkan riwayat berdasarkan Hari (Bahasa Indonesia)
  Map<String, List<HistoryItem>> get groupedHistory {
    final Map<String, List<HistoryItem>> groups = {};
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    const List<String> daysFull = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    
    const List<String> monthsFull = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    for (final item in historyItems) {
      final date = item.createdAt;
      final localDate = DateTime(date.year, date.month, date.day);
      
      String key;
      if (localDate == today) {
        key = 'Hari Ini';
      } else if (localDate == yesterday) {
        key = 'Kemarin';
      } else {
        final dayName = daysFull[date.weekday - 1];
        final monthName = monthsFull[date.month - 1];
        key = '$dayName, ${date.day} $monthName ${date.year}';
      }
      
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(item);
    }
    
    return groups;
  }

  /// Memuat riwayat rekomendasi dari database
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historyItems = await _historyService.fetchHistory(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat rekomendasi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menghapus satu sesi riwayat rekomendasi
  Future<bool> deleteSession(String sessionId) async {
    try {
      await _historyService.deleteHistorySession(sessionId);
      _historyItems.removeWhere((item) => item.sessionId == sessionId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus riwayat.';
      notifyListeners();
      return false;
    }
  }

  /// Mengatur kata kunci pencarian
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Membersihkan pesan kesalahan
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
