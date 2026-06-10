import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_header.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/auth_tab.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/login_form.dart';
import 'package:recommendation_app/features/auth/presentation/widgets/register_form.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/auth/services/auth_local_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _selectedTabIndex = 0;
  bool _isSubmitting = false;
  bool _rememberMe = false;
  final AuthLocalService _localService = AuthLocalService();
  String? _rememberedEmail;

  // Login Keys & Controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Register Keys & Controllers
  final _registerFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final rememberMe = await _localService.getRememberMeStatus();
    if (rememberMe) {
      final email = await _localService.getRememberedEmail();
      if (email != null && email.isNotEmpty) {
        setState(() {
          _emailController.text = email;
          _rememberMe = true;
          _rememberedEmail = email;
        });
      }
    }
  }

  Future<void> _saveRememberMe(String email) async {
    await _localService.saveRemembered(email, _rememberMe);
  }

  Future<void> _executeAuth({required Future<bool> Function() action}) async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    FocusScope.of(context).unfocus();

    try {
      final success = await action();
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (_selectedTabIndex == 0) {
          await _saveRememberMe(_emailController.text.trim());
        }
        if (!mounted) return;
        context.goNamed(AppRouter.homeName);
      }
    } finally {
      if (mounted) _isSubmitting = false;
    }
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    await _executeAuth(
      action: () => context.read<AuthProvider>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    await _executeAuth(
      action: () => context.read<AuthProvider>().signUp(
        namaLengkap: _fullNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
      ),
    );
  }

  void _resetFields() {
    if (_selectedTabIndex == 0) {
      if (_emailController.text.isEmpty &&
          _registerEmailController.text.isNotEmpty) {
        _emailController.text = _registerEmailController.text;
      }
    } else {
      if (_registerEmailController.text.isEmpty &&
          _emailController.text.isNotEmpty &&
          _emailController.text != _rememberedEmail) {
        _registerEmailController.text = _emailController.text;
      }
    }

    _passwordController.clear();
    _registerPasswordController.clear();
    _loginFormKey.currentState?.reset();
    _registerFormKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: CustomPaint(
              painter: _DottedGridPainter(color: context.colors.primary),
            ),
          ),
          Column(
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
              AppSpacing.v20,
              Expanded(
                flex: 3,
                child: AppContainer.card(
                  borderRadius: AppRadius.br32,
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
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
                            _resetFields();
                            context.read<AuthProvider>().clearErrorMessage();
                          },
                        ),
                        AppSpacing.v24,
                        _selectedTabIndex == 0
                            ? LoginForm(
                                formKey: _loginFormKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                rememberMeValue: _rememberMe,
                                onRememberMeChanged: (value) {
                                  setState(() {
                                    _rememberMe = value;
                                  });
                                },
                                onForgotPasswordTap: () {},
                                onLoginTap: _login,
                                isLoading: authProvider.isLoading,
                              )
                            : RegisterForm(
                                formKey: _registerFormKey,
                                fullNameController: _fullNameController,
                                emailController: _registerEmailController,
                                passwordController: _registerPasswordController,
                                onRegisterTap: _register,
                                isLoading: authProvider.isLoading,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  final Color color;

  _DottedGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const double spacing = 20.0;
    const double radius = 1.2;

    for (double x = 10.0; x < size.width; x += spacing) {
      for (double y = 20.0; y < size.height; y += spacing) {
        final double fadeProgress = (1.0 - (y / size.height)).clamp(0.0, 1.0);

        paint.color = color.withValues(alpha: 0.16 * fadeProgress);
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
