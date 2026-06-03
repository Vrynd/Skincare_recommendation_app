import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recommendation_app/features/rekomendasi/models/recommendation_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/ingredient_model.dart';

/// Service yang mengelola komunikasi data rekomendasi skincare dengan Supabase.
class RecommendationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil daftar master tipe kulit dari tabel `skin_types`
  Future<List<SkinTypeModel>> fetchSkinTypes() async {
    try {
      final List<dynamic> data = await _supabase
          .from('skin_types')
          .select()
          .order('skin_type_code', ascending: true);

      return data.map((json) => SkinTypeModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('RecommendationService fetchSkinTypes error: $e');
      rethrow;
    }
  }

  /// Mengambil daftar master masalah kulit dari tabel `skin_concerns`
  Future<List<SkinConcernModel>> fetchSkinConcerns() async {
    try {
      final List<dynamic> data = await _supabase
          .from('skin_concerns')
          .select()
          .order('skin_concern_code', ascending: true);

      return data.map((json) => SkinConcernModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('RecommendationService fetchSkinConcerns error: $e');
      rethrow;
    }
  }

  /// Mengambil daftar master bahan kosmetik dari tabel `ingredients`
  Future<List<IngredientModel>> fetchIngredients() async {
    try {
      final List<dynamic> data = await _supabase
          .from('ingredients')
          .select()
          .order('ingredient_name', ascending: true);

      return data.map((json) => IngredientModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('RecommendationService fetchIngredients error: $e');
      rethrow;
    }
  }

  /// Menyimpan formulir rekomendasi baru beserta data
  Future<String> submitRecommendations({
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
    try {
      // 1. Simpan data utama sesi rekomendasi
      final sessionResult = await _supabase
          .from('recommendation_sessions')
          .insert({
            'id_user': userId,
            'skin_type_id': skinTypeId,
            'usage_time': usageTime,
            'allergy_status': allergyStatus,
            'location_name': locationName,
            'latitude': latitude,
            'longitude': longitude,
            'uv_index': uvIndex,
            'uv_risk_level': uvRiskLevel,
          })
          .select('recommendation_session_id')
          .single();

      final String sessionId = sessionResult['recommendation_session_id'] as String;

      // 2. Simpan daftar masalah kulit terpilih
      if (selectedConcernIds.isNotEmpty) {
        final List<Map<String, dynamic>> concernsData = selectedConcernIds
            .map((concernId) => {
                  'recommendation_session_id': sessionId,
                  'skin_concern_id': concernId,
                })
            .toList();

        await _supabase.from('recommendation_concerns').insert(concernsData);
      }

      // 3. Simpan daftar bahan kosmetik yang dihindari
      if (avoidedIngredientIds.isNotEmpty) {
        final List<Map<String, dynamic>> avoidedIngredientsData = avoidedIngredientIds
            .map((ingredientId) => {
                  'recommendation_session_id': sessionId,
                  'ingredient_id': ingredientId,
                })
            .toList();

        await _supabase.from('avoided_ingredients').insert(avoidedIngredientsData);
      }

      return sessionId;
    } catch (e) {
      debugPrint('RecommendationService submitRecommendationSession error: $e');
      rethrow;
    }
  }

  /// Mengambil daftar riwayat rekomendasi skincare milik user dari tabel Supabase
  Future<List<RecommendationModel>> fetchRecommendations(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('recommendation_results')
          .select('''
            recommendation_result_id,
            recommendation_session_id,
            created_at,
            products!inner (
              product_name,
              brand_name,
              category
            ),
            recommendation_sessions!inner (
              id_user,
              recommendation_code
            )
          ''')
          .eq('recommendation_sessions.id_user', userId)
          .order('created_at', ascending: false);

      return data.map((json) => RecommendationModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('RecommendationService fetchRecommendations error: $e');
      rethrow;
    }
  }

  /// Mengambil jumlah rekomendasi produk per kategori skincare milik user
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
      debugPrint('RecommendationService fetchCategoryCounts error: $e');
      rethrow;
    }
  }

  /// Mengambil rincian sesi rekomendasi tertentu berdasarkan sessionId
  Future<Map<String, dynamic>?> fetchSessionDetails(String sessionId) async {
    try {
      // 1. Ambil detail sesi utama
      final sessionData = await _supabase
          .from('recommendation_sessions')
          .select('''
            recommendation_session_id,
            recommendation_code,
            usage_time,
            allergy_status,
            location_name,
            latitude,
            longitude,
            uv_index,
            uv_risk_level,
            skin_types (
              skin_type_name
            )
          ''')
          .eq('recommendation_session_id', sessionId)
          .single();

      // 2. Ambil masalah kulit terpilih
      final List<dynamic> concernsData = await _supabase
          .from('recommendation_concerns')
          .select('skin_concerns (skin_concern_name)')
          .eq('recommendation_session_id', sessionId);
      
      final List<String> concerns = concernsData
          .map((item) {
            final concern = item['skin_concerns'] as Map<String, dynamic>?;
            return concern != null ? concern['skin_concern_name'] as String : '';
          })
          .where((name) => name.isNotEmpty)
          .toList();

      // 3. Ambil bahan kosmetik yang dihindari (alergen)
      final List<dynamic> ingredientsData = await _supabase
          .from('avoided_ingredients')
          .select('ingredients (ingredient_name)')
          .eq('recommendation_session_id', sessionId);

      final List<String> ingredients = ingredientsData
          .map((item) {
            final ingredient = item['ingredients'] as Map<String, dynamic>?;
            return ingredient != null ? ingredient['ingredient_name'] as String : '';
          })
          .where((name) => name.isNotEmpty)
          .toList();

      return {
        'session': sessionData,
        'concerns': concerns,
        'ingredients': ingredients,
      };
    } catch (e) {
      debugPrint('RecommendationService fetchSessionDetails error: $e');
      return null;
    }
  }

  /// Mengambil daftar produk hasil rekomendasi untuk sesi tertentu
  Future<List<Map<String, dynamic>>> fetchSessionResults(String sessionId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('recommendation_results')
          .select('''
            recommendation_result_id,
            match_score,
            rank_position,
            products (
              product_id,
              brand_name,
              product_name,
              category,
              usage_time,
              spf_value,
              pa_grade
            )
          ''')
          .eq('recommendation_session_id', sessionId)
          .order('rank_position', ascending: true);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('RecommendationService fetchSessionResults error: $e');
      return [];
    }
  }
}
