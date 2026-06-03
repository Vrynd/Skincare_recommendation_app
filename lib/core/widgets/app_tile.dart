import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

enum TileVariant { classic, modern }

class AppTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String? subtitle;
  final String? value;
  final TileVariant variant;
  final Color? iconColor;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDanger;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const AppTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.variant = TileVariant.modern,
    this.iconColor,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.isDanger = false,
    this.padding,
    this.showDivider = false,
  });

  const AppTile.classic({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.iconColor,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.isDanger = false,
    this.padding,
    this.showDivider = false,
  }) : variant = TileVariant.classic;

  const AppTile.modern({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.iconColor,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.isDanger = false,
    this.padding,
    this.showDivider = false,
  }) : variant = TileVariant.modern;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (variant == TileVariant.classic) {
      content = _buildClassic(context);
    } else {
      content = _buildModern(context);
    }

    if (showDivider) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [content, const AppDivider.dashed(indent: 0, endIndent: 0)],
      );
    }

    return content;
  }

  Widget _buildClassic(BuildContext context) {
    final Color effectiveColor = isDanger
        ? Colors.redAccent
        : (iconColor ?? context.colors.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.br12,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Row(
            spacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.br12,
                ),
                child: icon is IconData
                    ? Icon(icon, color: effectiveColor, size: 20)
                    : HugeIcon(icon: icon, color: effectiveColor, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: context.text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDanger
                            ? Colors.redAccent
                            : context.colors.onSurface,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildTrailing(context, isModern: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModern(BuildContext context) {
    final Color effectiveIconColor = isDanger
        ? Colors.redAccent
        : (iconColor ?? context.colors.onSurfaceVariant);

    return ListTile(
      dense: true,
      onTap: onTap,
      contentPadding: padding,
      leading: icon is IconData
          ? Icon(icon, color: effectiveIconColor, size: 20)
          : HugeIcon(icon: icon, color: effectiveIconColor, size: 20),
      title: Text(
        title,
        style: context.text.titleSmall?.copyWith(
          color: isDanger ? Colors.redAccent : context.colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.text.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: _buildTrailing(context, isModern: true),
    );
  }

  Widget _buildTrailing(BuildContext context, {bool isModern = false}) {
    if (trailing != null) return trailing!;

    if (value != null) {
      return Text(
        value!,
        style: context.text.bodyMedium?.copyWith(
          color: valueColor ?? context.colors.outline,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (onTap != null) {
      return HugeIcon(
        icon: isModern
            ? HugeIcons.strokeRoundedArrowRight02
            : HugeIcons.strokeRoundedArrowRight02,
        color: context.colors.onSurfaceVariant.withValues(
          alpha: isModern ? 0.5 : 0.3,
        ),
        size: isModern ? 16 : 20,
      );
    }

    return const SizedBox.shrink();
  }
}
