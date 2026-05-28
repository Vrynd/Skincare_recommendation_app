import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

enum ButtonVariant { primary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  final dynamic icon;
  final Color? iconColor;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.iconColor,
    this.variant = ButtonVariant.primary,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius,
    this.padding,
  });

  const AppButton.primary({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.iconColor,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius,
    this.padding,
  }) : variant = ButtonVariant.primary;

  const AppButton.danger({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.iconColor,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius,
    this.padding,
  }) : variant = ButtonVariant.danger;

  const AppButton.outline({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.iconColor,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius,
    this.padding,
  }) : variant = ButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.iconColor,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius,
    this.padding,
  }) : variant = ButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final borderColor = _getBorderColor(context);
    final textColor = _getTextColor(context);
    final splashColor = _getSplashColor(context);
    final highlightColor = _getHighlightColor(context);

    return AppContainer(
      width: width,
      height: height,
      borderRadius: borderRadius ?? AppRadius.br16,
      color: backgroundColor,
      showBorder: variant == ButtonVariant.outline,
      borderColor: borderColor,
      showShadow: variant == ButtonVariant.primary,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (variant == ButtonVariant.primary)
            _ButtonDecorations(
              surfaceColor: context.colors.surface,
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onTap,
              borderRadius: borderRadius ?? AppRadius.br16,
              splashColor: splashColor,
              highlightColor: highlightColor,
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: _ButtonContent(
                    title: title,
                    isLoading: isLoading,
                    icon: icon,
                    textColor: textColor,
                    iconColor: iconColor,
                    isGhostStyle: variant == ButtonVariant.ghost,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return context.colors.primary;
      case ButtonVariant.danger:
        return context.colors.error;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color? _getBorderColor(BuildContext context) {
    if (variant == ButtonVariant.outline) {
      return context.colors.onSurfaceVariant.withValues(alpha: .2);
    }
    return null;
  }

  Color _getTextColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
        return context.colors.surface;
      case ButtonVariant.outline:
        return context.colors.onSurfaceVariant;
      case ButtonVariant.ghost:
        return context.colors.onSurface;
    }
  }

  Color _getSplashColor(BuildContext context) {
    final baseColor =
        (variant == ButtonVariant.primary || variant == ButtonVariant.danger)
        ? context.colors.surface
        : context.colors.onSurface;
    return baseColor.withValues(alpha: .15);
  }

  Color _getHighlightColor(BuildContext context) {
    final baseColor =
        (variant == ButtonVariant.primary || variant == ButtonVariant.danger)
        ? context.colors.surface
        : context.colors.onSurface;
    return baseColor.withValues(alpha: .05);
  }
}

class _ButtonDecorations extends StatelessWidget {
  final Color surfaceColor;

  const _ButtonDecorations({required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -45,
            right: -45,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceColor.withValues(alpha: .08),
              ),
            ),
          ),
          Positioned(
            top: -25,
            right: -25,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceColor.withValues(alpha: .12),
              ),
            ),
          ),
          Positioned(
            bottom: -45,
            left: -45,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceColor.withValues(alpha: .08),
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            left: -25,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceColor.withValues(alpha: .12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String title;
  final bool isLoading;
  final dynamic icon;
  final Color textColor;
  final Color? iconColor;
  final bool isGhostStyle;

  const _ButtonContent({
    required this.title,
    required this.isLoading,
    required this.icon,
    required this.textColor,
    this.iconColor,
    required this.isGhostStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          _ButtonIcon(
            icon: icon,
            iconColor: iconColor ?? textColor,
          ),
          const SizedBox(width: 10),
        ],
        Text(
          title,
          style: context.text.titleLarge?.copyWith(
            color: textColor,
            fontWeight: isGhostStyle ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ButtonIcon extends StatelessWidget {
  final dynamic icon;
  final Color iconColor;

  const _ButtonIcon({
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (icon is List<List<dynamic>>) {
      return HugeIcon(icon: icon, color: iconColor, size: 22);
    } else if (icon is IconData) {
      return Icon(icon, color: iconColor, size: 22);
    }
    return const SizedBox.shrink();
  }
}
