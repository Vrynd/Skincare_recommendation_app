import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _loadingFade;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Sequential premium animations
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Mesh Gradient Aura Blobs (Background)
          Positioned(
            top: -120,
            right: -80,
            child: _buildBlurBlob(
              color: AppColors.seed.withValues(alpha: isDark ? 0.15 : 0.22),
              width: 320,
              height: 320,
              blur: 80,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _buildBlurBlob(
              color: AppColors.accentTeal.withValues(alpha: isDark ? 0.12 : 0.18),
              width: 350,
              height: 350,
              blur: 90,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: -120,
            child: _buildBlurBlob(
              color: AppColors.accentAmber.withValues(alpha: isDark ? 0.08 : 0.12),
              width: 280,
              height: 280,
              blur: 70,
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glassmorphic Logo Container
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoFade.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: AppRadius.br32,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white.withValues(alpha: 0.4))
                                    .withValues(alpha: 0.6),
                                borderRadius: AppRadius.br32,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors.grey)
                                        .withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: AppColors.seed.withValues(alpha: 0.12),
                                    blurRadius: 30,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: AppRadius.br24,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback icon if the image cannot be loaded
                                      return Icon(
                                        Icons.shield_moon_outlined,
                                        size: 48,
                                        color: context.colors.primary,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 36),

                      // Premium Animated App Title with Gradient Text
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _titleFade.value,
                            child: Transform.translate(
                              offset: Offset(0, _titleSlide.value),
                              child: child,
                            ),
                          );
                        },
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              context.colors.onSurface,
                              isDark ? AppColors.seed : AppColors.seed.darken(),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'Dermacast',
                            style: context.text.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              fontSize: 38,
                              color: Colors.white, // Required for shader mask
                            ),
                          ),
                        ),
                      ),
                      
                      AppSpacing.v12,

                      // Sequential Tagline
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _taglineFade.value,
                            child: child,
                          );
                        },
                        child: Text(
                          'Smart Skin & UV Forecast',
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 72),

                      // Premium Circular Loading Indicator with Fade
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _loadingFade.value,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Elegant Footer at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _footerFade.value,
                          child: child,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Dermacast Labs © 2026',
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant.withValues(alpha: 0.35),
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper builder for mesh blur blobs
  Widget _buildBlurBlob({
    required Color color,
    required double width,
    required double height,
    required double blur,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

// Extension to darken colors for shader contrast
extension on Color {
  Color darken([double amount = .12]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
