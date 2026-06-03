import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class AppDockSheet extends StatelessWidget {
  final String title;
  final String description;
  final String buttonTitle;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onButtonTap;
  final bool isButtonLoading;
  final bool showSwitch;

  const AppDockSheet({
    super.key,
    required this.title,
    required this.description,
    required this.buttonTitle,
    this.switchValue,
    this.onSwitchChanged,
    this.onButtonTap,
    this.isButtonLoading = false,
    this.showSwitch = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSwitchValue = showSwitch ? (switchValue ?? false) : true;

    return AppContainer(
      width: double.infinity,
      borderRadius: AppRadius.only(topLeft: 32, topRight: 32),
      borderColor: context.colors.outline.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurface,
                        ),
                      ),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showSwitch && switchValue != null && onSwitchChanged != null)
                  _DockSwitch(value: switchValue!, onChanged: onSwitchChanged!),
              ],
            ),
            const AppDivider.dashed(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: effectiveSwitchValue ? 1.0 : 0.4,
              child: AppButton(
                title: buttonTitle,
                borderRadius: AppRadius.br32,
                onTap: effectiveSwitchValue ? onButtonTap : null,
                isLoading: isButtonLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DockSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value
              ? context.colors.primary
              : context.colors.outline.withValues(alpha: 0.15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? context.colors.onPrimary : context.colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
