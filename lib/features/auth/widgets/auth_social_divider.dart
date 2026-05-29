import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';

class AuthSocialDivider extends StatelessWidget {
  final String label;

  const AuthSocialDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: AppDivider.dashed()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: AppDivider.dashed()),
      ],
    );
  }
}
