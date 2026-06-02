import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class HomeCategory extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? textColor;
  final Color? activeTextColor;
  final Color? circleBackgroundColor;
  final Color? circleTextColor;
  final EdgeInsetsGeometry? padding;

  const HomeCategory({
    super.key,
    required this.title,
    required this.count,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.textColor,
    this.activeTextColor,
    this.circleBackgroundColor,
    this.circleTextColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;

    final defaultBgColor = isSelected
        ? (activeColor ?? themeColors.primaryContainer)
        : backgroundColor;

    final defaultTextColor = isSelected
        ? (activeTextColor ?? themeColors.onPrimaryContainer)
        : (textColor ?? themeColors.onSurface);

    final defaultCircleBgColor = isSelected
        ? (circleBackgroundColor ?? themeColors.surfaceContainerLowest)
        : (circleBackgroundColor ?? themeColors.surfaceContainerLow);

    final defaultCircleTextColor = isSelected
        ? (circleTextColor ?? themeColors.onSurface)
        : (circleTextColor ?? themeColors.onSurface);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.br32,
      child: AppContainer(
        width: null,
        padding:
            padding ??
            const EdgeInsets.only(left: 6, right: 18, top: 6, bottom: 6),
        color: defaultBgColor,
        borderRadius: AppRadius.br32,
        showShadow: false,
        showBorder: true,
        borderColor: isSelected
            ? (activeColor ?? themeColors.primaryContainer)
            : null,
        borderWidth: 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            AppContainer.flat(
              width: 40,
              height: 40,
              shape: BoxShape.circle,
              color: defaultCircleBgColor,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: context.text.labelLarge?.copyWith(
                  color: defaultCircleTextColor,
                ),
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: context.text.bodyMedium?.copyWith(
                  color: defaultTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
