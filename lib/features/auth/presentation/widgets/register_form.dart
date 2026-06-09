import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_text_field.dart';
import 'package:recommendation_app/features/auth/presentation/utils/auth_validator.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_social_divider.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_error_box.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';

class RegisterForm extends StatelessWidget with AuthValidator {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onRegisterTap;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.onRegisterTap,
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
            controller: fullNameController,
            label: 'Nama Lengkap',
            hintText: 'Masukkan nama lengkap Anda',
            prefixIcon: HugeIcons.strokeRoundedUser,
            validator: validateFullName,
          ),
          AppSpacing.v20,
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
          if (errorMessage != null) ...[
            AppSpacing.v20,
            AuthErrorBox(errorMessage: errorMessage),
          ],
          AppSpacing.v32,
          AppButton.primary(
            title: 'Register',
            borderRadius: AppRadius.br32,
            isLoading: isLoading,
            onTap: isLoading ? null : onRegisterTap,
          ),
          AppSpacing.v32,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AuthSocialDivider(
              label: 'atau register dengan',
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
