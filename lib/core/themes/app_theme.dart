import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_font.dart';

class AppTheme {
  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.light,
  );

  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.dark,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightScheme,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: AppFont.textTheme.apply(
      bodyColor: lightScheme.onSurface,
      displayColor: lightScheme.onSurface,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: AppFont.textTheme.apply(
      bodyColor: darkScheme.onSurface,
      displayColor: darkScheme.onSurface,
    ),
  );
}

extension ThemeExt on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

extension ColorSchemeExt on ColorScheme {
  Color get lime => brightness == Brightness.light
      ? AppColors.lime
      : AppColors.lime.withValues(alpha: 0.1);

  Color get mint => brightness == Brightness.light
      ? AppColors.mint
      : AppColors.mint.withValues(alpha: 0.1);

  Color get yellow => brightness == Brightness.light
      ? AppColors.yellow
      : AppColors.yellow.withValues(alpha: 0.1);

  Color get lightBackground => AppColors.lightBackground;
  Color get darkBackground => AppColors.darkBackground;
}