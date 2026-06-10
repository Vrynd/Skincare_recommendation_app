import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Cari riwayat rekomendasi...',
    this.onFilterTap,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      opacity: 0.8,
      showBorder: false,
      showShadow: false,
      height: 60,
      width: double.infinity,
      borderRadius: AppRadius.br32,
      padding: const EdgeInsets.only(left: 16, right: 4),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            size: 20,
            color: context.colors.outline,
          ),
          AppSpacing.h12,
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              cursorColor: context.colors.primary,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: context.text.bodyLarge?.copyWith(
                  color: context.colors.outline.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          AppSpacing.h12,
          Material(
            color: context.colors.primaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onFilterTap,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSlidersHorizontal,
                    size: 18,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
