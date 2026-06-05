import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';

class GroupTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const GroupTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(bottom: 8, left: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: context.text.labelMedium?.copyWith(
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}