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

  @override
  void initState() {
    super.initState();
    // Memuat data opsi master dari Supabase saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().loadFormOptions();
    });
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
        child: ListView(
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
      bottomNavigationBar: AppDockSheet(
        title: 'Yakin data sudah benar?',
        description: 'Pastikan semua inputan formulir terisi dengan valid.',
        buttonTitle: 'Buat Rekomendasi',
        switchValue: formProvider.isConfirmed,
        isButtonLoading: provider.isLoading,
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
