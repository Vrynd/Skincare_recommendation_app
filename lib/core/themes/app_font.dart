import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFont {
  static final TextStyle _base = GoogleFonts.outfit();

  // Display
  static final TextStyle displayLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -2,
  );

  static final TextStyle displayMedium = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static final TextStyle displaySmall = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // Headline
  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final TextStyle headlineMedium = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static final TextStyle headlineSmall = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title
  static final TextStyle titleLarge = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static final TextStyle titleMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static final TextStyle titleSmall = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // Body
  static final TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static final TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.2,
  );

  // Label
  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static final TextStyle labelMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );

  static final TextStyle labelSmall = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0.3,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
