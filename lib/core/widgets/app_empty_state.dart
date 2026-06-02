import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String description;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final Color? iconColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    this.icon = HugeIcons.strokeRoundedAlertCircle,
    required this.title,
    required this.description,
    this.height = 230.0,
    this.width = double.infinity,
    this.borderRadius = AppRadius.br32,
    this.iconColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;
    final resolvedIconColor = iconColor ?? themeColors.primary;
    final resolvedBorderColor = borderColor ?? themeColors.outlineVariant;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: resolvedBorderColor,
        borderRadius: borderRadius,
        strokeWidth: 1.3,
        dashWidth: 6.0,
        dashSpace: 4.0,
      ),
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: height),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: borderRadius,
        ),
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: resolvedIconColor.withValues(alpha: 0.04),
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: resolvedIconColor.withValues(alpha: 0.12),
                  ),
                ),
                // Ikon Utama
                _buildIcon(icon, resolvedIconColor),
              ],
            ),
            AppSpacing.v16,
            Text(
              title,
              style: context.text.titleLarge?.copyWith(
                color: themeColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.v8,
            Text(
              description,
              style: context.text.bodyMedium?.copyWith(
                color: themeColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic icon, Color color) {
    if (icon is List<List<dynamic>>) {
      return HugeIcon(icon: icon, color: color, size: 24);
    } else if (icon is IconData) {
      return Icon(icon, color: color, size: 24);
    }
    return const SizedBox.shrink();
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final BorderRadius borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.3,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = borderRadius.toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    final path = Path()..addRRect(rrect);

    final dashedPath = Path();
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (draw) {
          dashedPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.borderRadius != borderRadius;
  }
}
