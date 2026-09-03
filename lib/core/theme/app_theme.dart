import 'package:flutter/material.dart';

import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ).copyWith(
          secondary: AppColors.secondary,
          error: AppColors.danger,
          outline: AppColors.border,
          onSurface: AppColors.textPrimary,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        );

    return _theme(colorScheme, const AppPalette.light());
  }

  static ThemeData dark() {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surfaceDark,
        ).copyWith(
          secondary: AppColors.secondary,
          error: AppColors.danger,
          outline: AppColors.borderDark,
          onSurface: AppColors.textPrimaryDark,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        );

    return _theme(colorScheme, const AppPalette.dark());
  }

  static ThemeData _theme(ColorScheme colorScheme, AppPalette palette) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      fontFamily: AppTextStyles.fontFamily,
      // Driven by the palette rather than a light-only constant: the dark
      // theme used to patch these back afterwards and miss everything else.
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        headlineMedium: AppTextStyles.pageTitle,
        titleLarge: AppTextStyles.sectionTitle,
        titleMedium: AppTextStyles.cardTitle,
        bodyLarge: AppTextStyles.bodyEmphasis,
        bodyMedium: AppTextStyles.body,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Fields are white cards with no outline; the fill carries them, the
      // way the mockups draw them. Focus is the only state that draws a line.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: AppTextStyles.body.copyWith(
          fontSize: 15.5,
          color: palette.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
