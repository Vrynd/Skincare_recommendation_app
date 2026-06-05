import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? backgroundColor;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.showHandle = true,
    this.padding,
    this.height,
    this.backgroundColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    bool useRootNavigator = true,
    EdgeInsetsGeometry? padding,
    double? height,
    Color? backgroundColor,
    bool showHandle = true,
    double blurAmount = 4.0,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.2),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r32),
        ),
      ),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: AppBottomSheet(
          showHandle: showHandle,
          padding: padding,
          height: height,
          backgroundColor:
              backgroundColor ?? context.colors.surfaceContainerLowest,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      color: backgroundColor ?? context.colors.surfaceContainerLowest,
      width: double.infinity,
      height: height,
      opacity: 1.0,
      showBorder: false,
      showShadow: false,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.r32),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutQuad,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) _buildHandle(context),
              Padding(
                padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 60),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.outline.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}