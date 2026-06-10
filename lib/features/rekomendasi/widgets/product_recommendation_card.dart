import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class ProductRecommendationCard extends StatefulWidget {
  final String brandName;
  final String productName;
  final String bpomNumber;
  final String category;
  final String usageTime;
  final double matchScore;
  final String recommendationCategory;

  const ProductRecommendationCard({
    super.key,
    required this.brandName,
    required this.productName,
    required this.bpomNumber,
    required this.category,
    required this.usageTime,
    required this.matchScore,
    required this.recommendationCategory,
  });

  @override
  State<ProductRecommendationCard> createState() =>
      _ProductRecommendationCardState();
}

class _ProductRecommendationCardState extends State<ProductRecommendationCard> {
  bool _isExpanded = false;

  Color _getBrandColor(String brand) {
    const accents = [
      AppColors.accentPurple,
      AppColors.accentOrange,
      AppColors.accentPink,
      AppColors.accentIndigo,
      AppColors.accentBlue,
      AppColors.accentTeal,
      AppColors.accentAmber,
      AppColors.accentRed,
      AppColors.accentLavender,
      AppColors.accentSage,
      AppColors.accentCyan,
    ];
    int hash = 5381;
    for (final c in brand.toLowerCase().codeUnits) {
      hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
    }
    return accents[hash % accents.length];
  }

  String get _recommendationCategoryLabel {
    return switch (widget.recommendationCategory.toLowerCase()) {
      'highly_recommended' => 'Sangat Direkomendasikan',
      'recommended' => 'Direkomendasikan',
      'fairly_suitable' => 'Cukup Sesuai',
      _ => 'Sesuai',
    };
  }

  Color get _recommendationCategoryColor {
    return switch (widget.recommendationCategory.toLowerCase()) {
      'highly_recommended' => AppColors.success,
      'recommended' => AppColors.accentBlue,
      'fairly_suitable' => AppColors.accentOrange,
      _ => AppColors.info,
    };
  }

  int get _starCount {
    return switch (widget.recommendationCategory.toLowerCase()) {
      'highly_recommended' => 4,
      'recommended' => 3,
      'fairly_suitable' => 2,
      _ => 1,
    };
  }

  Widget _buildStars(BuildContext context) {
    final filled = _starCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: List.generate(4, (index) {
        final isFilled = index < filled;
        return Icon(
          Icons.star_rounded,
          color: isFilled ? AppColors.accentAmber : context.colors.onSurfaceVariant.withValues(alpha: 0.2),
          size: 18,
        );
      }),
    );
  }

  String _formatUsageTime(String time) {
    return switch (time.toLowerCase()) {
      'morning_day' => 'Pagi / Siang',
      'morning_and_night' => 'Pagi & Malam',
      'night' => 'Malam Hari',
      _ => time.replaceAll('_', ' ').split(' ').map((w) {
          if (w.isEmpty) return '';
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        }).join(' '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor(widget.brandName);
    final friendlyUsageTime = _formatUsageTime(widget.usageTime);

    return AppContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.br24,
      showShadow: false,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: AppRadius.br24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Body: brand, nama produk, ilustrasi kategori ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.brandName.toUpperCase(),
                          style: context.text.labelSmall?.copyWith(
                            color: brandColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        AppSpacing.v4,
                        Text(
                          widget.productName,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h16,
                  // Nilai skor kecocokan (e.g. 90%)
                  AppContainer(
                    width: 52,
                    height: 52,
                    color: brandColor,
                    opacity: 0.08,
                    showBorder: false,
                    showShadow: false,
                    borderRadius: BorderRadius.circular(16),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${widget.matchScore.toInt()}',
                            style: context.text.titleLarge?.copyWith(
                              color: brandColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: '%',
                            style: context.text.labelSmall?.copyWith(
                              color: brandColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider edge-to-edge: diletakkan di luar Padding, bukan di dalamnya
            const AppDivider.dashed(indent: 0, endIndent: 0, thickness: 1),

            // ── Footer: kategori (warna brand) + tingkat kecocokan ────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kategori rekomendasi
                  AppContainer(
                    width: null,
                    showBorder: false,
                    showShadow: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: _recommendationCategoryColor,
                    opacity: 0.12,
                    borderRadius: BorderRadius.circular(6),
                    child: Text(
                      _recommendationCategoryLabel.toUpperCase(),
                      style: context.text.labelSmall?.copyWith(
                        color: _recommendationCategoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
 
                  // Rating bintang
                  _buildStars(context),
                ],
              ),
            ),

            // ── Expanded: waktu penggunaan + nomor BPOM ──────────────────
            if (_isExpanded) ...[
              // Divider expanded juga edge-to-edge
              const AppDivider.dashed(indent: 0, endIndent: 0, thickness: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Waktu Penggunaan',
                          style: context.text.labelLarge?.copyWith(
                            color: context.colors.outline,
                          ),
                        ),
                        Text(
                          friendlyUsageTime,
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.v8,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nomor BPOM',
                          style: context.text.labelLarge?.copyWith(
                            color: context.colors.outline,
                          ),
                        ),
                        Text(
                          widget.bpomNumber,
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
