import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_dock_sheet.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
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
  bool _isConfirmed = false;
  SkinTypeModel? _selectedSkinType;
  List<SkinConcernModel> _selectedSkinProblems = [];
  String? _selectedUsageTime;
  String? _selectedAllergyStatus;
  List<IngredientModel> _selectedIngredients = [];

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
  String _mapUsageTime(String displayTime) {
    switch (displayTime) {
      case 'Pagi Hari':
        return 'morning_day';
      case 'Pagi & Malam Hari':
        return 'morning_and_night';
      case 'Malam Hari':
        return 'night';
      default:
        return 'morning_and_night';
    }
  }

  /// Memetakan label riwayat alergi ke format enum database Supabase
  String _mapAllergyStatus(String displayStatus) {
    switch (displayStatus) {
      case 'Tidak Ada Riwayat Alergi':
        return 'none';
      case 'Pernah Alergi, tapi Tidak Tahu Bahannya':
        return 'unknown_ingredient';
      case 'Pernah Alergi terhadap Bahan Tertentu':
        return 'known_ingredient';
      default:
        return 'none';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final showAllergenForm =
        _selectedAllergyStatus == 'Pernah Alergi terhadap Bahan Tertentu';

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const AppNavigation(),
            AppSpacing.v16,

            // Banner Error jika pemuatan opsi gagal
            if (provider.errorMessage != null && provider.skinTypes.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.colors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: context.colors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: context.colors.error,
                      onPressed: () => provider.loadFormOptions(),
                    ),
                  ],
                ),
              ),
              AppSpacing.v16,
            ],

            // 01. Pilihan Jenis Kulit (Dinamis dari Supabase)
            SingleChoice<SkinTypeModel>(
              indexNumber: '01',
              question: 'Jenis Kulit Anda',
              options: provider.skinTypes,
              selectedOption: _selectedSkinType,
              optionLabelBuilder: (type) => type.displayName,
              isLoading: provider.isLoading && provider.skinTypes.isEmpty,
              onOptionSelected: (type) {
                setState(() {
                  _selectedSkinType = type;
                  _isConfirmed = false;
                });
              },
            ),
            AppSpacing.v24,

            // 02. Pilihan Masalah Kulit (Dinamis dari Supabase)
            MultipleChoice<SkinConcernModel>(
              indexNumber: '02',
              question: 'Fokus Masalah Kulit (Pilihan Ganda)',
              options: provider.skinConcerns,
              selectedOptions: _selectedSkinProblems,
              optionLabelBuilder: (problem) => problem.displayName,
              isLoading: provider.isLoading && provider.skinConcerns.isEmpty,
              onOptionsChanged: (problems) {
                setState(() {
                  _selectedSkinProblems = problems;
                  _isConfirmed = false;
                });
              },
            ),
            AppSpacing.v24,

             // 03. Waktu Penggunaan Skincare (Statis Enum)
            SingleChoice<String>(
              indexNumber: '03',
              question: 'Waktu Penggunaan Skincare',
              options: _usageTimes,
              selectedOption: _selectedUsageTime,
              optionLabelBuilder: (time) => time,
              isLoading: provider.isLoading && provider.skinTypes.isEmpty,
              onOptionSelected: (time) {
                setState(() {
                  _selectedUsageTime = time;
                  _isConfirmed = false;
                });
              },
            ),
            AppSpacing.v24,

            // 04. Riwayat Alergi Produk (Statis Enum)
            SingleChoice<String>(
              indexNumber: '04',
              question: 'Riwayat Alergi Produk',
              options: _allergyStatuses,
              selectedOption: _selectedAllergyStatus,
              optionLabelBuilder: (status) => status,
              isLoading: provider.isLoading && provider.skinTypes.isEmpty,
              onOptionSelected: (status) {
                setState(() {
                  _selectedAllergyStatus = status;
                  if (status != 'Pernah Alergi terhadap Bahan Tertentu') {
                    _selectedIngredients = [];
                  }
                  _isConfirmed = false;
                });
              },
            ),

            // 05. Kandungan yang Dihindari / Alergen (Dinamis dari Supabase)
            if (showAllergenForm) ...[
              AppSpacing.v24,
              MultipleChoice<IngredientModel>(
                indexNumber: '05',
                question: 'Kandungan yang Dihindari (Alergen)',
                options: provider.ingredients,
                selectedOptions: _selectedIngredients,
                optionLabelBuilder: (ingredient) => ingredient.ingredientName,
                isLoading: provider.isLoading && provider.ingredients.isEmpty,
                onOptionsChanged: (ingredients) {
                  setState(() {
                    _selectedIngredients = ingredients;
                    _isConfirmed = false;
                  });
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
        switchValue: _isConfirmed,
        isButtonLoading: provider.isLoading,
        onSwitchChanged: (value) {
          final isAllergyWithIngredients =
              _selectedAllergyStatus == 'Pernah Alergi terhadap Bahan Tertentu';
          final hasInvalidAllergy =
              isAllergyWithIngredients && _selectedIngredients.isEmpty;

          if (_selectedSkinType == null ||
              _selectedSkinProblems.isEmpty ||
              _selectedUsageTime == null ||
              _selectedAllergyStatus == null ||
              hasInvalidAllergy) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Silakan lengkapi semua pilihan formulir terlebih dahulu.',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onError,
                  ),
                ),
                backgroundColor: context.colors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          setState(() {
            _isConfirmed = value;
          });
        },
        onButtonTap: () async {
          final authProvider = context.read<AuthProvider>();
          final userId = authProvider.currentUser?.idUser;
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sesi pengguna tidak ditemukan. Silakan login kembali.',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onError,
                  ),
                ),
                backgroundColor: context.colors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          // Simpan ScaffoldMessenger dan tema sebelum panggilan async untuk menghindari warning build context across async gaps
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final themeText = context.text;
          final themeColors = context.colors;

          // Kirim data formulir rekomendasi ke Supabase
          final sessionId = await provider.submitRecommendation(
            userId: userId,
            skinTypeId: _selectedSkinType!.skinTypeId,
            usageTime: _mapUsageTime(_selectedUsageTime!),
            allergyStatus: _mapAllergyStatus(_selectedAllergyStatus!),
            selectedConcernIds:
                _selectedSkinProblems.map((p) => p.skinConcernId).toList(),
            avoidedIngredientIds:
                _selectedIngredients.map((i) => i.ingredientId).toList(),
          );

          if (!context.mounted) return;

          if (sessionId != null) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Rekomendasi berhasil dibuat berdasarkan analisis kulit Anda.',
                  style: themeText.bodyMedium?.copyWith(
                    color: themeColors.onPrimary,
                  ),
                ),
                backgroundColor: themeColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );

            
            // Navigator.push(context, MaterialPageRoute(...));
          } else {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage ?? 'Gagal menyimpan rekomendasi.',
                  style: themeText.bodyMedium?.copyWith(
                    color: themeColors.onError,
                  ),
                ),
                backgroundColor: themeColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }
}

