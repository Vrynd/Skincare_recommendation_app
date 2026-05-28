import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';

class AppSeparator extends StatelessWidget {
  final double size;
  final double opacity;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const AppSeparator({
    super.key,
    this.size = 4.0,
    this.opacity = 0.5,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  const AppSeparator.small({
    super.key,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
  }) : size = 4.0,
      opacity = 0.5;

  const AppSeparator.large({
    super.key,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  }) : size = 6.0,
      opacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final separatorColor =
        color ?? context.colors.outline.withValues(alpha: opacity);

    return Padding(
      padding: padding,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: separatorColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
