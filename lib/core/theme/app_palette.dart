import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';

/// The surface and text colours that differ between light and dark.
///
/// `AppColors` holds raw constants, and its `…Dark` variants used to be almost
/// unreachable: widgets referenced the light constants directly, so the dark
/// theme rendered near-black text on a near-black background. Reading colours
/// through this extension is what makes a widget theme-aware.
///
/// Brand and semantic colours (primary, success, warning, danger and the
/// category tints) stay in `AppColors`: they are the same in both themes by
/// design.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.heroStart,
    required this.heroEnd,
  });

  const AppPalette.light()
    : background = AppColors.background,
      surface = AppColors.surface,
      surfaceSoft = AppColors.surfaceSoft,
      surfaceVariant = AppColors.surfaceVariant,
      border = AppColors.border,
      textPrimary = AppColors.textPrimary,
      textSecondary = AppColors.textSecondary,
      heroStart = AppColors.heroStart,
      heroEnd = AppColors.heroEnd;

  const AppPalette.dark()
    : background = AppColors.backgroundDark,
      surface = AppColors.surfaceDark,
      surfaceSoft = AppColors.surfaceSoftDark,
      surfaceVariant = AppColors.surfaceSoftDark,
      border = AppColors.borderDark,
      textPrimary = AppColors.textPrimaryDark,
      textSecondary = AppColors.textSecondaryDark,
      heroStart = AppColors.heroStartDark,
      heroEnd = AppColors.heroEndDark;

  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color surfaceVariant;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  /// Gradient stops for the daily-progress hero panel.
  final Color heroStart;
  final Color heroEnd;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? surfaceVariant,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? heroStart,
    Color? heroEnd,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  /// Surface and text colours for the active theme.
  ///
  /// Falls back to the light palette so a widget pumped without the app theme
  /// (a bare `MaterialApp` in a test) still renders instead of throwing.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? const AppPalette.light();
}
