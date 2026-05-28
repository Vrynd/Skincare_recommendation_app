import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

enum ActionStyle { button, text, none }

class AppTitleAction extends StatelessWidget {
  final ActionStyle style;
  final String title;
  final String? subtitle;
  final String actionText;
  final Widget? actionIcon;
  final VoidCallback? onPressed;

  const AppTitleAction({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText = 'See All',
    this.actionIcon,
    this.style = ActionStyle.none,
    this.onPressed,
  });

  const AppTitleAction.button({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText = '',
    this.actionIcon,
    this.onPressed,
  }) : style = ActionStyle.button;

  const AppTitleAction.text({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText = 'See All',
    this.onPressed,
  }) : style = ActionStyle.text,
      actionIcon = null;

  const AppTitleAction.none({super.key, required this.title, this.subtitle})
    : style = ActionStyle.none,
      actionText = '',
      actionIcon = null,
      onPressed = null;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _TitleHeader(
            title: title,
            subtitle: subtitle,
          ),
        ),
        if (style != ActionStyle.none) ...[
          AppSpacing.h12,
          _buildActionWidget(),
        ],
      ],
    );
  }

  Widget _buildActionWidget() {
    switch (style) {
      case ActionStyle.button:
        return _TitleButtonAction(
          actionText: actionText,
          actionIcon: actionIcon,
          onPressed: onPressed,
        );
      case ActionStyle.text:
        return _TitleTextAction(
          actionText: actionText,
          onPressed: onPressed,
        );
      case ActionStyle.none:
        return const SizedBox.shrink();
    }
  }
}

class _TitleHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _TitleHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.headlineMedium?.copyWith(
            color: context.colors.onSurface,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.outline,
            ),
          ),
        ],
      ],
    );
  }
}

class _TitleButtonAction extends StatelessWidget {
  final String actionText;
  final Widget? actionIcon;
  final VoidCallback? onPressed;

  const _TitleButtonAction({
    required this.actionText,
    this.actionIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = actionIcon != null;
    final hasText = actionText.isNotEmpty;

    if (!hasIcon && !hasText) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(38, 38),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          backgroundColor: context.colors.onSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.br20),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight02,
          color: context.colors.onPrimary,
          size: 24,
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(38, 38),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: context.colors.primary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.br24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (actionIcon != null) actionIcon!,
          if (actionIcon != null && actionText.isNotEmpty) const SizedBox(width: 6),
          if (actionText.isNotEmpty)
            Text(
              actionText,
              style: context.text.labelLarge?.copyWith(
                color: context.colors.onPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _TitleTextAction extends StatelessWidget {
  final String actionText;
  final VoidCallback? onPressed;

  const _TitleTextAction({
    required this.actionText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        actionText,
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
