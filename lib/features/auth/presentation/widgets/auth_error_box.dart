import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class AuthErrorBox extends StatelessWidget {
  final String errorMessage;

  const AuthErrorBox({super.key, required this.errorMessage});

  String _translateError(String originalError) {
    final lowerError = originalError.toLowerCase();

    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid credential') ||
        lowerError.contains('credentials do not match')) {
      return 'Ups! Surel (email) atau kata sandi yang Anda masukkan belum cocok. Silakan periksa kembali ya.';
    }

    if (lowerError.contains('user already exists') ||
        lowerError.contains('email already in use')) {
      return 'Surel ini sudah terdaftar di sistem kami. Apakah Anda ingin coba masuk saja?';
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('failed host lookup')) {
      return 'Koneksi internet Anda sedang terganggu. Silakan periksa jaringan internet Anda dan coba lagi.';
    }

    if (lowerError.contains('password') && lowerError.contains('weak')) {
      return 'Kata sandi Anda terlalu lemah. Silakan gunakan kombinasi minimal 8 karakter.';
    }

    // Default fallback yang ramah
    return 'Terjadi kendala sistem saat memproses permintaan Anda. Silakan coba kembali beberapa saat lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.error;
    final friendlyMessage = _translateError(errorMessage);

    return AppContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: AppRadius.br12,
      color: color,
      opacity: 0.08,
      showBorder: true,
      borderColor: color.withValues(alpha: 0.25),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAlertCircle,
              color: color,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              friendlyMessage,
              style: context.text.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
