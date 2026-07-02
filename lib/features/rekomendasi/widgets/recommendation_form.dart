import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/single_choice.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/multiple_choice.dart';

const _noneConcern = SkinConcernModel(
  skinConcernId: 'none',
  skinConcernCode: 'none',
  skinConcernName: 'Tidak Ada',
  description: 'Tidak memiliki masalah kulit tertentu',
);

class RecommendationForm extends StatelessWidget {
  const RecommendationForm({super.key});

  static const List<String> _activities = [
    'Dalam Ruangan (Indoor)',
    'Luar Ruangan Ringan',
    'Luar Ruangan Intens',
    'Olahraga / Sport',
    'Berenang / Aktivitas Air',
  ];

  static const List<String> _finishes = [
    'Matte',
    'Dewy / Glowy',
    'Natural / Satin',
    'Tone-Up',
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
        // Pertanyaan 01: Jenis Kulit
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

        // Pertanyaan 02: Masalah Kulit (Multi-Select, maks 2)
        MultipleChoice<SkinConcernModel>(
          indexNumber: '02',
          question: 'Apa masalah kulitmu saat ini? (Maksimal 2)',
          options: [
            _noneConcern,
            ...provider.skinConcerns,
          ],
          selectedOptions: formProvider.selectedSkinProblems,
          onOptionsChanged: (concerns) {
            final noneAdded = concerns.contains(_noneConcern) &&
                !formProvider.selectedSkinProblems.contains(_noneConcern);
            if (noneAdded) {
              formProvider.setSelectedSkinProblems([_noneConcern]);
            } else {
              final realConcerns = concerns.where((c) => c != _noneConcern).toList();
              formProvider.setSelectedSkinProblems(realConcerns);
            }
          },
          optionLabelBuilder: (concern) => concern.displayName,
          isLoading: provider.isLoading && provider.skinConcerns.isEmpty,
        ),
        AppSpacing.v16,

        // Pertanyaan 03: Aktivitas Harian
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

        // Pertanyaan 04 & 05 hanya muncul jika Jenis Kulit sudah dipilih (agar dinamis)
        if (formProvider.selectedSkinType != null) ...[
          AppSpacing.v16,
          // Pertanyaan 04: Tekstur Dinamis
          SingleChoice<String>(
            indexNumber: '04',
            question: 'Tekstur sunscreen seperti apa yang kamu sukai?',
            options: formProvider.dynamicTextures,
            selectedOption: formProvider.selectedTexture,
            optionLabelBuilder: (texture) => texture,
            isLoading: provider.isLoading && provider.skinTypes.isEmpty,
            onOptionSelected: (texture) {
              formProvider.setSelectedTexture(texture);
            },
          ),
          if (formProvider.selectedTexture != null && formProvider.selectedTextureDescription != null) ...[
            AppSpacing.v8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formProvider.selectedTextureDescription!,
                      style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppSpacing.v16,

          // Pertanyaan 05: Hasil Akhir / Finish
          SingleChoice<String>(
            indexNumber: '05',
            question: 'Bagaimana hasil akhir sunscreen pada wajah yang kamu inginkan?',
            options: _finishes,
            selectedOption: formProvider.selectedFinish,
            optionLabelBuilder: (finish) => finish,
            isLoading: provider.isLoading && provider.skinTypes.isEmpty,
            onOptionSelected: (finish) {
              formProvider.setSelectedFinish(finish);
            },
          ),
          if (formProvider.selectedFinish != null && formProvider.selectedFinishDescription != null) ...[
            AppSpacing.v8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formProvider.selectedFinishDescription!,
                      style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],

        // Pertanyaan 06 (Kondisional Malam Hari)
        if (showUsageTimeForm) ...[
          AppSpacing.v16,
          SingleChoice<String>(
            indexNumber: '06',
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
