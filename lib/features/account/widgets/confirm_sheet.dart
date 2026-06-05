import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';

class ConfirmSheet extends StatefulWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final FutureOr<void> Function() onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;
  final dynamic icon;
  final Color? iconColor;

  const ConfirmSheet({
    super.key,
    required this.title,
    required this.description,
    required this.confirmText,
    this.cancelText = 'Batal',
    required this.onConfirm,
    this.onCancel,
    this.isDanger = false,
    this.icon,
    this.iconColor,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmText,
    String cancelText = 'Batal',
    required FutureOr<void> Function() onConfirm,
    VoidCallback? onCancel,
    bool isDanger = false,
    dynamic icon,
    Color? iconColor,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: ConfirmSheet(
        title: title,
        description: description,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDanger: isDanger,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  State<ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<ConfirmSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        if (widget.icon != null)
          _ConfirmIllustration(
            icon: widget.icon,
            color: widget.iconColor ??
                (widget.isDanger ? context.colors.error : context.colors.primary),
          ),
        _ConfirmHeader(title: widget.title, description: widget.description),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 16,
          children: [
            Expanded(
              child: AppButton.outline(
                title: widget.cancelText,
                onTap: _isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                        widget.onCancel?.call();
                      },
              ),
            ),
            Expanded(
              child: widget.isDanger
                  ? AppButton.danger(
                      title: widget.confirmText,
                      isLoading: _isLoading,
                      onTap: _handleConfirm,
                    )
                  : AppButton.primary(
                      title: widget.confirmText,
                      isLoading: _isLoading,
                      onTap: _handleConfirm,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirm();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }
}

class _ConfirmHeader extends StatelessWidget {
  final String title;
  final String description;

  const _ConfirmHeader({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Text(
          title,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          description,
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ConfirmIllustration extends StatelessWidget {
  final dynamic icon;
  final Color color;

  const _ConfirmIllustration({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppContainer(
        width: 80,
        height: 80,
        padding: EdgeInsets.zero,
        color: color,
        opacity: 0.04,
        shape: BoxShape.circle,
        showBorder: false,
        showShadow: true,
        customShadows: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
        child: Center(
          child: AppContainer(
            width: 65,
            height: 65,
            padding: EdgeInsets.zero,
            color: color,
            opacity: 0.15,
            shape: BoxShape.circle,
            showBorder: false,
            showShadow: true,
            customShadows: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            child: Center(child: _buildIcon()),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (icon is List<List<dynamic>>) {
      return HugeIcon(icon: icon, color: color, size: 32);
    } else if (icon is IconData) {
      return Icon(icon, color: color, size: 32);
    }
    return const SizedBox.shrink();
  }
}