import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recommendation_app/features/history/models/history_item.dart';

class HistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil semua riwayat sesi rekomendasi untuk user tertentu.
  /// Hanya mengambil produk dengan peringkat pertama (skor tertinggi) dari tiap sesi.
  Future<List<HistoryItem>> fetchHistory(String userId) async {
    try {
      final response = await _supabase
          .from('recommendation_results')
          .select('''
            recommendation_result_id,
            recommendation_session_id,
            match_score,
            recommendation_category,
            rank_position,
            created_at,
            recommendation_sessions!inner(
              recommendation_code,
              user_id
            ),
            products(
              product_id,
              product_code,
              brand_name,
              product_name,
              spf,
              pa_grade,
              sunscreen_type,
              texture,
              finish
            )
          ''')
          .eq('recommendation_sessions.user_id', userId)
          .eq('rank_position', 1)
          .order('created_at', ascending: false);

      final List<dynamic> list = response as List<dynamic>;
      return list.map((item) => HistoryItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      // Return empty list on failure or log the error
      debugPrint('HistoryService.fetchHistory error: $e');
      debugPrint(stackTrace.toString());
      return [];
    }
  }

  /// Menghapus sesi rekomendasi berdasarkan ID Sesi.
  /// Berkat cascade delete, ini juga menghapus data di recommendation_results,
  /// recommendation_concerns, dan avoided_ingredients terkait.
  Future<void> deleteHistorySession(String sessionId) async {
    await _supabase
        .from('recommendation_sessions')
        .delete()
        .eq('recommendation_session_id', sessionId);
  }
}
