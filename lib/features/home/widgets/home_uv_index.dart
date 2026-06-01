import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/widgets/home_uv_gauge.dart';

class HomeUVIndex extends StatelessWidget {
  const HomeUVIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<HomeLocationProvider>();

    final currentHour = DateTime.now().hour;
    final uvIndex = _calculateMockUVIndex(currentHour);
    final riskLevel = _getRiskLevel(uvIndex);
    final riskColor = _getRiskColor(uvIndex);
    final peakTimeRange = _calculateMockPeakTimeRange(currentHour);
    final durationText = _calculateMockDuration(currentHour);

    return AppContainer(
      borderRadius: AppRadius.br32,
      color: context.colors.onSurface,
      showShadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: AnimatedOpacity(
        opacity: locationProvider.isLoading ? 0.6 : 1.0,
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
                      peakTimeRange: peakTimeRange,
                      durationText: durationText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMockUVIndex(int hour) {
    if (hour < 6 || hour >= 18) return 6.0;
    if (hour >= 11 && hour <= 13) return 8.5;
    if (hour >= 9 && hour < 11) return 5.2;
    if (hour > 13 && hour <= 15) return 6.0;
    if (hour >= 6 && hour < 9) return 1.5;
    return 6.0;
  }

  Color _getRiskColor(double index) {
    if (index <= 2.0) return AppColors.accentSage;
    if (index <= 5.0) return AppColors.accentAmber;
    if (index <= 7.0) return AppColors.accentOrange;
    if (index <= 10.0) return AppColors.accentRed;
    return AppColors.accentLavender;
  }

  String _getRiskLevel(double index) {
    if (index <= 2.0) return 'Rendah';
    if (index <= 5.0) return 'Sedang';
    if (index <= 7.0) return 'Tinggi';
    if (index <= 10.0) return 'Sangat Tinggi';
    return 'Ekstrem';
  }

  String _calculateMockPeakTimeRange(int hour) {
    if (hour < 6 || hour >= 18) return '11:00 - 13:00';
    return '11:00 - 13:00';
  }

  String _calculateMockDuration(int hour) {
    if (hour < 6 || hour >= 18) return '2.5 Jam';
    return '2.5 Jam';
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
  final String peakTimeRange;
  final String durationText;

  const _UVInfoSection({
    required this.riskLevel,
    required this.riskColor,
    required this.peakTimeRange,
    required this.durationText,
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
          title: 'Jam Puncak UV',
          value: peakTimeRange,
        ),
        _InfoRow(
          icon: HugeIcons.strokeRoundedHourglass,
          iconColor: AppColors.accentBlue,
          title: 'Durasi Bahaya',
          value: durationText,
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
          width: 40,
          height: 40,
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
                style: context.text.labelSmall?.copyWith(
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
