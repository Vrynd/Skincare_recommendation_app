import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_title.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/widgets/home_category.dart';
import 'package:recommendation_app/features/home/widgets/home_greeting.dart';
import 'package:recommendation_app/features/home/widgets/home_location.dart';
import 'package:recommendation_app/features/home/widgets/home_uv_index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Cleanser';

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
          padding: const EdgeInsets.only(top: 24, bottom: 48),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: HomeGreeting(
                greeting: _getGreeting(),
                fullName: user?.namaLengkap,
              ),
            ),
            AppSpacing.v24,

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: AppContainer(
                color: context.colors.primaryContainer,
                borderRadius: AppRadius.br32,
                padding: EdgeInsets.zero,
                showShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [const HomeLocation(), const HomeUVIndex()],
                ),
              ),
            ),
            AppSpacing.v24,

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: AppTitleAction.text(
                title: 'Rekomendasi Saya',
                actionText: 'Lihat Semua',
                onPressed: () {},
              ),
            ),
            AppSpacing.v8,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left:20),
              child: Row(
                spacing: 8,
                children: [
                  HomeCategory(
                    title: 'Cleanser',
                    count: 4,
                    isSelected: _selectedCategory == 'Cleanser',
                    onTap: () => setState(() => _selectedCategory = 'Cleanser'),
                  ),
                  HomeCategory(
                    title: 'Toner',
                    count: 2,
                    isSelected: _selectedCategory == 'Toner',
                    onTap: () => setState(() => _selectedCategory = 'Toner'),
                  ),
                  HomeCategory(
                    title: 'Serum',
                    count: 3,
                    isSelected: _selectedCategory == 'Serum',
                    onTap: () => setState(() => _selectedCategory = 'Serum'),
                  ),
                  HomeCategory(
                    title: 'Moisture',
                    count: 2,
                    isSelected: _selectedCategory == 'Moisture',
                    onTap: () => setState(() => _selectedCategory = 'Moisture'),
                  ),
                  HomeCategory(
                    title: 'Sunscreen',
                    count: 1,
                    isSelected: _selectedCategory == 'Sunscreen',
                    onTap: () =>
                        setState(() => _selectedCategory = 'Sunscreen'),
                  ),
                ],
              ),
            ),
            AppSpacing.v20,

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: AppContainer(
                height: 350,
                borderRadius: AppRadius.br32,
                showShadow: false,
                opacity: 0.8,
              ),
            )

            // // Logout button
            // AppButton.danger(
            //   title: 'Keluar',
            //   icon: HugeIcons.strokeRoundedLogout03,
            //   borderRadius: AppRadius.br32,
            //   isLoading: authProvider.isLoading,
            //   onTap: () async {
            //     await authProvider.signOut();
            //     if (context.mounted) {
            //       context.goNamed(AppRouter.loginName);
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
