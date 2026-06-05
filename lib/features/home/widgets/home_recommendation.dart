import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_separator.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/rekomendasi/models/recommendation_model.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/account/widgets/confirm_sheet.dart';

class HomeRecommendation extends StatelessWidget {
  final RecommendationModel recommendation;

  const HomeRecommendation({
    super.key,
    required this.recommendation,
  });

  // Hash deterministik — sama dengan ProductRecommendationCard agar konsisten
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

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString();
    final month = months[dt.month - 1];
    final year = dt.year;
    return '$day $month $year';
  }

  void _tapToDelete(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.idUser;
    if (userId == null) return;

    ConfirmSheet.show(
      context: context,
      title: 'Hapus Riwayat',
      description:
          'Apakah Anda yakin ingin menghapus rekomendasi produk ini dari riwayat Anda?',
      confirmText: 'Ya, Hapus',
      isDanger: true,
      icon: HugeIcons.strokeRoundedDelete02,
      onConfirm: () async {
        final provider = context.read<RecommendationProvider>();
        await provider.deleteRecommendation(
          recommendation.resultId,
          userId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor(recommendation.brandName);
    return AppContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.br32,
      opacity: 0.6,
      showShadow: false,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    recommendation.category.toUpperCase(),
                    style: context.text.bodyLarge?.copyWith(
                      color: context.colors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: AppContainer(
                borderRadius: AppRadius.br32,
                showBorder: false,
                showShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              '${recommendation.createdAt.hour}:${recommendation.createdAt.minute.toString().padLeft(2, '0')}',
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.outline,
                              ),
                            ),
                            AppSeparator.small(),
                            Text(
                              _formatDate(recommendation.createdAt),
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.outline,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _tapToDelete(context),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedMoreHorizontal,
                              size: 20,
                              color: context.colors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  AppSpacing.v8,
                  Text(
                    recommendation.productName,
                    style: context.text.titleMedium?.copyWith(
                      color: context.colors.onSurface,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  AppSpacing.v8,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: brandColor.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          recommendation.brandName,
                          style: context.text.labelMedium?.copyWith(
                            color: brandColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
