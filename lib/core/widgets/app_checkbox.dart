import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? context.colors.primary : Colors.transparent,
              borderRadius: AppRadius.br8,
              border: Border.all(
                color: value
                    ? context.colors.primary
                    : context.colors.outline.withValues(alpha: 0.4),
                width: 1.3,
              ),
            ),
            child: value
                ? Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedTick01,
                      color: context.colors.surface,
                      size: 20,
                    ),
                  )
                : null,
          ),
          AppSpacing.h12,
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
