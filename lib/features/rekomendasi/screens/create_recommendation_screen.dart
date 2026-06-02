import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_dock_sheet.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
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
  String? _selectedSkinType;
  List<String> _selectedSkinProblems = [];
  String? _selectedUsageTime;
  String? _selectedAllergyStatus;
  List<String> _selectedIngredients = [];

  final List<String> _skinTypes = [
    'Kulit Berminyak',
    'Kulit Kering',
    'Kulit Kombinasi',
    'Kulit Normal',
    'Kulit Sensitif',
  ];

  final List<String> _skinProblems = [
    'Masalah Jerawat',
    'Komedo & Pori-pori',
    'Flek Hitam',
    'Kulit Kusam',
    'Kemerahan & Iritasi',
    'Kulit Dehidrasi',
    'Kerutan & Garis Halus',
    'Warna Kulit Tidak Merata',
    'Sensitivitas Tinggi',
  ];

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

  final List<String> _ingredients = [
    'Salicylic Acid (BHA)',
    'Retinol (Vitamin A)',
    'Niacinamide (Vitamin B3)',
    'Vitamin C (L-Ascorbic Acid)',
    'Centella Asiatica (Cica)',
    'Tea Tree Oil',
    'Fragrance (Pewangi)',
    'Alcohol Denat (Alkohol)',
  ];

  @override
  Widget build(BuildContext context) {
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

            // 01. Pilihan Jenis Kulit (Single Choice)
            SingleChoice<String>(
              indexNumber: '01',
              question: 'Jenis Kulit Anda',
              options: _skinTypes,
              selectedOption: _selectedSkinType,
              optionLabelBuilder: (type) => type,
              onOptionSelected: (type) {
                setState(() {
                  _selectedSkinType = type;
                  _isConfirmed = false;
                });
              },
            ),
            AppSpacing.v24,

            // 02. Pilihan Masalah Kulit (Multiple Choice)
            MultipleChoice<String>(
              indexNumber: '02',
              question: 'Fokus Masalah Kulit (Pilihan Ganda)',
              options: _skinProblems,
              selectedOptions: _selectedSkinProblems,
              optionLabelBuilder: (problem) => problem,
              onOptionsChanged: (problems) {
                setState(() {
                  _selectedSkinProblems = problems;
                  _isConfirmed = false;
                });
              },
            ),
            AppSpacing.v24,

            // 03. Waktu Penggunaan Skincare (Single Choice)
            SingleChoice<String>(
              indexNumber: '03',
              question: 'Waktu Penggunaan Skincare',
              options: _usageTimes,
              selectedOption: _selectedUsageTime,
              optionLabelBuilder: (time) => time,
              onOptionSelected: (time) {
                setState(() {
                  _selectedUsageTime = time;
                  _isConfirmed = false;
                });
              },
            ),
            AppSpacing.v24,

            // 04. Riwayat Alergi Produk (Single Choice)
            SingleChoice<String>(
              indexNumber: '04',
              question: 'Riwayat Alergi Produk',
              options: _allergyStatuses,
              selectedOption: _selectedAllergyStatus,
              optionLabelBuilder: (status) => status,
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

            // 05. Kandungan yang Dihindari / Alergen (Multiple Choice - Kondisional)
            if (showAllergenForm) ...[
              AppSpacing.v24,
              MultipleChoice<String>(
                indexNumber: '05',
                question: 'Kandungan yang Dihindari (Alergen)',
                options: _ingredients,
                selectedOptions: _selectedIngredients,
                optionLabelBuilder: (ingredient) => ingredient,
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
        onButtonTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rekomendasi berhasil dibuat berdasarkan analisis kulit Anda.',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onPrimary,
                ),
              ),
              backgroundColor: context.colors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
