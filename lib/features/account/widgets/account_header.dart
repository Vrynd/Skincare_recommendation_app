import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fullName = auth.currentUser?.namaLengkap ?? 'Pengguna';
    final initials = _getInitials(fullName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 16,
      children: [
        Expanded(
          child: Text(
            'Akun Saya',
            style: context.text.headlineMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppContainer(
          width: 48,
          height: 48,
          shape: BoxShape.circle,
          opacity: 0.8,
          showBorder: false,
          showShadow: false,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              initials,
              style: context.text.titleLarge?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return 'P';
    final parts = cleanName.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
