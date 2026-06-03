import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

/// Utilitas / Komponen sistem desain untuk menampilkan SnackBar bergaya premium secara konsisten di seluruh aplikasi.
class AppSnackBar {
  AppSnackBar._();

  /// Menampilkan SnackBar sukses (berwarna hijau utama)
  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: context.colors.primary,
      textColor: context.colors.onPrimary,
      icon: Icons.check_circle_rounded,
    );
  }

  /// Menampilkan SnackBar error (berwarna merah error)
  static void showError(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: context.colors.error,
      textColor: context.colors.onError,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Menampilkan SnackBar informasi (berwarna kontainer latar dengan border tipis)
  static void showInfo(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: context.colors.surfaceContainerLowest,
      textColor: context.colors.onSurface,
      icon: Icons.info_outline_rounded,
      borderColor: context.colors.outline.withValues(alpha: 0.12),
    );
  }

  /// Logika internal untuk membangun dan memicu SnackBar mengambang (floating)
  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    Color? borderColor,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Hapus SnackBar aktif saat ini agar SnackBar baru muncul seketika tanpa antrean lambat
    scaffoldMessenger.removeCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.br16,
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        content: Row(
          children: [
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: context.text.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
