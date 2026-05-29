import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header greeting
              AppContainer.card(
                borderRadius: AppRadius.br24,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.primary.withValues(alpha: .12),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(user?.namaLengkap ?? 'U'),
                          style: context.text.titleLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Greeting text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang! 👋',
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.namaLengkap ?? 'Pengguna',
                            style: context.text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.onSurface,
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

              AppSpacing.v24,

              // Info card
              AppContainer.card(
                borderRadius: AppRadius.br24,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64,
                      color: context.colors.primary,
                    ),
                    AppSpacing.v16,
                    Text(
                      'Autentikasi Berhasil!',
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.onSurface,
                      ),
                    ),
                    AppSpacing.v8,
                    Text(
                      'Anda berhasil masuk ke aplikasi.\nHalaman ini adalah placeholder untuk fitur Home.',
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    AppSpacing.v8,
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Logout button
              AppButton.danger(
                title: 'Keluar',
                icon: HugeIcons.strokeRoundedLogout03,
                borderRadius: AppRadius.br32,
                isLoading: authProvider.isLoading,
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    context.goNamed(AppRouter.loginName);
                  }
                },
              ),
              AppSpacing.v16,
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
