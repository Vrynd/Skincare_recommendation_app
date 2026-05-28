import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';

enum DividerStyle { dashed, solid }

class AppDivider extends StatelessWidget {
  final DividerStyle style;
  final Axis axis;
  final double thickness;
  final double width;
  final double space;
  final Color? color;
  final double indent;
  final double endIndent;

  const AppDivider({
    super.key,
    this.style = DividerStyle.dashed,
    this.axis = Axis.horizontal,
    this.thickness = 0.5,
    this.width = 4.0,
    this.space = 4.0,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  const AppDivider.dashed({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = .5,
    this.width = 4.0,
    this.space = 4.0,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : style = DividerStyle.dashed;

  const AppDivider.solid({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = .5,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : style = DividerStyle.solid,
       width = 0.0,
       space = 0.0;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? context.colors.outlineVariant;

    if (style == DividerStyle.solid) {
      return _SolidDivider(
        axis: axis,
        thickness: thickness,
        color: dividerColor,
        indent: indent,
        endIndent: endIndent,
      );
    }

    return _DashedDivider(
      axis: axis,
      thickness: thickness,
      width: width,
      space: space,
      color: dividerColor,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

class _SolidDivider extends StatelessWidget {
  final Axis axis;
  final double thickness;
  final Color color;
  final double indent;
  final double endIndent;

  const _SolidDivider({
    required this.axis,
    required this.thickness,
    required this.color,
    required this.indent,
    required this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = axis == Axis.horizontal;

    return Padding(
      padding: isHorizontal
          ? EdgeInsets.only(left: indent, right: endIndent)
          : EdgeInsets.only(top: indent, bottom: endIndent),
      child: Container(
        height: isHorizontal ? thickness : double.infinity,
        width: isHorizontal ? double.infinity : thickness,
        color: color,
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Axis axis;
  final double thickness;
  final double width;
  final double space;
  final Color color;
  final double indent;
  final double endIndent;

  const _DashedDivider({
    required this.axis,
    required this.thickness,
    required this.width,
    required this.space,
    required this.color,
    required this.indent,
    required this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = axis == Axis.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableLength = isHorizontal
            ? constraints.maxWidth - indent - endIndent
            : constraints.maxHeight - indent - endIndent;

        final dashCount = (availableLength / (width + space)).floor();

        return Padding(
          padding: isHorizontal
              ? EdgeInsets.only(left: indent, right: endIndent)
              : EdgeInsets.only(top: indent, bottom: endIndent),
          child: _DashedRender(
            count: dashCount,
            axis: axis,
            width: width,
            thickness: thickness,
            color: color,
          ),
        );
      },
    );
  }
}

class _DashedRender extends StatelessWidget {
  final int count;
  final Axis axis;
  final double width;
  final double thickness;
  final Color color;

  const _DashedRender({
    required this.count,
    required this.axis,
    required this.width,
    required this.thickness,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = axis == Axis.horizontal;

    final dashes = List.generate(count, (_) {
      return SizedBox(
        width: isHorizontal ? width : thickness,
        height: isHorizontal ? thickness : width,
        child: DecoratedBox(decoration: BoxDecoration(color: color)),
      );
    });

    if (isHorizontal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dashes,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dashes,
    );
  }
}
