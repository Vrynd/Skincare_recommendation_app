import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class HomeRecommendationCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final double? width;

  const HomeRecommendationCard({
    super.key,
    required this.product,
    this.width = double.infinity,
  });

  Color _getBrandColor(String brandName) {
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
    for (final c in brandName.toLowerCase().codeUnits) {
      hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
    }
    return accents[hash % accents.length];
  }

  @override
  Widget build(BuildContext context) {
    final brand = product['brand_name'] as String? ?? 'Brand';
    final name = product['product_name'] as String? ?? 'Sunscreen Product';
    final spf = product['spf'] as int? ?? 30;
    final paGrade = product['pa_grade'] as String? ?? 'PA+++';
    final brandColor = _getBrandColor(brand);

    return AppContainer(
      width: width,
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.br24,
      opacity: 0.8,
      showShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        brand.toUpperCase(),
                        style: context.text.labelSmall?.copyWith(
                          color: brandColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSun02,
                      color: context.colors.primary,
                      size: 20,
                    ),
                  ],
                ),
                AppSpacing.v12,
                Text(
                  name,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SPF $spf $paGrade',
                    style: context.text.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
