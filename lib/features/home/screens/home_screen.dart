import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/widgets/home_greeting.dart';
import 'package:recommendation_app/features/home/widgets/home_location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeLocationProvider>().fetchLocation();
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Selamat pagi 👋';
    } else if (hour >= 12 && hour < 15) {
      return 'Selamat siang 🌤️';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore ⛅';
    } else {
      return 'Selamat malam 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
          children: [
            HomeGreeting(greeting: _getGreeting(), fullName: user?.namaLengkap),
            AppSpacing.v24,

            AppContainer(
              showShadow: false,
              color: context.colors.primaryContainer,
              borderRadius: AppRadius.br32,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HomeLocation(),
                  AppContainer(
                    height: 150,
                    borderRadius: AppRadius.br32,
                    color: AppColors.darkBackground,
                    showShadow: false,
                    // showBorder: false,
                  ),
                ],
              ),
            ),
            AppSpacing.v32,

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
    );
  }
}
