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
import 'package:recommendation_app/core/widgets/app_text_field.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
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

class _AuthScreenState extends State<AuthScreen> {
  int _selectedTabIndex = 0;

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
    // Clean up Login Controllers
    _emailController.dispose();
    _passwordController.dispose();

    // Clean up Register Controllers
    _fullNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();

    super.dispose();
  }

  // --- Login Validators ---
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Masukkan alamat email yang valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal harus 6 karakter';
    }
    return null;
  }

  // --- Register Validators ---
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    return null;
  }

  String? _validateRegisterEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Masukkan alamat email yang valid';
    }
    return null;
  }

  String? _validateRegisterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal harus 6 karakter';
    }
    return null;
  }

  // --- Auth Handlers ---
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else if (authProvider.errorMessage != null) {
      _showErrorSnackBar(authProvider.errorMessage!);
      authProvider.clearErrorMessage();
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      namaLengkap: _fullNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else if (authProvider.errorMessage != null) {
      _showErrorSnackBar(authProvider.errorMessage!);
      authProvider.clearErrorMessage();
    }
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
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

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
                        // Bersihkan error saat pindah tab
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
                              validator: _validateEmail,
                            ),
                            AppSpacing.v20,
                            AppTextField(
                              controller: _passwordController,
                              label: 'Kata Sandi',
                              hintText: 'Kata sandi minimal 6 karakter',
                              isPassword: true,
                              prefixIcon: HugeIcons.strokeRoundedLockKey,
                              validator: _validatePassword,
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
                            AppButton.primary(
                              title: 'Log In',
                              borderRadius: AppRadius.br32,
                              isLoading: isLoading,
                              onTap: isLoading ? null : _handleLogin,
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
                              validator: _validateFullName,
                            ),
                            AppSpacing.v20,
                            AppTextField(
                              controller: _registerEmailController,
                              label: 'Email',
                              hintText: 'Masukkan email Anda',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: HugeIcons.strokeRoundedMail01,
                              validator: _validateRegisterEmail,
                            ),
                            AppSpacing.v20,
                            AppTextField(
                              controller: _registerPasswordController,
                              label: 'Kata Sandi',
                              hintText: 'Kata sandi minimal 6 karakter',
                              isPassword: true,
                              prefixIcon: HugeIcons.strokeRoundedLockKey,
                              validator: _validateRegisterPassword,
                            ),
                            AppSpacing.v32,
                            AppButton.primary(
                              title: 'Register',
                              borderRadius: AppRadius.br32,
                              isLoading: isLoading,
                              onTap: isLoading ? null : _handleRegister,
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
