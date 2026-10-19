// Model DTO untuk hasil rekomendasi sunscreen dual-mode (Rutin & Hari Ini)
// sesuai metodologi Rule-Based Scoring 5 Langkah (6 Kriteria).

class SunscreenRecommendationItem {
  final int rankPosition;
  final String? mode;
  final String productId;
  final String? productCode;
  final String brandName;
  final String productName;
  final String bpomNumber;
  final int spf;
  final String paGrade;
  final String? sunscreenType;
  final String? texture;
  final String? finish;
  final double matchScore;
  final String recommendationCategory;

  // 6 Nilai Derajat Kecocokan Kriteria (s_ij)
  final double sUv;
  final double sSkin;
  final double sActivity;
  final double sConcern;
  final double sTexture;
  final double sFinish;

  // Skor Poin Terbobot (0 - 25 / 20 / 10)
  final double uvScore;
  final double skinTypeScore;
  final double activityScore;
  final double skinConcernScore;
  final double textureScore;
  final double finishScore;
  final double penalty;

  // Persentase Kontribusi Relatif K_ij (Total = 100%)
  final Map<String, double> contributions;

  const SunscreenRecommendationItem({
    required this.rankPosition,
    this.mode,
    required this.productId,
    this.productCode,
    required this.brandName,
    required this.productName,
    required this.bpomNumber,
    required this.spf,
    required this.paGrade,
    this.sunscreenType,
    this.texture,
    this.finish,
    required this.matchScore,
    required this.recommendationCategory,
    this.sUv = 1.0,
    this.sSkin = 1.0,
    this.sActivity = 1.0,
    this.sConcern = 1.0,
    this.sTexture = 1.0,
    this.sFinish = 1.0,
    this.uvScore = 25.0,
    this.skinTypeScore = 25.0,
    this.activityScore = 20.0,
    this.skinConcernScore = 10.0,
    this.textureScore = 10.0,
    this.finishScore = 10.0,
    this.penalty = 0.0,
    this.contributions = const {},
  });

  factory SunscreenRecommendationItem.fromJson(Map<String, dynamic> json) {
    // Tangani kemungkinan nested object dari query tabel products
    final productObj = json['products'] is Map<String, dynamic>
        ? json['products'] as Map<String, dynamic>
        : json;

    final rawContributions = json['contributions'] as Map<String, dynamic>? ?? {};
    final mappedContributions = <String, double>{};
    rawContributions.forEach((k, v) {
      if (v is num) {
        mappedContributions[k] = v.toDouble();
      }
    });

    return SunscreenRecommendationItem(
      rankPosition: (json['rank_position'] as num?)?.toInt() ?? 1,
      mode: json['mode']?.toString(),
      productId: (productObj['product_id'] ?? json['product_id'] ?? '').toString(),
      productCode: (productObj['product_code'] ?? json['product_code'])?.toString(),
      brandName: (productObj['brand_name'] ?? json['brand_name'] ?? '-').toString(),
      productName: (productObj['product_name'] ?? json['product_name'] ?? '-').toString(),
      bpomNumber: (productObj['bpom_number'] ?? json['bpom_number'] ?? '-').toString(),
      spf: (productObj['spf'] as num?)?.toInt() ?? 30,
      paGrade: (productObj['pa_grade'] ?? json['pa_grade'] ?? 'PA+++').toString(),
      sunscreenType: (productObj['sunscreen_type'] ?? json['sunscreen_type'])?.toString(),
      texture: (productObj['texture'] ?? json['texture'])?.toString(),
      finish: (productObj['finish'] ?? json['finish'])?.toString(),
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0.0,
      recommendationCategory: (json['recommendation_category'] ?? 'fairly_suitable').toString(),
      sUv: (json['s_uv'] as num?)?.toDouble() ?? 1.0,
      sSkin: (json['s_skin'] as num?)?.toDouble() ?? 1.0,
      sActivity: (json['s_activity'] as num?)?.toDouble() ?? 1.0,
      sConcern: (json['s_concern'] as num?)?.toDouble() ?? 1.0,
      sTexture: (json['s_texture'] as num?)?.toDouble() ?? 1.0,
      sFinish: (json['s_finish'] as num?)?.toDouble() ?? 1.0,
      uvScore: (json['uv_score'] as num?)?.toDouble() ?? 25.0,
      skinTypeScore: (json['skin_type_score'] as num?)?.toDouble() ?? 25.0,
      activityScore: (json['activity_score'] as num?)?.toDouble() ?? 20.0,
      skinConcernScore: (json['skin_concern_score'] as num?)?.toDouble() ?? 10.0,
      textureScore: (json['texture_score'] as num?)?.toDouble() ?? 10.0,
      finishScore: (json['finish_score'] as num?)?.toDouble() ?? 10.0,
      penalty: (json['penalty'] as num?)?.toDouble() ?? 0.0,
      contributions: mappedContributions,
    );
  }

  /// Konversi ke `Map<String, dynamic>` untuk kompatibilitas widget lama
  Map<String, dynamic> toMap() {
    return {
      'rank_position': rankPosition,
      'mode': mode,
      'product_id': productId,
      'product_code': productCode,
      'brand_name': brandName,
      'product_name': productName,
      'bpom_number': bpomNumber,
      'spf': spf,
      'pa_grade': paGrade,
      'sunscreen_type': sunscreenType,
      'texture': texture,
      'finish': finish,
      'match_score': matchScore,
      'recommendation_category': recommendationCategory,
      's_uv': sUv,
      's_skin': sSkin,
      's_activity': sActivity,
      's_concern': sConcern,
      's_texture': sTexture,
      's_finish': sFinish,
      'uv_score': uvScore,
      'skin_type_score': skinTypeScore,
      'activity_score': activityScore,
      'skin_concern_score': skinConcernScore,
      'texture_score': textureScore,
      'finish_score': finishScore,
      'penalty': penalty,
      'contributions': contributions,
      'products': {
        'product_id': productId,
        'brand_name': brandName,
        'product_name': productName,
        'bpom_number': bpomNumber,
        'spf': spf,
        'pa_grade': paGrade,
        'category': 'sunscreen',
        'spf_value': spf.toString(),
      },
    };
  }
}

class UvDataModel {
  final double uvIndex;
  final String uvRiskLevel;
  final int spfMinimum;
  final String paMinimum;
  final int routineSpfTarget;
  final String routinePaTarget;
  final String usageTimePreference;
  final bool isForecast;

  const UvDataModel({
    required this.uvIndex,
    required this.uvRiskLevel,
    required this.spfMinimum,
    required this.paMinimum,
    this.routineSpfTarget = 30,
    this.routinePaTarget = 'PA+++',
    required this.usageTimePreference,
    this.isForecast = false,
  });

  factory UvDataModel.fromJson(Map<String, dynamic> json) {
    return UvDataModel(
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
      uvRiskLevel: (json['uv_risk_level'] ?? 'low').toString(),
      spfMinimum: (json['spf_minimum'] as num?)?.toInt() ?? 30,
      paMinimum: (json['pa_minimum'] ?? 'PA+++').toString(),
      routineSpfTarget: (json['routine_spf_target'] as num?)?.toInt() ?? 30,
      routinePaTarget: (json['routine_pa_target'] ?? 'PA+++').toString(),
      usageTimePreference: (json['usage_time_preference'] ?? 'realtime').toString(),
      isForecast: json['is_forecast'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uv_index': uvIndex,
      'uv_risk_level': uvRiskLevel,
      'spf_minimum': spfMinimum,
      'pa_minimum': paMinimum,
      'routine_spf_target': routineSpfTarget,
      'routine_pa_target': routinePaTarget,
      'usage_time_preference': usageTimePreference,
      'is_forecast': isForecast,
    };
  }
}

class RecommendationDualModeResponse {
  final String sessionId;
  final String? recommendationCode;
  final UvDataModel? uvData;
  final List<SunscreenRecommendationItem> routineResults;
  final List<SunscreenRecommendationItem> todayResults;
  final List<SunscreenRecommendationItem> results;

  const RecommendationDualModeResponse({
    required this.sessionId,
    this.recommendationCode,
    this.uvData,
    required this.routineResults,
    required this.todayResults,
    required this.results,
  });

  factory RecommendationDualModeResponse.fromJson(Map<String, dynamic> json) {
    final sessionId = (json['recommendation_session_id'] ?? '').toString();
    final code = json['recommendation_code']?.toString();

    final uvJson = json['uv_data'] as Map<String, dynamic>?;
    final uv = uvJson != null ? UvDataModel.fromJson(uvJson) : null;

    final routineList = (json['routine_results'] as List<dynamic>? ?? [])
        .map((item) => SunscreenRecommendationItem.fromJson(item as Map<String, dynamic>))
        .toList();

    final todayList = (json['today_results'] as List<dynamic>? ?? [])
        .map((item) => SunscreenRecommendationItem.fromJson(item as Map<String, dynamic>))
        .toList();

    final fallbackList = (json['results'] as List<dynamic>? ?? [])
        .map((item) => SunscreenRecommendationItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return RecommendationDualModeResponse(
      sessionId: sessionId,
      recommendationCode: code,
      uvData: uv,
      routineResults: routineList,
      todayResults: todayList,
      results: fallbackList.isNotEmpty ? fallbackList : (todayList.isNotEmpty ? todayList : routineList),
    );
  }
}
