import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/services/recommendation_service.dart';
import 'package:recommendation_app/features/rekomendasi/widgets/result_recommendation_helpers.dart';

class SessionSummarySheet extends StatefulWidget {
  final String sessionId;

  const SessionSummarySheet({
    super.key,
    required this.sessionId,
  });

  static Future<void> show({
    required BuildContext context,
    required String sessionId,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: SessionSummarySheet(
        sessionId: sessionId,
      ),
    );
  }

  @override
  State<SessionSummarySheet> createState() => _SessionSummarySheetState();
}

class _SessionSummarySheetState extends State<SessionSummarySheet> {
  bool _isLoading = true;
  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    try {
      final service = RecommendationService();
      final details = await service.fetchSessionDetails(widget.sessionId);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_details == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            'Gagal Memuat Konteks',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Konteks rekomendasi ini tidak dapat ditemukan.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final session = _details!['session'] as Map<String, dynamic>? ?? {};
    final concerns = List<String>.from(_details!['concerns'] as List? ?? []);
    final ingredients = List<String>.from(
      _details!['ingredients'] as List? ?? [],
    );

    final skinDisplay = SkinTypeModel.getDisplay(
      (session['skin_types'] ?? {})['skin_type_name'] as String?,
    );

    final concernDisplay = concerns.isEmpty
        ? '-'
        : concerns.length <= 1
            ? SkinConcernModel.getDisplay(concerns.first)
            : '${SkinConcernModel.getDisplay(concerns.first)}, ...';

    final uvStr = uvDisplay(
      session['uv_index'],
      session['uv_risk_level'] as String?,
    );
    final loc = session['location_name'] as String?;
    final locDisplay = loc != null && loc.isNotEmpty ? loc : '-';
    final allergyStr = allergyDisplay(session['allergy_status'] as String?);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Parameter Rekomendasi',
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.v4,
        Text(
          'Kondisi kulit dan faktor lingkungan Anda saat mencari rekomendasi ini',
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.v20,
        AppContainer.bordered(
          borderRadius: AppRadius.br24,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              summaryTile(0, skinDisplay),
              summaryTile(1, concernDisplay),
              summaryTile(2, uvStr),
              summaryTile(3, locDisplay),
              summaryTile(4, allergyStr),
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
}
