import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_tile.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/location_selector_sheet.dart';
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
    'Di Dalam Ruangan',
    'Di Luar Ruangan',
    'Olahraga',
    'Berenang',
  ];

  static const List<String> _finishes = [
    'Matte',
    'Dewy',
    'Natural',
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
    final locationProvider = context.watch<HomeLocationProvider>();

    final isRoutine = formProvider.isRoutineMode;
    final showUsageTimeForm = formProvider.isTodayMode && formProvider.isNight;

    if (isRoutine) {
      return _buildRoutineForm(context, provider, formProvider);
    } else {
      return _buildTodayForm(
        context,
        provider,
        formProvider,
        locationProvider,
        showUsageTimeForm,
      );
    }
  }

  /// Formulir Mode Rekomendasi Produk
  /// Urutan: 01 Jenis Kulit, 02 Masalah Kulit, 03 Aktivitas, 04 Tekstur, 05 Hasil Akhir
  Widget _buildRoutineForm(
    BuildContext context,
    RecommendationProvider provider,
    RecommendationFormProvider formProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 01: Jenis Kulit
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

        // 02: Masalah Kulit
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
              final realConcerns =
                  concerns.where((c) => c != _noneConcern).toList();
              formProvider.setSelectedSkinProblems(realConcerns);
            }
          },
          optionLabelBuilder: (concern) => concern.displayName,
          isLoading: provider.isLoading && provider.skinConcerns.isEmpty,
        ),
        AppSpacing.v16,

        // 03: Aktivitas
        SingleChoice<String>(
          indexNumber: '03',
          question:
              'Bagaimana kebiasaan aktivitas utamamu saat menggunakan sunscreen?',
          options: _activities,
          selectedOption: formProvider.selectedActivity,
          optionLabelBuilder: (activity) => activity,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (activity) {
            formProvider.setSelectedActivity(activity);
          },
        ),

        // 04 & 05: Tekstur & Hasil Akhir jika jenis kulit sudah dipilih
        if (formProvider.selectedSkinType != null) ...[
          AppSpacing.v16,
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
          if (formProvider.selectedTextureDescription != null) ...[
            AppSpacing.v12,
            _buildInfoBanner(
              context,
              title: 'Tekstur ${formProvider.selectedTexture}',
              description: formProvider.selectedTextureDescription!,
            ),
          ],
          AppSpacing.v16,
          SingleChoice<String>(
            indexNumber: '05',
            question:
                'Bagaimana hasil akhir sunscreen pada wajah yang kamu inginkan?',
            options: _finishes,
            selectedOption: formProvider.selectedFinish,
            optionLabelBuilder: (finish) => finish,
            isLoading: provider.isLoading && provider.skinTypes.isEmpty,
            onOptionSelected: (finish) {
              formProvider.setSelectedFinish(finish);
            },
          ),
          if (formProvider.selectedFinishDescription != null) ...[
            AppSpacing.v12,
            _buildInfoBanner(
              context,
              title: 'Hasil Akhir ${formProvider.selectedFinish}',
              description: formProvider.selectedFinishDescription!,
            ),
          ],
        ],
      ],
    );
  }

  /// Formulir Mode Hari Ini
  /// Urutan yang diutamakan:
  /// 00 Lokasi Proteksi UV
  /// 01 Aktivitas apa?
  /// 02 Jenis kulit apa?
  /// 03 Memiliki masalah kulit atau tidak?
  /// 04 Hasil akhir pemakaian seperti apa yang Anda inginkan?
  /// (Tekstur ditiadakan di Mode Hari Ini)
  Widget _buildTodayForm(
    BuildContext context,
    RecommendationProvider provider,
    RecommendationFormProvider formProvider,
    HomeLocationProvider locationProvider,
    bool showUsageTimeForm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Lokasi Proteksi Hari Ini ─────────────────────────
        _buildLocationCard(context, formProvider, locationProvider),
        AppSpacing.v16,

        // 01: Aktivitas Hari Ini
        SingleChoice<String>(
          indexNumber: '01',
          question: 'Bagaimana rencanamu beraktivitas hari ini?',
          options: _activities,
          selectedOption: formProvider.selectedActivity,
          optionLabelBuilder: (activity) => activity,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (activity) {
            formProvider.setSelectedActivity(activity);
          },
        ),
        AppSpacing.v16,

        // 02: Jenis Kulit
        SingleChoice<SkinTypeModel>(
          indexNumber: '02',
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

        // 03: Masalah Kulit
        MultipleChoice<SkinConcernModel>(
          indexNumber: '03',
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
              final realConcerns =
                  concerns.where((c) => c != _noneConcern).toList();
              formProvider.setSelectedSkinProblems(realConcerns);
            }
          },
          optionLabelBuilder: (concern) => concern.displayName,
          isLoading: provider.isLoading && provider.skinConcerns.isEmpty,
        ),
        AppSpacing.v16,

        // 04: Hasil Akhir / Finish
        SingleChoice<String>(
          indexNumber: '04',
          question:
              'Bagaimana hasil akhir sunscreen pada wajah yang kamu inginkan?',
          options: _finishes,
          selectedOption: formProvider.selectedFinish,
          optionLabelBuilder: (finish) => finish,
          isLoading: provider.isLoading && provider.skinTypes.isEmpty,
          onOptionSelected: (finish) {
            formProvider.setSelectedFinish(finish);
          },
        ),
        if (formProvider.selectedFinishDescription != null) ...[
          AppSpacing.v12,
          _buildInfoBanner(
            context,
            title: 'Hasil Akhir ${formProvider.selectedFinish}',
            description: formProvider.selectedFinishDescription!,
          ),
        ],

        // 05: Waktu Penggunaan (hanya jika malam hari)
        if (showUsageTimeForm) ...[
          AppSpacing.v16,
          SingleChoice<String>(
            indexNumber: '05',
            question: 'Kapan kamu akan menggunakan sunscreen ini besok?',
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

  /// Banner informasi penjelasan karakteristik opsi yang sedang dipilih
  Widget _buildInfoBanner(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return AppContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: AppRadius.br16,
      color: context.colors.primary,
      opacity: 0.08,
      showBorder: true,
      borderColor: context.colors.primary.withValues(alpha: 0.2),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              color: context.colors.primary,
              size: 16,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                AppSpacing.v4,
                Text(
                  description,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Komponen lokasi dan indeks UV untuk Mode Hari Ini.
  /// Terdiri dari:
  /// - 1 komponen tile untuk menampilkan lokasi saat ini dan aksi klik untuk memilih lokasi
  /// - 2 grup komponen tile lainnya yang menyajikan kategori dan nilai indeks
  /// Semuanya menggunakan komponen AppTile.
  Widget _buildLocationCard(
    BuildContext context,
    RecommendationFormProvider formProvider,
    HomeLocationProvider locationProvider,
  ) {
    final isCustom = formProvider.isCustomLocation;
    final hasNoGps = !isCustom &&
        (!locationProvider.hasPermissions ||
            locationProvider.currentPosition == null);

    final locationName = isCustom
        ? (formProvider.customLocationName ?? 'Lokasi Pilihan')
        : (hasNoGps
            ? '${locationProvider.readableAddress} • Ketuk untuk pilih kota'
            : locationProvider.readableAddress);

    final isUvFailed = isCustom
        ? formProvider.isCustomUvError
        : locationProvider.isUvError;

    final uvVal = isCustom
        ? formProvider.customUvIndex
        : (locationProvider.isUvError ? null : locationProvider.uvIndex);

    final riskLevel = (uvVal != null && !isUvFailed) ? UVRiskLevel.fromIndex(uvVal) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. Tile Lokasi Saat Ini (dengan aksi klik) ─────────────────
        AppContainer.bordered(
          borderRadius: AppRadius.br24,
          padding: EdgeInsets.zero,
          child: AppTile.modern(
            icon: isCustom
                ? HugeIcons.strokeRoundedLocation01
                : (hasNoGps
                    ? HugeIcons.strokeRoundedAlertCircle
                    : HugeIcons.strokeRoundedGps01),
            iconColor: hasNoGps ? AppColors.accentOrange : context.colors.primary,
            title: isCustom ? 'Lokasi Pilihan' : 'Lokasi Saat Ini',
            subtitle: locationName,
            onTap: () => LocationSelectorSheet.show(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
        AppSpacing.v12,

        // ── 2. Grup Tile Kategori & Nilai Indeks UV ────────────────────
        AppContainer.bordered(
          borderRadius: AppRadius.br24,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTile.modern(
                icon: HugeIcons.strokeRoundedAlertCircle,
                iconColor: isUvFailed
                    ? context.colors.error
                    : (riskLevel?.color ?? AppColors.accentOrange),
                title: 'Kategori Risiko',
                value: formProvider.isLoadingCustomLocation
                    ? 'Memuat...'
                    : (isUvFailed ? 'Layanan Gagal' : (riskLevel?.name ?? '-')),
                valueColor: isUvFailed ? context.colors.error : riskLevel?.color,
                trailing: formProvider.isLoadingCustomLocation
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                showDivider: true,
              ),
              AppTile.modern(
                icon: HugeIcons.strokeRoundedSun02,
                iconColor: isUvFailed ? context.colors.error : AppColors.accentAmber,
                title: 'Nilai Indeks UV',
                value: formProvider.isLoadingCustomLocation
                    ? 'Memuat...'
                    : (isUvFailed
                        ? 'Tidak Tersedia'
                        : (uvVal != null ? uvVal.toStringAsFixed(1) : '-')),
                valueColor: isUvFailed
                    ? context.colors.error
                    : context.colors.onSurface,
                trailing: formProvider.isLoadingCustomLocation
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                showDivider: false,
              ),
            ],
          ),
        ),
        if (isUvFailed) ...[
          AppSpacing.v12,
          _buildInfoBanner(
            context,
            title: 'Layanan Indeks UV Terganggu',
            description:
                'Gagal mengambil data indeks UV dari satelit/layanan cuaca. Silakan periksa jaringan internet atau coba beberapa saat lagi.',
          ),
        ],
      ],
    );
  }
}
