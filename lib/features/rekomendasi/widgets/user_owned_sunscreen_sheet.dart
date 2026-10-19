import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/rekomendasi/models/recommendation_result_model.dart';

/// Bottom Sheet untuk memilih sunscreen alternatif yang dimiliki pengguna di rumah.
/// Menyajikan produk dalam format grid 2 kolom (2x2), tanpa menampilkan persentase
/// sebelum dievaluasi, dan dilengkapi kolom pencarian instan.
class UserOwnedSunscreenSheet extends StatefulWidget {
  final List<SunscreenRecommendationItem> otherCandidates;
  final List<SunscreenRecommendationItem> allCandidates;
  final Function(SunscreenRecommendationItem) onProductSelected;

  const UserOwnedSunscreenSheet({
    super.key,
    required this.otherCandidates,
    required this.allCandidates,
    required this.onProductSelected,
  });

  static void show({
    required BuildContext context,
    required List<SunscreenRecommendationItem> otherCandidates,
    required List<SunscreenRecommendationItem> allCandidates,
    required Function(SunscreenRecommendationItem) onProductSelected,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    AppBottomSheet.show(
      context: context,
      showHandle: true,
      wrapInScrollView: false,
      height: screenHeight * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: UserOwnedSunscreenSheet(
        otherCandidates: otherCandidates,
        allCandidates: allCandidates,
        onProductSelected: onProductSelected,
      ),
    );
  }

  @override
  State<UserOwnedSunscreenSheet> createState() =>
      _UserOwnedSunscreenSheetState();
}

class _UserOwnedSunscreenSheetState extends State<UserOwnedSunscreenSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SunscreenRecommendationItem> get _currentDisplayProducts {
    final pool = widget.otherCandidates.isNotEmpty
        ? widget.otherCandidates
        : widget.allCandidates;

    if (_searchQuery.isNotEmpty) {
      // Pencarian di seluruh produk yang tersedia
      return widget.allCandidates.where((item) {
        final name = item.productName.toLowerCase();
        final brand = item.brandName.toLowerCase();
        return name.contains(_searchQuery) || brand.contains(_searchQuery);
      }).toList();
    }

    return pool;
  }

  @override
  Widget build(BuildContext context) {
    final products = _currentDisplayProducts;
    final isSearching = _searchQuery.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Judul & Keterangan (Fixed) ──────────────────────────────────
        Text(
          'Pilih Sunscreen yang Anda Miliki',
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        AppSpacing.v4,
        Text(
          'Pilih sunscreen yang Anda miliki di rumah untuk mengetahui tingkat kecocokannya dengan kondisi kulit dan cuaca hari ini.',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.outline,
            height: 1.4,
          ),
        ),
        AppSpacing.v16,

        // ── Kolom Cari Cepat (Fixed) ───────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: AppRadius.br16,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.15),
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: context.text.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Cari merk atau nama produk sunscreen...',
              hintStyle: context.text.bodyMedium?.copyWith(
                color: context.colors.outline,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.colors.outline,
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        AppSpacing.v16,

        // ── Header Seksi (Fixed) ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSearching
                  ? 'HASIL PENCARIAN (${products.length})'
                  : 'PILIHAN SUNSCREEN (${products.length})',
              style: context.text.labelSmall?.copyWith(
                color: context.colors.outline,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        AppSpacing.v12,

        // ── Grid Produk (Scrollable, Mengisi sisa ruang ke bawah) ───────
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Sunscreen tidak ditemukan.\nCoba ketik kata kunci merk lainnya.',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return _ProductGridCardItem(
                      item: item,
                      onTap: () {
                        widget.onProductSelected(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ProductGridCardItem extends StatefulWidget {
  final SunscreenRecommendationItem item;
  final VoidCallback onTap;

  const _ProductGridCardItem({
    required this.item,
    required this.onTap,
  });

  @override
  State<_ProductGridCardItem> createState() => _ProductGridCardItemState();
}

class _ProductGridCardItemState extends State<_ProductGridCardItem> {
  bool _isHovered = false;

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
    final item = widget.item;
    final brandColor = _getBrandColor(item.brandName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = isDark ? const Color(0xFF3F2D0B) : const Color(0xFFFEF3C7);
    final badgeText =
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

    final borderColor = _isHovered
        ? brandColor
        : context.colors.outline.withValues(alpha: 0.2);

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
      borderRadius: AppRadius.br16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.br16,
          border: Border.all(
            color: borderColor,
            width: _isHovered ? 1.6 : 1.2,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris atas: Nama Brand dengan warna Brand (tanpa ikon)
            Text(
              item.brandName.toUpperCase(),
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
            // Nama Produk tanpa SPF & PA yang redundan
            Expanded(
              child: Text(
                _cleanProductName(item.productName),
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
            // Badge SPF · PA dan Tekstur
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'SPF ${item.spf} · ${item.paGrade}',
                    style: TextStyle(
                      color: badgeText,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                if (item.texture != null && item.texture!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '· ${item.texture}',
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.outline,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
