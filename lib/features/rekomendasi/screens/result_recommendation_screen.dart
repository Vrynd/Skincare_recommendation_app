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
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/result_recommendation_helpers.dart';

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
              onTap: () => context.go(AppRouter.homePath),
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
              _buildModeTabSelector(context, provider),
              AppSpacing.v16,
              _buildModeDescriptionCard(
                  context, provider, provider.currentSessionDetails),
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
                const AppTitleAction.none(title: 'Rekomendasi Utama'),
                AppSpacing.v12,
                productCard(provider.activeModeResults.isNotEmpty
                    ? provider.activeModeResults.first.toMap()
                    : provider.currentSessionResults.first),
                if ((provider.activeModeResults.isNotEmpty
                        ? provider.activeModeResults.length
                        : provider.currentSessionResults.length) >
                    1) ...[
                  AppSpacing.v24,
                  const AppTitleAction.none(title: 'Rekomendasi Alternatif'),
                  AppSpacing.v12,
                  ...(provider.activeModeResults.isNotEmpty
                          ? provider.activeModeResults.skip(1).map((e) => e.toMap())
                          : provider.currentSessionResults.skip(1))
                      .map(productCard),
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
    final session = details['session'] as Map<String, dynamic>? ?? {};
    final concerns = List<String>.from(details['concerns'] as List? ?? []);
    final ingredients = List<String>.from(
      details['ingredients'] as List? ?? [],
    );

    final skinDisplay = SkinTypeModel.getDisplay(
      (session['skin_types'] ?? {})['skin_type_name'] as String?,
    );
    final concernDisplay = concerns.isEmpty
        ? '-'
        : concerns.length <= 1
        ? SkinConcernModel.getDisplay(concerns.first)
        : '${SkinConcernModel.getDisplay(concerns.first)}, ...';
    final rawFinish = session['finish_preference'] as String?;
    final finishDisplay = const {
      'matte': 'Matte',
      'dewy': 'Dewy / Glowy',
      'natural': 'Natural / Satin',
      'tone_up': 'Tone-Up',
    }[rawFinish?.toLowerCase()] ?? rawFinish ?? '-';
    final uvStr = uvDisplay(
      session['uv_index'],
      session['uv_risk_level'] as String?,
    );
    final loc = session['location_name'] as String?;
    final locDisplay = loc != null && loc.isNotEmpty ? loc : '-';
    final allergyStr = allergyDisplay(session['allergy_status'] as String?);

    return Column(
      children: [
        AppContainer.bordered(
          borderRadius: AppRadius.br24,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              summaryTile(0, skinDisplay),
              summaryTile(1, concernDisplay),
              summaryTile(2, finishDisplay),
              summaryTile(3, uvStr),
              summaryTile(4, locDisplay),
              summaryTile(5, allergyStr),
            ],
          ),
        ),
        if (ingredients.isNotEmpty) ...[
          AppSpacing.v12,
          AppContainer.bordered(
            borderRadius: AppRadius.br24,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bahan yang Dihindari',
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.v12,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ingredients
                      .map((n) => ingredientChip(context, n))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModeTabSelector(
      BuildContext context, RecommendationProvider provider) {
    final selectedIndex = provider.selectedModeIndex;

    return AppContainer.bordered(
      height: 54,
      width: double.infinity,
      borderColor: context.colors.surfaceContainerHigh.withValues(alpha: 0.8),
      borderRadius: AppRadius.br32,
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          // Animated sliding pill indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: AppContainer(
                borderRadius: AppRadius.br32,
                color: context.colors.primary,
                opacity: 0.12,
                showBorder: false,
                showShadow: false,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          // Options row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.setSelectedModeIndex(0),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedDroplet,
                          color: selectedIndex == 0
                              ? context.colors.primary
                              : context.colors.outline,
                          size: 18,
                        ),
                        AppSpacing.h8,
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: context.text.bodyMedium!.copyWith(
                            fontWeight: selectedIndex == 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selectedIndex == 0
                                ? context.colors.primary
                                : context.colors.outline,
                          ),
                          child: const Text('Rekomendasi Rutin'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.setSelectedModeIndex(1),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSun02,
                          color: selectedIndex == 1
                              ? AppColors.accentAmber
                              : context.colors.outline,
                          size: 18,
                        ),
                        AppSpacing.h8,
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: context.text.bodyMedium!.copyWith(
                            fontWeight: selectedIndex == 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selectedIndex == 1
                                ? AppColors.accentAmber
                                : context.colors.outline,
                          ),
                          child: const Text('Proteksi Hari Ini'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeDescriptionCard(BuildContext context,
      RecommendationProvider provider, Map<String, dynamic>? details) {
    final isRoutine = provider.isRoutineMode;
    final session = details?['session'] as Map<String, dynamic>? ?? {};
    final uvIdx = session['uv_index'] ?? provider.uvData?.uvIndex;
    final uvStr = uvIdx != null ? (uvIdx as num).toStringAsFixed(1) : '-';

    return AppContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: AppRadius.br16,
      color: isRoutine ? AppColors.accentBlue : AppColors.accentAmber,
      opacity: 0.08,
      showBorder: false,
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(
            icon: isRoutine
                ? HugeIcons.strokeRoundedInformationCircle
                : HugeIcons.strokeRoundedSun02,
            color: isRoutine ? AppColors.accentBlue : AppColors.accentAmber,
            size: 20,
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRoutine
                      ? 'Mode Rutin (Penggunaan Berulang)'
                      : 'Mode Proteksi Situasional Hari Ini',
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isRoutine ? AppColors.accentBlue : AppColors.accentAmber,
                  ),
                ),
                AppSpacing.v4,
                Text(
                  isRoutine
                      ? 'Rekomendasi stabil berbasis profil kulit untuk stok pemakaian berulang sehari-hari dengan target proteksi dasar (SPF ≥ 30, PA ≥ +++).'
                      : 'Rekomendasi adaptif terhadap indeks UV cuaca hari ini (UV $uvStr) dan intensitas aktivitas harian Anda.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
