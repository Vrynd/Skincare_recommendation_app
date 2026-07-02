import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bar.dart';
import 'package:recommendation_app/core/widgets/app_dock_sheet.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_snackbar.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/history/provider/history_provider.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/recommendation_form.dart';

class CreateRecommendationScreen extends StatefulWidget {
  const CreateRecommendationScreen({super.key});

  @override
  State<CreateRecommendationScreen> createState() =>
      _CreateRecommendationScreenState();
}

class _CreateRecommendationScreenState
    extends State<CreateRecommendationScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Memuat data opsi master dari Supabase saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecommendationProvider>().loadFormOptions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      if (offset <= 40.0) {
        setState(() {
          _scrollOffset = offset;
        });
      } else if (_scrollOffset < 40.0) {
        setState(() {
          _scrollOffset = 40.0;
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

    if (!formProvider.isFormValid) {
      AppSnackBar.showError(
        context,
        'Silakan lengkapi semua pilihan formulir terlebih dahulu.',
      );
      return;
    }

    final skinType = formProvider.selectedSkinType!;
    final locationProvider = context.read<HomeLocationProvider>();
    formProvider.updateLocationAndUv(locationProvider);

    final sessionId = await provider.submitRecommendation(
      userId: userId,
      skinTypeId: skinType.skinTypeId,
      usageTime: formProvider.mappedUsageTime,
      allergyStatus: formProvider.mappedAllergyStatus,
      activity: formProvider.mappedActivity,
      texturePreference: formProvider.mappedTexture,
      finishPreference: formProvider.mappedFinish,
      selectedConcernIds: formProvider.selectedConcernIds,
      avoidedIngredientIds: const [],
      locationName: formProvider.locationName,
      latitude: formProvider.latitude,
      longitude: formProvider.longitude,
      uvIndex: formProvider.uvIndex,
      uvRiskLevel: formProvider.uvRiskLevel,
    );

    if (!mounted) return;
    if (sessionId != null) {
      // Perbarui riwayat rekomendasi di HistoryProvider agar langsung muncul
      if (mounted) {
        context.read<HistoryProvider>().loadHistory(userId);
      }
      formProvider.resetForm();
      AppSnackBar.showSuccess(
        context,
        'Rekomendasi berhasil dibuat berdasarkan analisis kulit Anda.',
      );
      // Arahkan pengguna ke layar hasil rekomendasi
      context.pushReplacement(
        '${AppRouter.recommendationResultPath}/$sessionId',
      );
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
      appBar: AppAppBar(
        title: 'Buat Rekomendasi',
        scrollOffset: _scrollOffset,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: NavigationCircleButton(
              size: 48,
              onTap: () => context.pop(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft02,
                color: context.colors.onSurface,
                size: 24,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: NavigationCircleButton(
                size: 48,
                onTap: () => formProvider.resetForm(),
                child: Icon(
                  Icons.refresh_rounded,
                  color: context.colors.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: const [
            RecommendationForm(),
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
