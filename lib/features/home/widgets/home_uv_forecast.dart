import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/features/home/models/home_uv_data.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';

class HomeUVForecast extends StatelessWidget {
  final List<HourlyUVForecast> forecast;

  const HomeUVForecast({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    final currentHour = DateTime.now().hour;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Prakiraan Hari Ini',
          style: context.text.titleSmall?.copyWith(
            color: context.colors.surface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: forecast.map((item) {
            final isCurrent = item.time.hour == currentHour;
            final uvVal = item.uvIndex;
            final riskLevel = UVRiskLevel.fromIndex(uvVal);
            final barHeightFactor = (uvVal / 12.0).clamp(0.06, 1.0); // min 6% height for visibility
            final maxBarHeight = 70.0;
            final fillHeight = maxBarHeight * barHeightFactor;
            
            final hour = item.time.hour;
            final showLabel = hour == 6 || hour == 9 || hour == 12 || hour == 15 || hour == 18;
            final labelText = showLabel ? '${hour.toString().padLeft(2, '0')}:00' : '';

            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tooltip / Current UV Value above the bar
                  SizedBox(
                    height: 20,
                    child: isCurrent
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: riskLevel.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              uvVal.toStringAsFixed(1),
                              style: context.text.labelSmall?.copyWith(
                                color: context.colors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 4),
                  
                  // The bar gauge itself
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Background Track
                      Container(
                        width: 12,
                        height: maxBarHeight,
                        decoration: BoxDecoration(
                          color: context.colors.surface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: isCurrent
                              ? Border.all(
                                  color: riskLevel.color.withValues(alpha: 0.5),
                                  width: 1.0,
                                )
                              : null,
                        ),
                      ),
                      // Colored Progress
                      Container(
                        width: 12,
                        height: fillHeight,
                        decoration: BoxDecoration(
                          color: riskLevel.color,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: riskLevel.color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Hour label
                  SizedBox(
                    height: 12,
                    child: Text(
                      labelText,
                      style: context.text.labelSmall?.copyWith(
                        color: isCurrent
                            ? riskLevel.color
                            : context.colors.surface.withValues(alpha: 0.5),
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
