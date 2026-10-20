import 'package:recommendation_app/core/utils/product_asset_util.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class HistoryTile extends StatelessWidget {
  final String time;
  final String label;
  final String title;
  final String? productCode;
  final VoidCallback? onTap;
  final VoidCallback? onTapMore;

  const HistoryTile({
    super.key,
    required this.time,
    required this.label,
    required this.title,
    this.productCode,
    this.onTap,
    this.onTapMore,
  });

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

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor(label);

    return AppContainer(
      padding: EdgeInsets.zero,
      opacity: 0.8,
      showShadow: false,
      borderRadius: AppRadius.br24,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.br24,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: brandColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ProductAssetHelper.buildImage(
                  productCode: productCode,
                  productName: title,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      size: 22,
                      color: brandColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              label.toUpperCase(),
                              style: context.text.labelSmall?.copyWith(
                                color: brandColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '•',
                              style: context.text.labelSmall?.copyWith(
                                color: context.colors.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              time,
                              style: context.text.labelMedium?.copyWith(
                                color: context.colors.outline,
                              ),
                            ),
                          ],
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTapMore,
                            borderRadius: BorderRadius.circular(100),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 0.0,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedMoreHorizontal,
                                size: 18,
                                color: context.colors.outline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
