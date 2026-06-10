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
    required String activity,
    required String? texturePreference,
    required List<String> selectedConcernIds,
    required List<String> avoidedIngredientIds,
    String? locationName,
    double? latitude,
    double? longitude,
    double? uvIndex,
    String? uvRiskLevel,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'get_sunscreen_recommendation',
        body: {
          'user_id': userId,
          'skin_type_id': skinTypeId,
          'skin_concern_ids': selectedConcernIds,
          'activity': activity,
          'texture_preference': texturePreference,
          'allergy_status': allergyStatus,
          'avoided_ingredient_ids': avoidedIngredientIds,
          'location_name': locationName,
          'latitude': latitude ?? 0.0,
          'longitude': longitude ?? 0.0,
          'usage_time_preference': usageTime,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Gagal membuat rekomendasi');
      }

      final String sessionId = response.data['recommendation_session_id'] as String;
      return sessionId;
    } catch (e) {
      debugPrint('RecommendationService submitRecommendations error: $e');
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
              spf,
              pa_grade
            ),
            recommendation_sessions!inner (
              user_id,
              recommendation_code
            )
          ''')
          .eq('recommendation_sessions.user_id', userId)
          .order('created_at', ascending: false);

      final mappedData = data.map((json) {
        final Map<String, dynamic> mutableJson = Map<String, dynamic>.from(json);
        if (mutableJson['products'] != null) {
          final Map<String, dynamic> product = Map<String, dynamic>.from(mutableJson['products']);
          product['category'] = 'sunscreen';
          product['spf_value'] = product['spf']?.toString() ?? '15';
          mutableJson['products'] = product;
        }
        return mutableJson;
      }).toList();

      return mappedData.map((json) => RecommendationModel.fromJson(json)).toList();
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
            recommendation_sessions!inner (
              user_id
            )
          ''')
          .eq('recommendation_sessions.user_id', userId);

      // Since the new database and recommendations are exclusively sunscreen
      final counts = {
        'Cleanser': 0,
        'Toner': 0,
        'Serum': 0,
        'Moisture': 0,
        'Sunscreen': data.length,
      };

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
            usage_time_preference,
            allergy_status,
            location_name,
            latitude,
            longitude,
            uv_index,
            skin_types (
              skin_type_name
            )
          ''')
          .eq('recommendation_session_id', sessionId)
          .single();

      // Calculate UV risk level dynamically for backward compatibility
      double? uvVal = sessionData['uv_index'] != null 
          ? double.tryParse(sessionData['uv_index'].toString()) 
          : null;
      String riskLevel = 'low';
      if (uvVal != null) {
        if (uvVal <= 2) {
          riskLevel = 'low';
        } else if (uvVal <= 5) {
          riskLevel = 'moderate';
        } else if (uvVal <= 7) {
          riskLevel = 'high';
        } else if (uvVal <= 10) {
          riskLevel = 'very_high';
        } else {
          riskLevel = 'extreme';
        }
      }

      // Map usage_time_preference back to usage_time labels for UI compatibility
      String usageTime = 'Pagi & Malam Hari';
      String? pref = sessionData['usage_time_preference'] as String?;
      if (pref == 'morning') {
        usageTime = 'Pagi Hari';
      } else if (pref == 'evening') {
        usageTime = 'Malam Hari';
      }

      final Map<String, dynamic> modifiedSession = Map<String, dynamic>.from(sessionData);
      modifiedSession['usage_time'] = usageTime;
      modifiedSession['uv_risk_level'] = riskLevel;

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
        'session': modifiedSession,
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
            recommendation_category,
            rank_position,
            products (
              product_id,
              brand_name,
              product_name,
              spf,
              pa_grade,
              bpom_number
            )
          ''')
          .eq('recommendation_session_id', sessionId)
          .order('rank_position', ascending: true);

      // Map products to include category and spf_value for backward compatibility
      final mappedData = data.map((item) {
        final Map<String, dynamic> mutableItem = Map<String, dynamic>.from(item);
        if (mutableItem['products'] != null) {
          final Map<String, dynamic> product = Map<String, dynamic>.from(mutableItem['products']);
          product['category'] = 'sunscreen';
          product['spf_value'] = product['spf']?.toString() ?? '15';
          mutableItem['products'] = product;
        }
        return mutableItem;
      }).toList();

      return List<Map<String, dynamic>>.from(mappedData);
    } catch (e) {
      debugPrint('RecommendationService fetchSessionResults error: $e');
      return [];
    }
  }

  /// Mengambil daftar semua produk sunscreen aktif dari database
  Future<List<Map<String, dynamic>>> fetchActiveSunscreens() async {
    try {
      final List<dynamic> data = await _supabase
          .from('products')
          .select('product_id, brand_name, product_name, spf, pa_grade')
          .eq('is_active', true);

      final mappedData = data.map((item) {
        final Map<String, dynamic> mutableItem = Map<String, dynamic>.from(item);
        mutableItem['category'] = 'sunscreen';
        mutableItem['spf_value'] = mutableItem['spf']?.toString() ?? '15';
        return mutableItem;
      }).toList();

      return List<Map<String, dynamic>>.from(mappedData);
    } catch (e) {
      debugPrint('RecommendationService fetchActiveSunscreens error: $e');
      return [];
    }
  }

  /// Menghapus baris hasil rekomendasi tertentu berdasarkan ID hasil rekomendasi
  Future<void> deleteRecommendationResult(String resultId) async {
    try {
      await _supabase
          .from('recommendation_results')
          .delete()
          .eq('recommendation_result_id', resultId);
    } catch (e) {
      debugPrint('RecommendationService deleteRecommendationResult error: $e');
      rethrow;
    }
  }
}
