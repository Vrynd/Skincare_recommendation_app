import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_dock_sheet.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_snackbar.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/recommendation_form.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';

class CreateRecommendationScreen extends StatefulWidget {
  const CreateRecommendationScreen({super.key});

  @override
  State<CreateRecommendationScreen> createState() =>
      _CreateRecommendationScreenState();
}

class _CreateRecommendationScreenState
    extends State<CreateRecommendationScreen> {
  late ScrollController _scrollController;
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    // Memuat data opsi master dari Supabase saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().loadFormOptions();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    const threshold = 40.0;
    if (_scrollController.hasClients) {
      final isScrolled = _scrollController.offset > threshold;
      if (isScrolled != _showStickyHeader) {
        setState(() {
          _showStickyHeader = isScrolled;
        });
      }
    }
  }

  Future<void> _tapToRecommendation() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.idUser;
    if (userId == null) {
      AppSnackBar.showError(
        context,
        'Sesi pengguna tidak ditemukan. Silakan login kembali.',
      );
      return;
    }

    final provider = context.read<RecommendationProvider>();
    final formProvider = context.read<RecommendationFormProvider>();

    final skinType = formProvider.selectedSkinType;
    final usageTime = formProvider.selectedUsageTime;
    final allergyStatus = formProvider.selectedAllergyStatus;
    if (skinType == null || usageTime == null || allergyStatus == null) {
      AppSnackBar.showError(
        context,
        'Silakan lengkapi semua pilihan formulir terlebih dahulu.',
      );
      return;
    }

    final locationProvider = context.read<HomeLocationProvider>();
    formProvider.updateLocationAndUv(locationProvider);

    final sessionId = await provider.submitRecommendation(
      userId: userId,
      skinTypeId: skinType.skinTypeId,
      usageTime: formProvider.mappedUsageTime,
      allergyStatus: formProvider.mappedAllergyStatus,
      selectedConcernIds: formProvider.selectedSkinProblems
          .map((p) => p.skinConcernId)
          .toList(),
      avoidedIngredientIds: formProvider.selectedIngredients
          .map((i) => i.ingredientId)
          .toList(),
      locationName: formProvider.locationName,
      latitude: formProvider.latitude,
      longitude: formProvider.longitude,
      uvIndex: formProvider.uvIndex,
      uvRiskLevel: formProvider.uvRiskLevel,
    );

    if (!mounted) return;
    if (sessionId != null) {
      formProvider.resetForm();
      AppSnackBar.showSuccess(
        context,
        'Rekomendasi berhasil dibuat berdasarkan analisis kulit Anda.',
      );
      // Arahkan pengguna ke layar hasil rekomendasi
      context.pushReplacement('${AppRouter.recommendationResultPath}/$sessionId');
    } else {
      AppSnackBar.showError(
        context,
        provider.errorMessage ?? 'Gagal menyimpan rekomendasi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final formProvider = context.watch<RecommendationFormProvider>();

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  AppNavigation(
                    rightAction: NavigationCircleButton(
                      size: 48,
                      onTap: () => formProvider.resetForm(),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: context.colors.onSurface,
                        size: 22,
                      ),
                    ),
                  ),
                  AppSpacing.v16,
                  const RecommendationForm(),
                ],
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: _showStickyHeader ? 0 : -80,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.lightBackground.withValues(
                        alpha: 0.85,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: context.colors.outline.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    child: AppNavigation(
                      seamless: true,
                      rightAction: NavigationCircleButton(
                        size: 48,
                        seamless: true,
                        onTap: () => formProvider.resetForm(),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: context.colors.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppDockSheet(
        title: 'Yakin data sudah benar?',
        description: 'Pastikan semua inputan formulir terisi dengan valid.',
        buttonTitle: 'Buat Rekomendasi',
        switchValue: formProvider.isConfirmed,
        isButtonLoading: provider.isSubmitting,
        onSwitchChanged: (value) {
          if (!formProvider.isFormValid) {
            AppSnackBar.showError(
              context,
              'Silakan lengkapi semua pilihan formulir terlebih dahulu.',
            );
            return;
          }
          formProvider.setIsConfirmed(value);
        },
        onButtonTap: _tapToRecommendation,
      ),
    );
  }
}
