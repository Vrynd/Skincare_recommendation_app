import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';

class AppAvatar extends StatelessWidget {
  final String? initialName;
  final String? fullName;
  final double size;
  final Color? backgroundColor;
  final double opacity;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.initialName,
    this.fullName,
    this.size = 46.0,
    this.backgroundColor,
    this.opacity = 0.06,
    this.onTap,
  });

  String _getInitials() {
    if (initialName != null && initialName!.isNotEmpty) {
      return initialName!;
    }
    
    if (fullName == null || fullName!.trim().isEmpty) {
      return '?';
    }

    final name = fullName!.trim();
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final displayInitial = _getInitials();
    final themeBgColor = backgroundColor ?? context.colors.onSurfaceVariant;

    Widget avatarWidget = AppContainer(
      color: themeBgColor,
      opacity: backgroundColor != null ? 1.0 : opacity,
      showBorder: false,
      showShadow: false,
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      shape: BoxShape.circle,
      child: Center(
        child: Text(
          displayInitial,
          style: context.text.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size),
          child: avatarWidget,
        ),
      );
    }

    return avatarWidget;
  }
}
