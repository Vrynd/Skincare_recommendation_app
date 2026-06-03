import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_dock_sheet.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_snackbar.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/ingredient_model.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/single_choice.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/multiple_choice.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';

class CreateRecommendationScreen extends StatefulWidget {
  const CreateRecommendationScreen({super.key});

  @override
  State<CreateRecommendationScreen> createState() =>
      _CreateRecommendationScreenState();
}

class _CreateRecommendationScreenState
    extends State<CreateRecommendationScreen> {
  final List<String> _usageTimes = [
    'Pagi Hari',
    'Pagi & Malam Hari',
    'Malam Hari',
  ];

  final List<String> _allergyStatuses = [
    'Tidak Ada Riwayat Alergi',
    'Pernah Alergi, tapi Tidak Tahu Bahannya',
    'Pernah Alergi terhadap Bahan Tertentu',
  ];

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

  /// Memetakan label waktu penggunaan ke format enum database Supabase
  String _mapUsageTime(String displayTime) => switch (displayTime) {
    'Pagi Hari' => 'morning_day',
    'Pagi & Malam Hari' => 'morning_and_night',
    'Malam Hari' => 'night',
    _ => 'morning_and_night',
  };

  /// Memetakan label riwayat alergi ke format enum database Supabase
  String _mapAllergyStatus(String displayStatus) => switch (displayStatus) {
    'Tidak Ada Riwayat Alergi' => 'none',
    'Pernah Alergi, tapi Tidak Tahu Bahannya' => 'unknown_ingredient',
    'Pernah Alergi terhadap Bahan Tertentu' => 'known_ingredient',
    _ => 'none',
  };

  /// Memetakan tingkat risiko UV dari enum model ke string enum database
  String _mapUvRiskLevel(UVRiskLevel level) => switch (level) {
        UVRiskLevel.low => 'low',
        UVRiskLevel.moderate => 'moderate',
        UVRiskLevel.high => 'high',
        UVRiskLevel.veryHigh => 'very_high',
        UVRiskLevel.extreme => 'extreme',
      };

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

    // 1. Ambil data lokasi & indeks UV terintegrasi dari HomeLocationProvider
    final locationProvider = context.read<HomeLocationProvider>();
    final position = locationProvider.currentPosition;
    final locationName = locationProvider.readableAddress;

    // Set ke null jika statusnya masih berupa placeholder pencarian awal
    final isSearching = locationName == 'Mencari lokasi...' || locationName == 'Gagal memuat lokasi';
    final actualLocationName = isSearching ? null : locationName;

    // 2. Kirim data formulir beserta informasi cuaca/lokasi yang terdeteksi
    final sessionId = await provider.submitRecommendation(
      userId: userId,
      skinTypeId: skinType.skinTypeId,
      usageTime: _mapUsageTime(usageTime),
      allergyStatus: _mapAllergyStatus(allergyStatus),
      selectedConcernIds: formProvider.selectedSkinProblems
          .map((p) => p.skinConcernId)
          .toList(),
      avoidedIngredientIds: formProvider.selectedIngredients
          .map((i) => i.ingredientId)
          .toList(),
      locationName: actualLocationName,
      latitude: position?.latitude,
      longitude: position?.longitude,
      uvIndex: locationProvider.uvIndex,
      uvRiskLevel: _mapUvRiskLevel(locationProvider.uvRiskLevel),
    );

    if (!mounted) return;
    if (sessionId != null) {
      formProvider.resetForm();
      AppSnackBar.showSuccess(
        context,
        'Rekomendasi berhasil dibuat berdasarkan analisis kulit Anda.',
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

    final showAllergenForm =
        formProvider.selectedAllergyStatus ==
        'Pernah Alergi terhadap Bahan Tertentu';

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Formulir Utama
            Positioned.fill(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  // AppNavigation utama yang ikut bergeser ke atas saat scroll
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

                  SingleChoice<SkinTypeModel>(
                    indexNumber: '01',
                    question: 'Jenis Kulit Anda',
                    options: provider.skinTypes,
                    selectedOption: formProvider.selectedSkinType,
                    optionLabelBuilder: (type) => type.displayName,
                    isLoading: provider.isLoading && provider.skinTypes.isEmpty,
                    onOptionSelected: (type) {
                      formProvider.setSelectedSkinType(type);
                    },
                  ),
                  AppSpacing.v16,

                  MultipleChoice<SkinConcernModel>(
                    indexNumber: '02',
                    question: 'Fokus Masalah Kulit (Pilihan Ganda)',
                    options: provider.skinConcerns,
                    selectedOptions: formProvider.selectedSkinProblems,
                    optionLabelBuilder: (problem) => problem.displayName,
                    isLoading: provider.isLoading && provider.skinConcerns.isEmpty,
                    onOptionsChanged: (problems) {
                      formProvider.setSelectedSkinProblems(problems);
                    },
                  ),
                  AppSpacing.v16,

                  SingleChoice<String>(
                    indexNumber: '03',
                    question: 'Waktu Penggunaan Skincare',
                    options: _usageTimes,
                    selectedOption: formProvider.selectedUsageTime,
                    optionLabelBuilder: (time) => time,
                    isLoading: provider.isLoading && provider.skinTypes.isEmpty,
                    onOptionSelected: (time) {
                      formProvider.setSelectedUsageTime(time);
                    },
                  ),
                  AppSpacing.v16,

                  SingleChoice<String>(
                    indexNumber: '04',
                    question: 'Riwayat Alergi Produk',
                    options: _allergyStatuses,
                    selectedOption: formProvider.selectedAllergyStatus,
                    optionLabelBuilder: (status) => status,
                    isLoading: provider.isLoading && provider.skinTypes.isEmpty,
                    onOptionSelected: (status) {
                      formProvider.setSelectedAllergyStatus(status);
                    },
                  ),

                  if (showAllergenForm) ...[
                    AppSpacing.v24,
                    MultipleChoice<IngredientModel>(
                      indexNumber: '05',
                      question: 'Kandungan yang Dihindari (Alergen)',
                      options: provider.ingredients,
                      selectedOptions: formProvider.selectedIngredients,
                      optionLabelBuilder: (ingredient) => ingredient.ingredientName,
                      isLoading: provider.isLoading && provider.ingredients.isEmpty,
                      onOptionsChanged: (ingredients) {
                        formProvider.setSelectedIngredients(ingredients);
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Sticky Header Glassmorphism (Turun dari atas saat di-scroll)
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.colors.lightBackground.withValues(alpha: 0.85),
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
