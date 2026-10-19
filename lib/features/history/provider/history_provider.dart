import 'package:flutter/material.dart';
import 'package:recommendation_app/features/history/models/history_item.dart';
import 'package:recommendation_app/features/history/service/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  List<HistoryItem> _historyItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  int _displayedCount = 8;
  bool _isLoadingMore = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _displayedCount < historyItems.length;
  int get displayedCount => _displayedCount;
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

  /// Mengembalikan list item yang ditampilkan sesuai batas lazy loading
  List<HistoryItem> get displayedHistoryItems {
    final items = historyItems;
    if (_displayedCount >= items.length) {
      return items;
    }
    return items.take(_displayedCount).toList();
  }

  /// Mengembalikan total riwayat secara keseluruhan (atau hasil pencarian)
  String get totalHistory {
    final list = _searchQuery.isNotEmpty ? historyItems : _historyItems;
    return list.length.toString();
  }

  /// Mengembalikan rata-rata match score dari seluruh riwayat (atau hasil pencarian)
  String get averageMatch {
    final list = _searchQuery.isNotEmpty ? historyItems : _historyItems;
    if (list.isEmpty) return '0%';
    final sum = list.fold<double>(0.0, (acc, item) => acc + item.matchScore);
    final avg = sum / list.length;
    return '${avg.round()}%';
  }

  /// Mengelompokkan riwayat yang sedang ditampilkan (lazy load) berdasarkan Hari (Bahasa Indonesia)
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

    for (final item in displayedHistoryItems) {
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

  /// Memuat lebih banyak item riwayat (lazy loading +8 item)
  Future<void> loadMoreHistory() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _displayedCount += 8;
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Reset batas tampilan ke 8 item awal
  void resetPagination() {
    _displayedCount = 8;
    notifyListeners();
  }

  /// Memuat riwayat rekomendasi dari database
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    _displayedCount = 8;
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
    _displayedCount = 8;
    notifyListeners();
  }

  /// Membersihkan pesan kesalahan
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
