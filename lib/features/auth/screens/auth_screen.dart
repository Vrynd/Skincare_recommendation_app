import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/widgets/app_text_field.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/auth/utils/auth_validator.dart';
import 'package:recommendation_app/features/auth/widgets/auth_header.dart';
import 'package:recommendation_app/features/auth/widgets/auth_remember.dart';
import 'package:recommendation_app/features/auth/widgets/auth_social_button.dart';
import 'package:recommendation_app/features/auth/widgets/auth_social_divider.dart';
import 'package:recommendation_app/features/auth/widgets/auth_tab.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with AuthValidator {
  int _selectedTabIndex = 0;
  bool _isSubmitting = false;

  // Login Keys & Controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  // Register Keys & Controllers
  final _registerFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _resetFormState() {
    _emailController.clear();
    _passwordController.clear();
    _fullNameController.clear();
    _registerEmailController.clear();
    _registerPasswordController.clear();
    _loginFormKey.currentState?.reset();
    _registerFormKey.currentState?.reset();
    setState(() {
      _rememberMe = false;
    });
  }

  Future<void> _executeAuthAction({
    required Future<bool> Function() action,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    FocusScope.of(context).unfocus();

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await action();
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        context.goNamed(AppRouter.homeName);
      } else if (authProvider.errorMessage != null) {
        _showErrorSnackBar(authProvider.errorMessage!);
        authProvider.clearErrorMessage();
      }
    } finally {
      if (mounted) _isSubmitting = false;
    }
  }

  Future<void> _tapToLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    await _executeAuthAction(
      action: () => context.read<AuthProvider>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _tapToRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    await _executeAuthAction(
      action: () => context.read<AuthProvider>().signUp(
        namaLengkap: _fullNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.br16),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeader(
            title: _selectedTabIndex == 0
                ? 'Selamat Datang Kembali, Silakan\nMasuk ke Akun'
                : 'Buat Akun Baru Anda untuk Mulai\nLangkah Pertama',
            subtitle: _selectedTabIndex == 0
                ? 'Belum punya akun? Ketuk daftar di bawah'
                : 'Sudah memiliki akun? Masuk untuk melanjutkan perjalanan',
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: AppContainer.card(
              borderRadius: AppRadius.br32,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AuthTab(
                      selectedIndex: _selectedTabIndex,
                      onTabChanged: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                        _resetFormState();
                        context.read<AuthProvider>().clearErrorMessage();
                      },
                    ),
                    AppSpacing.v24,

                    // Tab 0: Login Form
                    if (_selectedTabIndex == 0)
                      Form(
                        key: _loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'Masukkan email Anda',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: HugeIcons.strokeRoundedMail01,
                              validator: validateEmail,
                            ),
                            AppSpacing.v20,
                            AppTextField(
                              controller: _passwordController,
                              label: 'Kata Sandi',
                              hintText: 'Kata sandi minimal 6 karakter',
                              isPassword: true,
                              prefixIcon: HugeIcons.strokeRoundedLockKey,
                              validator: validatePassword,
                            ),
                            AppSpacing.v24,
                            AuthRemember(
                              rememberMeValue: _rememberMe,
                              onRememberMeChanged: (value) {
                                setState(() {
                                  _rememberMe = value;
                                });
                              },
                              onForgotPasswordTap: () {},
                            ),
                            AppSpacing.v24,

                            Selector<AuthProvider, bool>(
                              selector: (_, provider) => provider.isLoading,
                              builder: (context, isLoading, _) =>
                                  AppButton.primary(
                                    title: 'Log In',
                                    borderRadius: AppRadius.br32,
                                    isLoading: isLoading,
                                    onTap: isLoading ? null : _tapToLogin,
                                  ),
                            ),
                            AppSpacing.v32,

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                      )
                    // Tab 1: Register Form
                    else
                      Form(
                        key: _registerFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: _fullNameController,
                              label: 'Nama Lengkap',
                              hintText: 'Masukkan nama lengkap Anda',
                              prefixIcon: HugeIcons.strokeRoundedUser,
                              validator: validateFullName,
                            ),
                            AppSpacing.v20,
                            AppTextField(
                              controller: _registerEmailController,
                              label: 'Email',
                              hintText: 'Masukkan email Anda',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: HugeIcons.strokeRoundedMail01,
                              validator: validateEmail,
                            ),
                            AppSpacing.v20,
                            AppTextField(
                              controller: _registerPasswordController,
                              label: 'Kata Sandi',
                              hintText: 'Kata sandi minimal 6 karakter',
                              isPassword: true,
                              prefixIcon: HugeIcons.strokeRoundedLockKey,
                              validator: validatePassword,
                            ),
                            AppSpacing.v32,

                            Selector<AuthProvider, bool>(
                              selector: (_, provider) => provider.isLoading,
                              builder: (context, isLoading, _) =>
                                  AppButton.primary(
                                    title: 'Register',
                                    borderRadius: AppRadius.br32,
                                    isLoading: isLoading,
                                    onTap: isLoading ? null : _tapToRegister,
                                  ),
                            ),
                            AppSpacing.v32,

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
