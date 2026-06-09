import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_text_field.dart';
import 'package:recommendation_app/features/auth/presentation/utils/auth_validator.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_remember.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_social_divider.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_error_box.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';

class LoginForm extends StatelessWidget with AuthValidator {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMeValue;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPasswordTap;
  final VoidCallback onLoginTap;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMeValue,
    required this.onRememberMeChanged,
    required this.onForgotPasswordTap,
    required this.onLoginTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.watch<AuthProvider>().errorMessage;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: emailController,
            label: 'Email',
            hintText: 'Masukkan email Anda',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: HugeIcons.strokeRoundedMail01,
            validator: validateEmail,
          ),
          AppSpacing.v20,
          AppTextField(
            controller: passwordController,
            label: 'Kata Sandi',
            hintText: 'Kata sandi minimal 8 karakter',
            isPassword: true,
            prefixIcon: HugeIcons.strokeRoundedLockKey,
            validator: validatePassword,
          ),
          AppSpacing.v24,
          AuthRemember(
            rememberMeValue: rememberMeValue,
            onRememberMeChanged: onRememberMeChanged,
            onForgotPasswordTap: onForgotPasswordTap,
          ),
          if (errorMessage != null) ...[
            AppSpacing.v20,
            AuthErrorBox(errorMessage: errorMessage),
          ],
          AppSpacing.v24,
          AppButton.primary(
            title: 'Log In',
            borderRadius: AppRadius.br32,
            isLoading: isLoading,
            onTap: isLoading ? null : onLoginTap,
          ),
          AppSpacing.v32,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AuthSocialDivider(
              label: 'atau login dengan',
            ),
          ),
          AppSpacing.v32,
          AuthSocialButton(
            onGoogleTap: () {},
            onAppleTap: () {},
          ),
        ],
      ),
    );
  }
}
