import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_tile.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/product_recommendation_card.dart';

String allergyDisplay(String? r) =>
    const {
      'none': 'Tidak Ada Alergi',
      'unknown_ingredient': 'Ada, Bahan Tidak Diketahui',
      'known_ingredient': 'Ada Riwayat Alergi',
    }[r?.toLowerCase()] ??
    r ??
    '-';

String uvDisplay(dynamic idx, String? lvl) {
  final i = idx != null ? (idx as num).toStringAsFixed(1) : '-';
  final l = const {
    'low': 'Rendah',
    'moderate': 'Sedang',
    'high': 'Tinggi',
    'very_high': 'Sangat Tinggi',
    'extreme': 'Ekstrem',
  }[lvl?.toLowerCase()];
  return l == null ? i : '$i · $l';
}

Widget summaryTile(int i, String v) {
  final cfg = [
    (HugeIcons.strokeRoundedDroplet, AppColors.accentPurple, 'Jenis Kulit'),
    (HugeIcons.strokeRoundedAlert01, AppColors.accentOrange, 'Masalah Kulit'),
    (HugeIcons.strokeRoundedSparkles, AppColors.accentTeal, 'Hasil Akhir'),
    (HugeIcons.strokeRoundedSun02, AppColors.accentAmber, 'Indeks UV'),
    (HugeIcons.strokeRoundedLocation01, AppColors.accentTeal, 'Lokasi'),
    (
      HugeIcons.strokeRoundedAlertCircle,
      AppColors.accentPink,
      'Riwayat Alergi',
    ),
  ][i];
  return AppTile.modern(
    icon: cfg.$1,
    iconColor: cfg.$2,
    title: cfg.$3,
    value: v,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    showDivider: i < 5,
  );
}

Widget ingredientChip(BuildContext context, String name) {
  return AppContainer(
    width: null,
    showBorder: false,
    showShadow: false,
    opacity: 0.08,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    borderRadius: AppRadius.br24,
    color: AppColors.accentRed,
    child: Text(
      name,
      style: context.text.labelMedium?.copyWith(
        color: AppColors.accentRed,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget productCard(Map<String, dynamic> item) {
  final p = item['products'] as Map<String, dynamic>? ?? {};

  Map<String, double>? parseContributions(dynamic c) {
    if (c is Map) {
      final map = <String, double>{};
      c.forEach((k, v) {
        if (v is num) map[k.toString()] = v.toDouble();
      });
      return map;
    }
    return null;
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ProductRecommendationCard(
      brandName: (item['brand_name'] ?? p['brand_name'] ?? '-').toString(),
      productName: (item['product_name'] ?? p['product_name'] ?? '-').toString(),
      bpomNumber: (item['bpom_number'] ?? p['bpom_number'] ?? '-').toString(),
      category: (item['category'] ?? p['category'] ?? 'sunscreen').toString(),
      usageTime: (item['usage_time'] ?? p['usage_time'] ?? '-').toString(),
      matchScore: (item['match_score'] as num?)?.toDouble() ?? 0.0,
      recommendationCategory:
          (item['recommendation_category'] ?? '').toString(),
      uvScore: (item['uv_score'] as num?)?.toDouble(),
      skinTypeScore: (item['skin_type_score'] as num?)?.toDouble(),
      activityScore: (item['activity_score'] as num?)?.toDouble(),
      skinConcernScore: (item['skin_concern_score'] as num?)?.toDouble(),
      textureScore: (item['texture_score'] as num?)?.toDouble(),
      finishScore: (item['finish_score'] as num?)?.toDouble(),
      sUv: (item['s_uv'] as num?)?.toDouble(),
      sSkin: (item['s_skin'] as num?)?.toDouble(),
      sActivity: (item['s_activity'] as num?)?.toDouble(),
      sConcern: (item['s_concern'] as num?)?.toDouble(),
      sTexture: (item['s_texture'] as num?)?.toDouble(),
      sFinish: (item['s_finish'] as num?)?.toDouble(),
      contributions: parseContributions(item['contributions']),
      spf: (item['spf'] ?? p['spf'] as num?)?.toInt(),
      paGrade: (item['pa_grade'] ?? p['pa_grade'])?.toString(),
      sunscreenType: (item['sunscreen_type'] ?? p['sunscreen_type'])?.toString(),
      texture: (item['texture'] ?? p['texture'])?.toString(),
      finish: (item['finish'] ?? p['finish'])?.toString(),
      penalty: (item['penalty'] as num?)?.toDouble() ?? 0.0,
    ),
  );
}
