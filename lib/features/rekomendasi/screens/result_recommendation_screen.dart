import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_empty_state.dart';
import 'package:recommendation_app/core/widgets/app_bar.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_title.dart';
import 'package:recommendation_app/features/rekomendasi/models/recommendation_result_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/result_recommendation_helpers.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/user_owned_sunscreen_sheet.dart';

class ResultRecommendationScreen extends StatefulWidget {
  final String sessionId;
  const ResultRecommendationScreen({super.key, required this.sessionId});

  @override
  State<ResultRecommendationScreen> createState() =>
      _ResultRecommendationScreenState();
}

class _ResultRecommendationScreenState
    extends State<ResultRecommendationScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  SunscreenRecommendationItem? _selectedUserOwnedProduct;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecommendationProvider>().loadSessionResults(
          widget.sessionId,
        );
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final isRoutine = provider.isRoutineMode;
    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      appBar: AppAppBar(
        title: 'Hasil Rekomendasi',
        scrollOffset: _scrollOffset,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: NavigationCircleButton(
              size: 48,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.homePath);
                }
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft02,
                color: context.colors.onSurface,
                size: 24,
              ),
            ),
          ),
        ),
        actions: const [],
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            if (provider.isLoading)
              const AppEmptyState(
                icon: HugeIcons.strokeRoundedHourglass,
                title: 'Memuat rekomendasi...',
                description: 'Harap tunggu sebentar.',
                height: 280,
              )
            else if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAlertCircle,
                      color: context.colors.error,
                      size: 48,
                    ),
                    AppSpacing.v16,
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge,
                    ),
                    AppSpacing.v24,
                    ElevatedButton(
                      onPressed: () => context
                          .read<RecommendationProvider>()
                          .loadSessionResults(widget.sessionId),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            else if (provider.currentSessionResults.isEmpty &&
                provider.routineResults.isEmpty &&
                provider.todayResults.isEmpty)
              const AppEmptyState(
                icon: HugeIcons.strokeRoundedAlertCircle,
                title: 'Produk Belum Tersedia',
                description:
                    'Rekomendasi produk untuk kulit Anda belum tersedia.',
                height: 200,
              )
            else ...[
              _buildSummary(context, provider.currentSessionDetails),
              AppSpacing.v24,
              if (provider.activeModeResults.isEmpty &&
                  provider.currentSessionResults.isEmpty)
                const AppEmptyState(
                  icon: HugeIcons.strokeRoundedAlertCircle,
                  title: 'Produk Belum Tersedia',
                  description:
                      'Tidak ada produk yang memenuhi ambang batas untuk mode ini.',
                  height: 180,
                )
              else ...[
                const AppTitleAction.none(title: 'Rekomendasi Untuk Anda'),
                AppSpacing.v12,
                ...(provider.activeModeResults.isNotEmpty
                        ? provider.activeModeResults.take(3).map((e) => e.toMap())
                        : provider.currentSessionResults.take(3))
                    .map((item) => productCard(item, isRoutine: isRoutine)),
                if (!isRoutine) ...[
                  AppSpacing.v24,
                  if (_selectedUserOwnedProduct != null)
                    _buildSelectedUserOwnedProductSection(
                      context,
                      provider,
                      isRoutine,
                    )
                  else
                    _buildFeedbackPromptBanner(context, provider),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, Map<String, dynamic>? details) {
    if (details == null) return const SizedBox.shrink();
    final provider = context.watch<RecommendationProvider>();
    final isRoutine = provider.isRoutineMode;

    final session = details['session'] as Map<String, dynamic>? ?? {};
    final concerns = List<String>.from(details['concerns'] as List? ?? []);

    final skinDisplay = SkinTypeModel.getDisplay(
      (session['skin_types'] ?? {})['skin_type_name'] as String?,
    );
    final concernDisplay = concerns.isEmpty
        ? 'Tidak Ada'
        : concerns.length <= 1
            ? SkinConcernModel.getDisplay(concerns.first)
            : '${SkinConcernModel.getDisplay(concerns.first)}, ${SkinConcernModel.getDisplay(concerns[1])}';

    final rawActivity = session['activity'] as String?;
    final activityDisplay = const {
      'indoor': 'Di Dalam Ruangan',
      'outdoor_light': 'Di Luar Ruangan',
      'outdoor_intense': 'Olahraga',
      'sport': 'Olahraga',
      'swim': 'Berenang',
    }[rawActivity?.toLowerCase()] ?? rawActivity ?? '-';

    final rawTexture = session['texture_preference'] as String?;
    final textureDisplay = const {
      'gel': 'Gel',
      'cream': 'Cream',
      'lotion': 'Lotion',
      'serum': 'Serum',
      'milk': 'Milk',
      'watery': 'Watery',
      'stick': 'Stick',
      'spray': 'Spray',
      'mist': 'Mist',
    }[rawTexture?.toLowerCase()] ?? rawTexture ?? '-';

    final rawFinish = session['finish_preference'] as String?;
    final finishDisplay = const {
      'matte': 'Matte',
      'dewy': 'Dewy',
      'natural': 'Natural',
      'tone_up': 'Tone-Up',
    }[rawFinish?.toLowerCase()] ?? rawFinish ?? '-';

    return AppContainer.bordered(
      borderRadius: AppRadius.br24,
      padding: EdgeInsets.zero,
      child: Column(
        children: isRoutine
            ? [
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedDroplet,
                  iconColor: AppColors.accentPurple,
                  title: 'Jenis Kulit',
                  value: skinDisplay,
                ),
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedAlert01,
                  iconColor: AppColors.accentOrange,
                  title: 'Masalah Kulit',
                  value: concernDisplay,
                  isEllipsis: concerns.length > 1,
                ),
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedActivity01,
                  iconColor: AppColors.accentBlue,
                  title: 'Aktivitas',
                  value: activityDisplay,
                  isEllipsis: true,
                ),
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedSparkles,
                  iconColor: AppColors.accentTeal,
                  title: 'Tekstur',
                  value: textureDisplay,
                ),
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedCircle,
                  iconColor: AppColors.accentPink,
                  title: 'Hasil Akhir',
                  value: finishDisplay,
                  showDivider: false,
                ),
              ]
            : [
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedActivity01,
                  iconColor: AppColors.accentBlue,
                  title: 'Aktivitas Hari Ini',
                  value: activityDisplay,
                  isEllipsis: true,
                ),
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedDroplet,
                  iconColor: AppColors.accentPurple,
                  title: 'Jenis Kulit',
                  value: skinDisplay,
                ),
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedAlert01,
                  iconColor: AppColors.accentOrange,
                  title: 'Masalah Kulit',
                  value: concernDisplay,
                  isEllipsis: concerns.length > 1,
                ),
                summaryItemTile(
                  icon: HugeIcons.strokeRoundedCircle,
                  iconColor: AppColors.accentPink,
                  title: 'Hasil Akhir',
                  value: finishDisplay,
                  showDivider: false,
                ),
              ],
      ),
    );
  }

  void _openUserOwnedProductSheet(
    BuildContext context,
    RecommendationProvider provider,
  ) {
    final allCandidates = provider.activeModeResults.isNotEmpty
        ? provider.activeModeResults
        : provider.currentSessionResults
            .map((m) => SunscreenRecommendationItem.fromJson(m))
            .toList();

    // Produk di luar 3 rekomendasi teratas (utama + 2 alternatif)
    final otherCandidates = provider.activeModeResults.length > 3
        ? provider.activeModeResults.skip(3).toList()
        : (provider.currentSessionResults.length > 3
            ? provider.currentSessionResults
                .skip(3)
                .map((m) => SunscreenRecommendationItem.fromJson(m))
                .toList()
            : allCandidates);

    UserOwnedSunscreenSheet.show(
      context: context,
      otherCandidates: otherCandidates,
      allCandidates: allCandidates,
      onProductSelected: (product) {
        setState(() {
          _selectedUserOwnedProduct = product;
        });
      },
    );
  }

  Widget _buildFeedbackPromptBanner(
    BuildContext context,
    RecommendationProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dari ke-3 produk yang direkomendasikan, apakah Anda memiliki salah satunya?',
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _openUserOwnedProductSheet(context, provider),
          borderRadius: BorderRadius.circular(4),
          child: Text.rich(
            TextSpan(
              text: 'Jika tidak, ',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.outline,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'cari dan pilih produk yang Anda miliki',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: context.colors.primary,
                  ),
                ),
                const TextSpan(
                  text: ' di rumah untuk dihitung tingkat kecocokannya.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedUserOwnedProductSection(
    BuildContext context,
    RecommendationProvider provider,
    bool isRoutine,
  ) {
    final activeOwned = provider.activeModeResults.firstWhere(
      (item) => item.productId == _selectedUserOwnedProduct?.productId,
      orElse: () => _selectedUserOwnedProduct!,
    );

    final score = activeOwned.matchScore;
    final statusDesc = () {
      if (score >= 80.0) {
        return 'Formula sunscreen ini sangat selaras dengan kondisi kulit dan kebutuhan proteksi sinar matahari Anda hari ini.';
      } else if (score >= 70.0) {
        return 'Sunscreen ini memenuhi kriteria dasar perlindungan UV dan jenis kulit Anda untuk aktivitas hari ini.';
      } else if (score >= 55.0) {
        return 'Dapat digunakan saat ini, namun perhatikan kenyamanan tekstur atau perlindungan ekstra jika paparan matahari meningkat.';
      } else {
        return 'Tingkat perlindungan UV atau kandungan produk ini kurang optimal untuk intensitas paparan matahari Anda saat ini.';
      }
    }();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infoBg = isDark ? const Color(0xFF0F2744) : const Color(0xFFEFF6FF);
    final infoBorder = isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE);
    final infoColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppTitleAction.none(title: 'Sunscreen Anda'),
        AppSpacing.v12,
        productCard(
          activeOwned.toMap(),
          isRoutine: isRoutine,
        ),
        AppSpacing.v12,
        AppContainer(
          borderRadius: AppRadius.br16,
          color: infoBg,
          borderColor: infoBorder,
          showBorder: true,
          showShadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: infoColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusDesc,
                      style: context.text.bodySmall?.copyWith(
                        color:
                            context.colors.onSurface.withValues(alpha: 0.9),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              _openUserOwnedProductSheet(context, provider),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Pilih produk lain',
                                  style: context.text.labelMedium?.copyWith(
                                    color: infoColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: infoColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: infoColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedUserOwnedProduct = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              'Batal',
                              style: context.text.labelSmall?.copyWith(
                                color: context.colors.outline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
