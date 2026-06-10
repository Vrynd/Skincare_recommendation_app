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
    showDivider: i < 4,
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
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ProductRecommendationCard(
      brandName: p['brand_name'] as String? ?? '-',
      productName: p['product_name'] as String? ?? '-',
      bpomNumber: p['bpom_number'] as String? ?? '-',
      category: p['category'] as String? ?? '-',
      usageTime: p['usage_time'] as String? ?? '-',
      matchScore: (item['match_score'] as num?)?.toDouble() ?? 0,
      recommendationCategory: item['recommendation_category'] as String? ?? '',
    ),
  );
}
