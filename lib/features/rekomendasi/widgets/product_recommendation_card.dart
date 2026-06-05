import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
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

  const ProductRecommendationCard({
    super.key,
    required this.brandName,
    required this.productName,
    required this.bpomNumber,
    required this.category,
    required this.usageTime,
    required this.matchScore,
  });

  @override
  State<ProductRecommendationCard> createState() => _ProductRecommendationCardState();
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
    final index = brand.hashCode.abs() % accents.length;
    return accents[index];
  }

  String _formatUsageTime(String time) {
    switch (time.toLowerCase()) {
      case 'morning_day':
        return 'Pagi / Siang';
      case 'morning_and_night':
        return 'Pagi & Malam';
      case 'night':
        return 'Malam Hari';
      default:
        return time.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
    }
  }

  dynamic _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'cleanser':
        return HugeIcons.strokeRoundedClean;
      case 'toner':
        return HugeIcons.strokeRoundedDroplet;
      case 'serum':
        return HugeIcons.strokeRoundedDroplet;
      case 'moisturizer':
      case 'moisture':
        return HugeIcons.strokeRoundedClean;
      case 'sunscreen':
        return HugeIcons.strokeRoundedSun02;
      default:
        return HugeIcons.strokeRoundedClean;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor(widget.brandName);
    final friendlyUsageTime = _formatUsageTime(widget.usageTime);
    final categoryIcon = _getCategoryIcon(widget.category);

    return AppContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.br24,
      showShadow: false, // Hilangkan shadow
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: AppRadius.br24,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Baris 1: Body ──────────────────────────────────────────
              Row(
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
                  AppContainer.flat(
                    width: 48,
                    height: 48,
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: HugeIcon(
                        icon: categoryIcon,
                        color: context.colors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.v12,
              // ── Pembatas putus-putus ───────────────────────────────────
              const AppDivider.dashed(indent: 0, endIndent: 0, thickness: 1),
              AppSpacing.v12,

              // ── Baris 2: Footer ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge Kategori
                  AppContainer.flat(
                    width: null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: context.colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                    child: Text(
                      widget.category.toUpperCase(),
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Badge Skor Kecocokan
                  AppContainer.flat(
                    width: null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    child: Text(
                      '${widget.matchScore.toInt()}% Cocok',
                      style: context.text.labelMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Bagian Expanded ───────────────────────────────────────
              if (_isExpanded) ...[
                AppSpacing.v12,
                const AppDivider.dashed(indent: 0, endIndent: 0, thickness: 1),
                AppSpacing.v12,
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
            ],
          ),
        ),
      ),
    );
  }
}
