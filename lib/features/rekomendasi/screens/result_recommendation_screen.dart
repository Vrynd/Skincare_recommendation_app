import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_dock_sheet.dart';
import 'package:recommendation_app/core/widgets/app_empty_state.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';

class ResultRecommendationScreen extends StatefulWidget {
  final String sessionId;

  const ResultRecommendationScreen({super.key, required this.sessionId});

  @override
  State<ResultRecommendationScreen> createState() =>
      _ResultRecommendationScreenState();
}

class _ResultRecommendationScreenState
    extends State<ResultRecommendationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecommendationProvider>().loadSessionResults(
          widget.sessionId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            AppNavigation(
              title: 'Hasil Rekomendasi',
              showBackButton: true,
              onBackTap: () => context.go(AppRouter.homePath),
            ),
            AppSpacing.v16,

            if (provider.isLoading) ...[
              const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (provider.errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    AppSpacing.v16,
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge,
                    ),
                    AppSpacing.v24,
                    ElevatedButton(
                      onPressed: () {
                        context.read<RecommendationProvider>().loadSessionResults(
                          widget.sessionId,
                        );
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const AppEmptyState(
                icon: HugeIcons.strokeRoundedAlertCircle,
                title: 'Produk Belum Tersedia',
                description:
                    'Rekomendasi produk berdasarkan tipe kulit dan masalah kulit Anda belum tersedia di sistem.',
                height: 200,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: AppDockSheet(
        title: 'Selesai Analisis?',
        description: 'Kembali ke halaman utama.',
        buttonTitle: 'Kembali ke Beranda',
        showSwitch: false,
        onButtonTap: () => context.go(AppRouter.homePath),
      ),
    );
  }
}
