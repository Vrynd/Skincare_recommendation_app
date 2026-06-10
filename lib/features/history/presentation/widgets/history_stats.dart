import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class HistoryStats extends StatelessWidget {
  final String totalHistory;
  final String averageMatch;

  const HistoryStats({
    super.key,
    required this.totalHistory,
    required this.averageMatch,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Total Riwayat',
        'value': totalHistory,
        'icon': HugeIcons.strokeRoundedClock01,
        'iconColor': AppColors.accentIndigo,
      },
      {
        'label': 'Rerata Cocok',
        'value': averageMatch,
        'icon': HugeIcons.strokeRoundedCheckmarkBadge01,
        'iconColor': AppColors.accentTeal,
      },
    ];

    return Row(
      spacing: 16,
      children: stats.map((stat) {
        return Expanded(
          child: AppContainer(
            opacity: 0.8,
            showShadow: false,
            borderRadius: AppRadius.br24,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      stat['label'] as String,
                      style: context.text.labelMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    HugeIcon(
                      icon: stat['icon'],
                      size: 18,
                      color: stat['iconColor'] as Color,
                    ),
                  ],
                ),
                Text(
                  stat['value'] as String,
                  style: context.text.headlineLarge?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
