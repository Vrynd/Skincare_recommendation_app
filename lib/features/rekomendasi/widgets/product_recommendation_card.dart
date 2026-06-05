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
  State<ProductRecommendationCard> createState() =>
      _ProductRecommendationCardState();
}

class _ProductRecommendationCardState extends State<ProductRecommendationCard> {
  bool _isExpanded = false;

  // Warna accent dinamis berdasarkan nama brand — hash deterministik (djb2-style)
  // agar distribusi warna merata dan tidak bergantung hashCode internal Dart
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

  // Icon yang menggambarkan kategori produk
  dynamic _getCategoryIcon(String cat) {
    return switch (cat.toLowerCase()) {
      'cleanser' => HugeIcons.strokeRoundedClean,
      'toner' => HugeIcons.strokeRoundedDroplet,
      'serum' => HugeIcons.strokeRoundedDroplet,
      'moisturizer' || 'moisture' => HugeIcons.strokeRoundedClean,
      'sunscreen' => HugeIcons.strokeRoundedSun02,
      _ => HugeIcons.strokeRoundedClean,
    };
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
    final categoryIcon = _getCategoryIcon(widget.category);
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
                  // Ilustrasi kategori — AppContainer generic agar opacity terkontrol
                  AppContainer(
                    width: 48,
                    height: 48,
                    color: brandColor,
                    opacity: 0.12,
                    showBorder: false,
                    showShadow: false,
                    borderRadius: BorderRadius.circular(16),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: HugeIcon(
                      icon: categoryIcon,
                      color: brandColor,
                      size: 24,
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
                  // Badge kategori — netral
                  AppContainer(
                    width: null,
                    showBorder: false,
                    showShadow: false,
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

                  // Badge tingkat kecocokan — AppContainer generic agar opacity terkontrol
                  AppContainer(
                    width: null,
                    showBorder: false,
                    showShadow: false,
                    opacity: 0.12,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    color: AppColors.success,
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
