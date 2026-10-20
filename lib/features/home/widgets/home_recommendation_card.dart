import 'dart:ui';
import 'package:recommendation_app/core/utils/product_asset_util.dart';
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
  bool _isFavorite = false;

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

  Widget _buildProductImage(
    BuildContext context,
    String productCode,
    String brand,
    Color brandColor,
    String texture,
    String? imageUrl,
  ) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildSmartPlaceholder(brandColor, texture),
      );
    }

    final assetPath = ProductAssetHelper.getAssetPath(
      productCode: productCode,
      productName: widget.product['product_name'] as String?,
    );

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildSmartPlaceholder(brandColor, texture),
      );
    }

    return _buildSmartPlaceholder(brandColor, texture);
  }

  Widget _buildSmartPlaceholder(Color brandColor, String texture) {
    final displayTexture = texture.isNotEmpty ? texture.toUpperCase() : 'SUNSCREEN';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            brandColor.withValues(alpha: 0.05),
            brandColor.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cap / Tutup botol
              Container(
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.25),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  border: Border.all(
                    color: brandColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              // Body / Badan botol sunscreen
              Container(
                width: 44,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                    top: Radius.circular(3),
                  ),
                  border: Border.all(
                    color: brandColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      size: 16,
                      color: brandColor.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayTexture,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: brandColor.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  @override
  Widget build(BuildContext context) {
    final brand = widget.product['brand_name'] as String? ?? 'Brand';
    final name =
        widget.product['product_name'] as String? ?? 'Sunscreen Product';
    final spf = widget.product['spf'] as int? ?? 30;
    final paGrade = widget.product['pa_grade'] as String? ?? 'PA+++';
    final productCode = widget.product['product_code'] as String? ?? '';
    final texture = widget.product['texture'] as String? ?? '';
    final imageUrl = widget.product['image_url'] as String?;
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            children: [
              // ── 1. Gambar Penuh / Smart Visual Placeholder ────────────
              Positioned.fill(
                child: _buildProductImage(
                  context,
                  productCode,
                  brand,
                  brandColor,
                  texture,
                  imageUrl,
                ),
              ),

              // ── 2. Gradient Scrim Halus di Bagian Bawah ───────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colors.surfaceContainerLowest
                            .withValues(alpha: 0.0),
                        context.colors.surfaceContainerLowest
                            .withValues(alpha: 0.65),
                        context.colors.surfaceContainerLowest
                            .withValues(alpha: 0.96),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      const SizedBox(height: 2),
                      Text(
                        _cleanProductName(name),
                        style: context.text.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                          height: 1.22,
                          fontSize: 11.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // ── 3. Elemen Atas: SPF/PA di Kiri & Favorit di Kanan ──────
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge SPF dan PA
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            'SPF $spf',
                            style: TextStyle(
                              color: badgeText,
                              fontWeight: FontWeight.bold,
                              fontSize: 8.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            paGrade,
                            style: TextStyle(
                              color: badgeText,
                              fontWeight: FontWeight.bold,
                              fontSize: 8.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Tombol Aksi Bookmark (Liquid Glass Effect)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _isFavorite = !_isFavorite);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          Colors.white.withValues(alpha: 0.22),
                                          Colors.white.withValues(alpha: 0.06),
                                        ]
                                      : [
                                          Colors.white.withValues(alpha: 0.70),
                                          Colors.white.withValues(alpha: 0.28),
                                        ],
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.28)
                                      : Colors.white.withValues(alpha: 0.65),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                  if (_isFavorite)
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _isFavorite
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                size: 16,
                                color: _isFavorite
                                    ? const Color(0xFFF59E0B)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : const Color(0xFF1F2937)),
                              ),
                            ),
                          ),
                        ),
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
