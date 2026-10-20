import 'package:flutter/material.dart';

/// Utilitas untuk mengelola dan memetakan aset gambar produk sunscreen lokal (`assets/products/`).
///
/// Memetakan `product_code` (misal: S001 -> 'assets/products/produk_01.png', S023 -> 'assets/products/produk_23.png')
/// secara deterministik dan mendukung fallback pencocokan nama produk jika kode belum tersedia.
class ProductAssetHelper {
  ProductAssetHelper._();

  /// Mengembalikan path asset lokal (misal: `assets/products/produk_01.png`)
  /// berdasarkan [productCode] atau [productName].
  static String? getAssetPath({
    String? productCode,
    String? productName,
  }) {
    // 1. Prioritas: Cek kode produk (contoh: S001, S023, s1, produk_01)
    if (productCode != null && productCode.trim().isNotEmpty) {
      final trimmed = productCode.trim();

      // Ekstrak angka dari string kode
      final match = RegExp(r'\d+').firstMatch(trimmed);
      if (match != null) {
        final intVal = int.tryParse(match.group(0)!);
        if (intVal != null && intVal >= 1 && intVal <= 99) {
          final formatted = intVal.toString().padLeft(2, '0');
          return 'assets/products/produk_$formatted.png';
        }
      }
    }

    // 2. Fallback: Cocokkan melalui nama produk / kata kunci brand
    if (productName != null && productName.trim().isNotEmpty) {
      final nameLower = productName.trim().toLowerCase();
      for (final entry in _nameKeywordsToAsset.entries) {
        if (nameLower.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    return null;
  }

  /// Peta kata kunci nama produk ke berkas asset produk 01 - 30
  static const Map<String, String> _nameKeywordsToAsset = {
    'wardah uv shield aqua fresh': 'assets/products/produk_01.png',
    'hydrasoothe': 'assets/products/produk_02.png',
    'madagascar centella': 'assets/products/produk_03.png',
    'biore uv aqua rich': 'assets/products/produk_04.png',
    'healthy matte': 'assets/products/produk_05.png',
    'carasun': 'assets/products/produk_05.png',
    'erha perfect shield': 'assets/products/produk_06.png',
    'holyshield': 'assets/products/produk_07.png',
    'extra protect oil control': 'assets/products/produk_08.png',
    'light matte sun stick': 'assets/products/produk_09.png',
    'banana boat': 'assets/products/produk_10.png',
    'sport ultra': 'assets/products/produk_10.png',
    'skintific 5x ceramide': 'assets/products/produk_11.png',
    'uv moisture milk': 'assets/products/produk_12.png',
    'copy paste tinted': 'assets/products/produk_13.png',
    'the originote ceramella': 'assets/products/produk_14.png',
    'uv whitening milk': 'assets/products/produk_15.png',
    'uv mild milk': 'assets/products/produk_16.png',
    'uv tone up essence': 'assets/products/produk_17.png',
    'facetology': 'assets/products/produk_18.png',
    'anessa': 'assets/products/produk_19.png',
    'neutrogena': 'assets/products/produk_20.png',
    'acnes derma care': 'assets/products/produk_21.png',
    'labore': 'assets/products/produk_22.png',
    'biomeprotect': 'assets/products/produk_22.png',
    'emina sun battle': 'assets/products/produk_23.png',
    'sun battle': 'assets/products/produk_23.png',
    'wardah uv shield physical': 'assets/products/produk_24.png',
    'dear me beauty': 'assets/products/produk_25.png',
    'amaterasun physical sunscreen': 'assets/products/produk_26.png',
    '100% physical': 'assets/products/produk_27.png',
    'pore blurring': 'assets/products/produk_28.png',
    'uvmune 400': 'assets/products/produk_29.png',
    'la roche-posay': 'assets/products/produk_29.png',
    'airy smooth': 'assets/products/produk_30.png',
  };

  /// Widget helper untuk memuat gambar produk dengan error builder cerdas
  static Widget buildImage({
    String? productCode,
    String? productName,
    String? imageUrl,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    // 1. Jika ada URL internet
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    // 2. Jika ada berkas asset lokal produk
    final assetPath = getAssetPath(
      productCode: productCode,
      productName: productName,
    );

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    // 3. Fallback jika tidak ditemukan
    if (errorBuilder != null) {
      return Builder(
        builder: (context) => errorBuilder(
          context,
          'Product asset not found',
          null,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
