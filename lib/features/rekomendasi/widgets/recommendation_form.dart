import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/ingredient_model.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/single_choice.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/multiple_choice.dart';

class RecommendationForm extends StatelessWidget {
  const RecommendationForm({super.key});

  static const List<String> _usageTimes = [
    'Pagi Hari',
    'Pagi & Malam Hari',
    'Malam Hari',
  ];

  static const List<String> _allergyStatuses = [
    'Tidak Ada Riwayat Alergi',
    'Pernah Alergi, tapi Tidak Tahu Bahannya',
    'Pernah Alergi terhadap Bahan Tertentu',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final formProvider = context.watch<RecommendationFormProvider>();

    final showAllergenForm = formProvider.selectedAllergyStatus ==
        'Pernah Alergi terhadap Bahan Tertentu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
    );
  }
}
