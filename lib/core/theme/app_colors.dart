import 'package:flutter/material.dart';

final class AppColors {
  const AppColors._();

  // Sage & Clay. Every value here is a token from the approved mockups; the
  // greys in particular are the corrected ones — the lighter pair they
  // replaced sat at 2.65:1 on white and failed as body text.
  static const Color background = Color(0xFFF5F1EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF0EBE2);
  static const Color surfaceVariant = Color(0xFFEAE3D9);
  static const Color border = Color(0xFFE6E0D6);
  static const Color primary = Color(0xFF55684F);
  static const Color primaryDeep = Color(0xFF3F4E3B);
  static const Color primarySoft = Color(0xFFE2E8DA);

  /// Reserved for what needs attention, never for decoration.
  static const Color accent = Color(0xFFC0714A);
  static const Color accentDeep = Color(0xFF9C5836);
  static const Color accentSoft = Color(0xFFF6E3D8);

  static const Color secondary = Color(0xFF3F5C6B);
  static const Color secondarySoft = Color(0xFFDFE9EE);

  static const Color textPrimary = Color(0xFF262320);
  static const Color textSecondary = Color(0xFF6B655C);

  /// Dimmer than [textSecondary] but still safe for body text; [iconMuted] is
  /// the lighter tone, and only ever carries icons (3:1 floor, not 4.5:1).
  static const Color textMuted = Color(0xFF6F6960);
  static const Color iconMuted = Color(0xFF857C71);

  static const Color success = Color(0xFF3F7A52);
  static const Color warning = Color(0xFFC0714A);
  static const Color danger = Color(0xFF9A3F2B);
  static const Color dangerSoft = Color(0xFFF7E0DA);

  // Category tints, each paired with an ink dark enough to label its own fill.
  static const Color waterTint = Color(0xFFDFE9EE);
  static const Color waterInk = Color(0xFF3F5C6B);
  static const Color mealTint = Color(0xFFF4E6D2);
  static const Color mealInk = Color(0xFF7F5A26);
  static const Color sleepTint = Color(0xFFE4E1EC);
  static const Color sleepInk = Color(0xFF4C4470);
  static const Color moveTint = Color(0xFFE3EADF);
  static const Color moveInk = Color(0xFF45603A);

  /// Daily-progress hero panel. Light in the light theme, a deep desaturated
  /// green in the dark one — a big pastel panel is harsh on a dark screen, and
  /// theme-driven text on it would be unreadable.
  static const Color heroStart = Color(0xFFE2E8DA);
  static const Color heroEnd = Color(0xFFEBEFE4);
  static const Color heroStartDark = Color(0xFF262D22);
  static const Color heroEndDark = Color(0xFF1E241B);

  static const Color backgroundDark = Color(0xFF171A16);
  static const Color surfaceDark = Color(0xFF22261F);
  static const Color surfaceSoftDark = Color(0xFF2C312A);
  static const Color borderDark = Color(0xFF373C34);
  static const Color textPrimaryDark = Color(0xFFF4F2EC);
  static const Color textSecondaryDark = Color(0xFFB8B3AA);
  static const Color textMutedDark = Color(0xFFA8A297);
  static const Color iconMutedDark = Color(0xFF8E887D);
}
