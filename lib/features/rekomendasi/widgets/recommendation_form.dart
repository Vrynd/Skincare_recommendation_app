import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
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

  static const List<String> _usageTimes = [
    'Pagi Hari',
    'Siang Hari',
    'Malam Hari',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final formProvider = context.watch<RecommendationFormProvider>();

    final showUsageTimeForm = formProvider.isNight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pertanyaan 1
        SingleChoice<SkinTypeModel>(
          indexNumber: '01',
          question: 'Apa jenis kulitmu?',
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
          question: 'Apa masalah kulitmu saat ini?',
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
          question: 'Bagaimana aktivitasmu saat menggunakan sunscreen?',
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
          question: 'Tekstur sunscreen seperti apa yang kamu sukai?',
          options: _textures,
          selectedOption: formProvider.selectedTexture,
          optionLabelBuilder: (texture) => texture,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (texture) {
            formProvider.setSelectedTexture(texture);
          },
        ),

        // Pertanyaan 5 (Kondisional Malam Hari)
        if (showUsageTimeForm) ...[
          AppSpacing.v16,
          SingleChoice<String>(
            indexNumber: '05',
            question: 'Kapan kamu akan menggunakan sunscreen ini?',
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
