import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';

class HomeUVGauge extends StatelessWidget {
  final double uvIndex;
  final Color riskColor;

  const HomeUVGauge({
    super.key,
    required this.uvIndex,
    required this.riskColor,
  });

  String _formatUVIndex(double index) {
    if (index == index.toInt()) {
      return index.toInt().toString();
    }
    return index.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (uvIndex / 12.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(100, 120),
            painter: _GaugePainter(value: progress, color: riskColor),
          ),

          Text(
            _formatUVIndex(uvIndex),
            style: context.text.headlineMedium?.copyWith(
              color: context.colors.surface,
              fontSize: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const outerStrokeWidth = 6.0;
    const progressStrokeWidth = 6.0;

    final outerTrackPaint = Paint()
      ..color = AppColors.lightBackground.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerStrokeWidth;
    canvas.drawCircle(center, radius - outerStrokeWidth / 2, outerTrackPaint);

    final progressRadius = radius - outerStrokeWidth - 3.5;
    if (value > 0) {
      final sweepAngle = value * 2 * math.pi;
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = progressStrokeWidth + 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: progressRadius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );

      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = progressStrokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: progressRadius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      final endAngle = -math.pi / 2 + sweepAngle;
      final knobCenter = Offset(
        center.dx + progressRadius * math.cos(endAngle),
        center.dy + progressRadius * math.sin(endAngle),
      );

      final knobBorderPaint = Paint()
        ..color = AppColors.lightBackground
        ..style = PaintingStyle.fill;
      canvas.drawCircle(knobCenter, 5.0, knobBorderPaint);

      final knobInnerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(knobCenter, 4.0, knobInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
