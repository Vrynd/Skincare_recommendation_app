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
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/history/provider/history_provider.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/location_selector_sheet.dart';
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

    final locationProvider = context.read<HomeLocationProvider>();

    // Guard: jika lokasi sedang dimuat atau izin lokasi ditolak HANYA pada mode Proteksi Hari Ini
    if (formProvider.isTodayMode) {
      if (formProvider.isCustomLocation && formProvider.isLoadingCustomLocation) {
        AppSnackBar.showError(
          context,
          'Sedang memuat data cuaca kota tujuan... Coba lagi sebentar.',
        );
        return;
      } else if (!formProvider.isCustomLocation && locationProvider.isLoading) {
        AppSnackBar.showError(
          context,
          'Menunggu data lokasi GPS... Coba lagi sebentar.',
        );
        return;
      } else if (!formProvider.isCustomLocation &&
          (locationProvider.currentPosition == null || !locationProvider.hasPermissions)) {
        AppSnackBar.showError(
          context,
          'Izin akses lokasi tidak aktif. Silakan pilih lokasi tujuan secara manual untuk melanjutkan.',
        );
        LocationSelectorSheet.show(context);
        return;
      }

      final isUvFailed = formProvider.isCustomLocation
          ? formProvider.isCustomUvError
          : locationProvider.isUvError;

      if (isUvFailed) {
        AppSnackBar.showError(
          context,
          'Layanan indeks UV sedang tidak dapat diakses. Rekomendasi hari ini tidak dapat dilanjutkan.',
        );
        return;
      }
    }

    formProvider.updateLocationAndUv(locationProvider);
    final skinType = formProvider.selectedSkinType!;

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
      mode: formProvider.isRoutineMode ? 'routine' : 'today',
      locationName: formProvider.locationName,
      latitude: formProvider.latitude,
      longitude: formProvider.longitude,
      uvIndex: formProvider.uvIndex,
      uvRiskLevel: formProvider.uvRiskLevel,
    );

    if (!mounted) return;
    if (sessionId != null) {
      // Sinkronkan mode aktif di RecommendationProvider agar Result Screen membuka tab yang sesuai
      provider.setSelectedModeIndex(formProvider.selectedModeIndex);

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

  Widget _buildModeTabSelector(
      BuildContext context, RecommendationFormProvider formProvider) {
    final selectedIndex = formProvider.selectedModeIndex;

    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: context.colors.surfaceContainerHigh.withValues(alpha: 0.8),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => formProvider.setSelectedModeIndex(0),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? context.colors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedDroplet,
                      color: selectedIndex == 0
                          ? context.colors.primary
                          : context.colors.outline,
                      size: 18,
                    ),
                    AppSpacing.h8,
                    Text(
                      'Cari Produk',
                      style: context.text.bodyMedium!.copyWith(
                        fontWeight: selectedIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedIndex == 0
                            ? context.colors.primary
                            : context.colors.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => formProvider.setSelectedModeIndex(1),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? context.colors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSun02,
                      color: selectedIndex == 1
                          ? context.colors.primary
                          : context.colors.outline,
                      size: 18,
                    ),
                    AppSpacing.h8,
                    Text(
                      'Hari Ini',
                      style: context.text.bodyMedium!.copyWith(
                        fontWeight: selectedIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedIndex == 1
                            ? context.colors.primary
                            : context.colors.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final formProvider = context.watch<RecommendationFormProvider>();

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      appBar: AppAppBar(
        title: 'Rekomendasi',
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
          children: [
            _buildModeTabSelector(context, formProvider),
            AppSpacing.v16,
            const RecommendationForm(),
          ],
        ),
      ),
      bottomNavigationBar: AppDockSheet(
        title: 'Yakin data sudah benar?',
        description: formProvider.isRoutineMode
            ? 'Pastikan preferensi pencarian rekomendasi produk terisi dengan valid.'
            : 'Pastikan data aktivitas dan preferensi hari ini sudah sesuai.',
        buttonTitle: formProvider.isRoutineMode
            ? 'Cari Rekomendasi'
            : 'Dapatkan Rekomendasi Hari Ini',
        switchValue: formProvider.isConfirmed,
        isButtonLoading: provider.isSubmitting,
        onSwitchChanged: (value) {
          if (!formProvider.isFormValid) {
            AppSnackBar.showError(
              context,
              formProvider.isTodayMode &&
                      formProvider.isNight &&
                      formProvider.selectedUsageTime == null
                  ? 'Silakan pilih waktu penggunaan sunscreen terlebih dahulu.'
                  : 'Silakan lengkapi semua pilihan formulir terlebih dahulu.',
            );
            return;
          }
          final loc = context.read<HomeLocationProvider>();
          if (formProvider.isTodayMode &&
              !formProvider.isCustomLocation &&
              (loc.currentPosition == null || !loc.hasPermissions)) {
            AppSnackBar.showError(
              context,
              'Izin akses lokasi tidak aktif. Silakan pilih lokasi tujuan secara manual untuk melanjutkan.',
            );
            LocationSelectorSheet.show(context);
            return;
          }

          final isUvFailed = formProvider.isCustomLocation
              ? formProvider.isCustomUvError
              : loc.isUvError;

          if (formProvider.isTodayMode && isUvFailed) {
            AppSnackBar.showError(
              context,
              'Layanan indeks UV sedang tidak dapat diakses. Rekomendasi hari ini tidak dapat dilanjutkan.',
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
