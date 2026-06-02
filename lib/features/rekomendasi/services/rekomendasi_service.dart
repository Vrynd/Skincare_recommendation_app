import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Bertanggung jawab untuk melangsungkan komunikasi langsung dengan database Supabase.
class RekomendasiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil jumlah produk unik per kategori skincare
  Future<Map<String, int>> fetchCategoryCounts(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('recommendation_results')
          .select('''
            product_id,
            products!inner (
              category
            ),
            recommendation_sessions!inner (
              id_user
            )
          ''')
          .eq('recommendation_sessions.id_user', userId);

      final counts = {
        'Cleanser': 0,
        'Toner': 0,
        'Serum': 0,
        'Moisture': 0,
        'Sunscreen': 0,
      };

      // Set untuk melacak produk unik yang sudah dihitung per kategori
      final Map<String, Set<String>> countedProducts = {
        'Cleanser': {},
        'Toner': {},
        'Serum': {},
        'Moisture': {},
        'Sunscreen': {},
      };

      for (final item in data) {
        final productId = item['product_id'] as String?;
        final products = item['products'] as Map<String, dynamic>?;
        if (productId == null || products == null) continue;

        final rawCategory = products['category'] as String?;
        if (rawCategory == null) continue;

        String? uiCategory;
        switch (rawCategory.toLowerCase()) {
          case 'cleanser':
            uiCategory = 'Cleanser';
            break;
          case 'toner':
            uiCategory = 'Toner';
            break;
          case 'serum':
            uiCategory = 'Serum';
            break;
          case 'moisturizer':
            uiCategory = 'Moisture';
            break;
          case 'sunscreen':
            uiCategory = 'Sunscreen';
            break;
        }

        if (uiCategory != null) {
          countedProducts[uiCategory]!.add(productId);
        }
      }

      countedProducts.forEach((key, value) {
        counts[key] = value.length;
      });

      return counts;
    } catch (e) {
      debugPrint('RekomendasiService fetchCategoryCounts error: $e');
      rethrow;
    }
  }
}
