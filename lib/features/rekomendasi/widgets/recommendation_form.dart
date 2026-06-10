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

  static const List<String> _activities = [
    'Dalam Ruangan (Indoor)',
    'Luar Ruangan Ringan',
    'Luar Ruangan Intens',
    'Olahraga / Sport',
    'Berenang / Aktivitas Air',
  ];

  static const List<String> _textures = [
    'Gel',
    'Cream',
    'Lotion',
    'Serum',
    'Milk',
    'Watery',
    'Stick',
    'Spray',
    'Mist',
  ];

  static const List<String> _allergyStatuses = [
    'Tidak, tidak pernah',
    'Ya, pernah (tidak tahu kandungannya)',
    'Ya, pernah (tahu kandungan yang harus dihindari)',
  ];

  static const List<String> _usageTimes = [
    'Pagi Hari',
    'Siang Hari',
    'Malam Hari',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final formProvider = context.watch<RecommendationFormProvider>();

    final showAllergenForm = formProvider.selectedAllergyStatus ==
        'Ya, pernah (tahu kandungan yang harus dihindari)';
        
    final showUsageTimeForm = formProvider.isNight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pertanyaan 1
        SingleChoice<SkinTypeModel>(
          indexNumber: '01',
          question: '1. Apa jenis kulitmu?',
          options: provider.skinTypes,
          selectedOption: formProvider.selectedSkinType,
          optionLabelBuilder: (type) => type.displayName,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (type) {
            formProvider.setSelectedSkinType(type);
          },
        ),
        AppSpacing.v16,

        // Pertanyaan 2
        MultipleChoice<SkinConcernModel>(
          indexNumber: '02',
          question: '2. Apa masalah kulitmu saat ini?',
          options: provider.skinConcerns,
          selectedOptions: formProvider.selectedSkinProblems,
          optionLabelBuilder: (problem) => problem.displayName,
          isLoading: provider.isLoading && provider.skinConcerns.isEmpty,
          onOptionsChanged: (problems) {
            formProvider.setSelectedSkinProblems(problems);
          },
        ),
        AppSpacing.v16,

        // Pertanyaan 3
        SingleChoice<String>(
          indexNumber: '03',
          question: '3. Bagaimana aktivitasmu saat menggunakan sunscreen?',
          options: _activities,
          selectedOption: formProvider.selectedActivity,
          optionLabelBuilder: (activity) => activity,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (activity) {
            formProvider.setSelectedActivity(activity);
          },
        ),
        AppSpacing.v16,

        // Pertanyaan 4
        SingleChoice<String>(
          indexNumber: '04',
          question: '4. Tekstur sunscreen seperti apa yang kamu sukai?',
          options: _textures,
          selectedOption: formProvider.selectedTexture,
          optionLabelBuilder: (texture) => texture,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (texture) {
            formProvider.setSelectedTexture(texture);
          },
        ),
        AppSpacing.v16,

        // Pertanyaan 5
        SingleChoice<String>(
          indexNumber: '05',
          question:
              '5. Apakah kamu pernah mengalami reaksi tidak nyaman seperti gatal, kemerahan, atau iritasi setelah memakai sunscreen?',
          options: _allergyStatuses,
          selectedOption: formProvider.selectedAllergyStatus,
          optionLabelBuilder: (status) => status,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (status) {
            formProvider.setSelectedAllergyStatus(status);
          },
        ),

        // Sub-pertanyaan Alergen jika terpilih
        if (showAllergenForm) ...[
          AppSpacing.v24,
          MultipleChoice<IngredientModel>(
            indexNumber: '5a',
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

        // Pertanyaan 6 (Kondisional Malam Hari)
        if (showUsageTimeForm) ...[
          AppSpacing.v16,
          SingleChoice<String>(
            indexNumber: '06',
            question: '6. Kapan kamu akan menggunakan sunscreen ini?',
            options: _usageTimes,
            selectedOption: formProvider.selectedUsageTime,
            optionLabelBuilder: (time) => time,
            isLoading: provider.isLoading && provider.skinTypes.isEmpty,
            onOptionSelected: (time) {
              formProvider.setSelectedUsageTime(time);
            },
          ),
        ],
      ],
    );
  }
}
