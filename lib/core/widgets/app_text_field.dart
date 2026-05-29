import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final dynamic prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.v8,
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            cursorColor: context.colors.primary,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20, right: 12),
                      child: HugeIcon(
                        icon: widget.prefixIcon,
                        color: _isFocused
                            ? context.colors.primary
                            : context.colors.outline.withValues(alpha: 0.8),
                        size: 22,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 24,
              ),
              suffixIcon: widget.isPassword
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: HugeIcon(
                          icon: _obscureText
                              ? HugeIcons.strokeRoundedView
                              : HugeIcons.strokeRoundedViewOff,
                          color: context.colors.outline.withValues(alpha: 0.8),
                          size: 22,
                        ),
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 24,
              ),
              filled: true,
              fillColor: _isFocused
                  ? context.colors.surfaceContainerLow
                  : context.colors.surfaceContainerLowest,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.br32,
                borderSide: BorderSide(
                  color: context.colors.surfaceContainerHigh.withValues(
                    alpha: 0.6,
                  ),
                  width: 1.3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.br32,
                borderSide: BorderSide(
                  color: context.colors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.br32,
                borderSide: BorderSide(color: context.colors.error, width: 1.3),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.br32,
                borderSide: BorderSide(color: context.colors.error, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
