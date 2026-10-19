import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class HomeRecommendationCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;

  const HomeRecommendationCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<HomeRecommendationCard> createState() => _HomeRecommendationCardState();
}

class _HomeRecommendationCardState extends State<HomeRecommendationCard> {
  bool _isHovered = false;

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

  String _cleanProductName(String name) {
    final regex = RegExp(
      r'\s*(?:SPF\s*\d+\+?|\bPA\+{1,4}\b).*$',
      caseSensitive: false,
    );
    final cleaned = name.replaceAll(regex, '').trim();
    return cleaned.isNotEmpty ? cleaned : name;
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.product['brand_name'] as String? ?? 'Brand';
    final name =
        widget.product['product_name'] as String? ?? 'Sunscreen Product';
    final spf = widget.product['spf'] as int? ?? 30;
    final paGrade = widget.product['pa_grade'] as String? ?? 'PA+++';
    final brandColor = _getBrandColor(brand);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = isDark ? const Color(0xFF3F2D0B) : const Color(0xFFFEF3C7);
    final badgeText =
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

    final defaultBgColor =
        context.colors.surfaceContainerLowest.withValues(alpha: 0.85);
    final defaultBorderColor = context.colors.surfaceContainerLowest;

    final borderColor = _isHovered ? brandColor : defaultBorderColor;

    return InkWell(
      onTap: widget.onTap,
      onHover: (hovered) {
        if (_isHovered != hovered) {
          setState(() => _isHovered = hovered);
        }
      },
      onHighlightChanged: (highlighted) {
        if (_isHovered != highlighted) {
          setState(() => _isHovered = highlighted);
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      borderRadius: AppRadius.br24,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: defaultBgColor,
          borderRadius: AppRadius.br24,
          border: Border.all(
            color: borderColor,
            width: _isHovered ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris atas: Nama Brand dengan warna Brand
            Text(
              brand.toUpperCase(),
              style: context.text.labelSmall?.copyWith(
                color: brandColor,
                fontWeight: FontWeight.bold,
                fontSize: 9.5,
                letterSpacing: 0.8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Nama Produk tanpa SPF & PA redundan
            Expanded(
              child: Text(
                _cleanProductName(name),
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            // Badge SPF dan PA terpisah
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'SPF $spf',
                    style: TextStyle(
                      color: badgeText,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    paGrade,
                    style: TextStyle(
                      color: badgeText,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
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
