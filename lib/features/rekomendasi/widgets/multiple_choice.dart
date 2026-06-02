import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class MultipleChoice<T> extends StatelessWidget {
  final String? indexNumber;
  final String question;
  final List<T> options;
  final List<T> selectedOptions;
  final ValueChanged<List<T>> onOptionsChanged;
  final String Function(T option) optionLabelBuilder;

  const MultipleChoice({
    super.key,
    this.indexNumber,
    required this.question,
    required this.options,
    required this.selectedOptions,
    required this.onOptionsChanged,
    required this.optionLabelBuilder,
  });

  void _handleOptionTap(T option) {
    final newSelections = List<T>.from(selectedOptions);
    if (newSelections.contains(option)) {
      newSelections.remove(option);
    } else {
      newSelections.add(option);
    }
    onOptionsChanged(newSelections);
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      opacity: 0.6,
      showShadow: false,
      borderRadius: AppRadius.br32,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (indexNumber != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    indexNumber!,
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.h12,
              ] else ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary,
                  ),
                ),
                AppSpacing.h12,
              ],
              Expanded(
                child: Text(
                  question,
                  style: context.text.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v16,

          // Kontainer Pilihan Dalam (Inner Card)
          AppContainer(
            borderRadius: AppRadius.br24,
            color: context.colors.onSurfaceVariant,
            opacity: 0.04,
            borderColor: context.colors.outline.withValues(alpha: 0.1),
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(options.length, (index) {
                final option = options[index];
                final isSelected = selectedOptions.contains(option);
                final isLast = index == options.length - 1;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ChoiceRow(
                      label: optionLabelBuilder(option),
                      isSelected: isSelected,
                      onTap: () => _handleOptionTap(option),
                    ),
                    if (!isLast) const AppDivider.dashed(thickness: 0.8),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper Widget privat untuk merepresentasikan baris opsi di dalam daftar pilihan.
class _ChoiceRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            spacing: 16,
            children: [
              _CheckboxIndicator(isSelected: isSelected),
              Expanded(
                child: Text(
                  label,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper Widget privat untuk menggambar checkbox ter-animasi dengan gaya premium.
class _CheckboxIndicator extends StatelessWidget {
  final bool isSelected;

  const _CheckboxIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? context.colors.primary : Colors.transparent,
        borderRadius: AppRadius.br8,
        border: Border.all(
          color: isSelected
              ? context.colors.primary
              : context.colors.outline.withValues(alpha: 0.3),
          width: 1.3,
        ),
      ),
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Icon(Icons.check, color: context.colors.surface, size: 14),
      ),
    );
  }
}
