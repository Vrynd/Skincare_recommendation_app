import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/widgets/home_uv_forecast.dart';
import 'package:recommendation_app/features/home/widgets/home_uv_gauge.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';

class HomeUVIndex extends StatelessWidget {
  const HomeUVIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<HomeLocationProvider>();
    final recommendationProvider = context.watch<RecommendationProvider>();

    final uvIndex = locationProvider.uvIndex;
    final UVRiskLevel uvRiskLevel = locationProvider.uvRiskLevel;
    final riskLevel = uvRiskLevel.name;
    final riskColor = uvRiskLevel.color;
    final isAnyLoading = locationProvider.isLoading || locationProvider.isUvLoading;

    // Tentukan PA default berdasarkan standar WHO UV index
    String defaultPa = 'PA++';
    if (uvIndex > 5.0) defaultPa = 'PA+++';
    if (uvIndex > 10.0) defaultPa = 'PA++++';

    String protectionValue = "SPF ${uvRiskLevel.recommendedSpf}, $defaultPa";

    // 1. Cari apakah ada sunscreen yang direkomendasikan untuk user di riwayat
    final userSunscreens = recommendationProvider.recommendations
        .where((item) => item.category.toLowerCase() == 'sunscreen')
        .toList();

    // 2. Tentukan proteksi yang direkomendasikan (hanya nilai proteksi, tanpa menyebutkan nama produk)
    if (userSunscreens.isNotEmpty) {
      // Jika user punya sunscreen hasil rekomendasi teranalisis, tampilkan proteksinya
      final latestSun = userSunscreens.first;
      final spf = latestSun.spfValue ?? 'SPF ${uvRiskLevel.recommendedSpf}';
      final pa = latestSun.paGrade ?? defaultPa;
      protectionValue = pa.isNotEmpty ? "$spf, $pa" : spf;
    } else if (recommendationProvider.dbSunscreens.isNotEmpty) {
      // Jika tidak ada riwayat, tapi database punya sunscreen, cari yang cocok dengan tingkat risiko UV index
      int targetSpf = 15;
      if (uvIndex > 5.0) targetSpf = 30;
      if (uvIndex > 10.0) targetSpf = 50;

      // Filter yang SPF-nya >= targetSpf
      final matchingSuns = recommendationProvider.dbSunscreens.where((p) {
        final spfStr = p['spf_value'] as String?;
        if (spfStr == null) return false;
        final num = int.tryParse(spfStr.replaceAll(RegExp(r'[^0-9]'), ''));
        return num != null && num >= targetSpf;
      }).toList();

      final selectedSun = matchingSuns.isNotEmpty 
          ? matchingSuns.first 
          : recommendationProvider.dbSunscreens.first;

      final spf = selectedSun['spf_value'] ?? 'SPF ${uvRiskLevel.recommendedSpf}';
      final pa = selectedSun['pa_grade'] as String? ?? defaultPa;
      protectionValue = pa.isNotEmpty ? "$spf, $pa" : spf;
    }

    return AppContainer(
      borderRadius: AppRadius.br32,
      color: context.colors.onSurface,
      showShadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: AnimatedOpacity(
        opacity: isAnyLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              'Indeks Ultraviolet',
              style: context.text.titleMedium?.copyWith(
                color: context.colors.surface,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: HomeUVGauge(uvIndex: uvIndex, riskColor: riskColor),
                  ),
                ),
                const _VerticalDivider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: _UVInfoSection(
                      riskLevel: riskLevel,
                      riskColor: riskColor,
                      protectionValue: protectionValue,
                    ),
                  ),
                ),
              ],
            ),
            if (locationProvider.hourlyForecast.isNotEmpty) ...[
              const _HorizontalDivider(),
              HomeUVForecast(forecast: locationProvider.hourlyForecast),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lightBackground.withValues(alpha: 0.0),
            AppColors.lightBackground.withValues(alpha: 0.12),
            AppColors.lightBackground.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _UVInfoSection extends StatelessWidget {
  final String riskLevel;
  final Color riskColor;
  final String protectionValue;

  const _UVInfoSection({
    required this.riskLevel,
    required this.riskColor,
    required this.protectionValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _InfoRow(
          icon: HugeIcons.strokeRoundedAlertCircle,
          iconColor: riskColor,
          title: 'Kategori Risiko',
          value: riskLevel,
        ),
        _InfoRow(
          icon: HugeIcons.strokeRoundedSun02,
          iconColor: AppColors.accentOrange,
          title: 'Proteksi',
          value: protectionValue,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final List<List<dynamic>> icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.12),
          ),
          child: Center(
            child: HugeIcon(icon: icon, color: iconColor, size: 16),
          ),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Text(
                title,
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.surface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.lightBackground.withValues(alpha: 0.0),
            AppColors.lightBackground.withValues(alpha: 0.12),
            AppColors.lightBackground.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
