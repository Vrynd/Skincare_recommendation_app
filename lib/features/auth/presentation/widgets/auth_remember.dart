import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_checkbox.dart';

class AuthRemember extends StatelessWidget {
  final bool rememberMeValue;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPasswordTap;

  const AuthRemember({
    super.key,
    required this.rememberMeValue,
    required this.onRememberMeChanged,
    required this.onForgotPasswordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppCheckbox(
          value: rememberMeValue,
          label: 'Ingat Saya',
          onChanged: onRememberMeChanged,
        ),
        // Lupa Kata Sandi
        GestureDetector(
          onTap: onForgotPasswordTap,
          child: Text(
            'Lupa Kata Sandi?',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
