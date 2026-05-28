import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class AppContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final bool showShadow;
  final double opacity;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final Gradient? gradient;
  final BoxShape shape;
  final DecorationImage? image;
  final List<BoxShadow>? customShadows;
  final double? borderWidth;

  // 1. Generic Constructor
  const AppContainer({
    super.key,
    this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderRadius,
    this.showBorder = true,
    this.showShadow = true,
    this.opacity = 1.0,
    this.alignment,
    this.constraints,
    this.clipBehavior = Clip.none,
    this.gradient,
    this.shape = BoxShape.rectangle,
    this.image,
    this.customShadows,
    this.borderWidth,
  });

  // 2. Named Constructor: Card (dengan bayangan, tanpa border default)
  const AppContainer.card({
    super.key,
    this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderRadius,
    this.alignment,
    this.constraints,
    this.clipBehavior = Clip.none,
    this.gradient,
    this.shape = BoxShape.rectangle,
    this.image,
    this.customShadows,
  })  : borderColor = null,
        showBorder = false,
        showShadow = true,
        opacity = 1.0,
        borderWidth = null;

  // 3. Named Constructor: Bordered (dengan garis tepi, tanpa bayangan)
  const AppContainer.bordered({
    super.key,
    this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderRadius,
    this.alignment,
    this.constraints,
    this.clipBehavior = Clip.none,
    this.gradient,
    this.shape = BoxShape.rectangle,
    this.image,
    this.borderWidth,
  })  : showBorder = true,
        showShadow = false,
        opacity = 1.0,
        customShadows = null;

  // 4. Named Constructor: Flat (polos, tanpa border & bayangan)
  const AppContainer.flat({
    super.key,
    this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderRadius,
    this.alignment,
    this.constraints,
    this.clipBehavior = Clip.none,
    this.gradient,
    this.shape = BoxShape.rectangle,
    this.image,
  })  : borderColor = null,
        showBorder = false,
        showShadow = false,
        opacity = 1.0,
        customShadows = null,
        borderWidth = null;

  @override
  Widget build(BuildContext context) {
    return _DecoratedContainer(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      constraints: constraints,
      clipBehavior: clipBehavior,
      color: color,
      borderColor: borderColor,
      borderRadius: borderRadius,
      showBorder: showBorder,
      showShadow: showShadow,
      opacity: opacity,
      gradient: gradient,
      shape: shape,
      image: image,
      customShadows: customShadows,
      borderWidth: borderWidth,
      child: child,
    );
  }
}

class _DecoratedContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final bool showShadow;
  final double opacity;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final Gradient? gradient;
  final BoxShape shape;
  final DecorationImage? image;
  final List<BoxShadow>? customShadows;
  final double? borderWidth;

  const _DecoratedContainer({
    required this.width,
    required this.height,
    required this.padding,
    required this.alignment,
    required this.constraints,
    required this.clipBehavior,
    required this.color,
    required this.borderColor,
    required this.borderRadius,
    required this.showBorder,
    required this.showShadow,
    required this.opacity,
    required this.gradient,
    required this.shape,
    required this.image,
    required this.customShadows,
    required this.borderWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      constraints: constraints,
      clipBehavior: clipBehavior,
      decoration: _buildDecoration(context),
      child: child,
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    final backgroundColor = color ?? context.colors.surfaceContainerLowest;

    return BoxDecoration(
      color: gradient == null
          ? (color == Colors.transparent
              ? Colors.transparent
              : backgroundColor.withValues(alpha: opacity))
          : null,
      borderRadius: _radius,
      shape: shape,
      gradient: gradient,
      image: image,
      border: _border(context),
      boxShadow: _shadow(context),
    );
  }

  BorderRadius? get _radius {
    if (shape == BoxShape.circle) return null;
    return borderRadius ?? AppRadius.br16;
  }

  Border? _border(BuildContext context) {
    if (!showBorder) return null;
    return Border.all(
      color: borderColor ?? context.colors.surfaceContainerLowest,
      width: borderWidth ?? 1.3,
    );
  }

  List<BoxShadow>? _shadow(BuildContext context) {
    if (!showShadow) return null;
    if (customShadows != null) return customShadows;
    return [
      BoxShadow(
        color: context.colors.shadow.withValues(alpha: 0.02),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ];
  }
}