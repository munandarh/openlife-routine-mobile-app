import 'package:flutter/material.dart';

final class AppColors {
  const AppColors._();

  // Meditation artwork uses fixed paired colors in both themes.
  static const Color meditationIvory = Color(0xFFF4EBD8);
  static const Color meditationFocus = Color(0xFF426A80);
  static const Color meditationReset = Color(0xFF956340);
  static const Color meditationSleep = Color(0xFF655884);
  static const Color meditationStress = Color(0xFF8B5861);
  static const Color meditationBreathe = Color(0xFF397779);
  static const Color meditationCalm = Color(0xFF4C684E);
  static const Color meditationOrbHighlight = Color(0xFFF2F3DE);
  static const Color meditationNight = Color(0xFF132D2B);
  static const Color meditationGlow = Color(0xFFFFE9C2);
  static const Color meditationSun = Color(0xFFF9EACD);
  static const Color meditationHillShadow = Color(0xFF142C29);
  static const Color meditationOrbInk = Color(0xFF315149);
  static const Color meditationPreviewGlow = Color(0xFFF3EAD4);
  static const Color meditationNumberInk = Color(0xFF2F4933);
  static const Color meditationPromptInk = Color(0xFF345343);
  static const Color meditationRingTrack = Color(0xFFDCE5D6);
  static const Color meditationRingActive = Color(0xFF829D79);

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
  static const Color medsTint = Color(0xFFF6DEDE);
  static const Color medsInk = Color(0xFF8E4040);
  static const Color calmTint = Color(0xFFEFE9E0);
  static const Color calmInk = Color(0xFF6B5B45);

  /// Daily-progress hero panel. Light in the light theme, a deep desaturated
  /// green in the dark one — a big pastel panel is harsh on a dark screen, and
  /// theme-driven text on it would be unreadable.
  static const Color heroStart = Color(0xFFE2E8DA);
  static const Color heroEnd = Color(0xFFEBEFE4);
  static const Color heroStartDark = Color(0xFF262D22);
  static const Color heroEndDark = Color(0xFF1E241B);

  // The pale "soft" fills are the light theme's quiet accents. Left alone in
  // the dark theme they became bright slabs carrying light text — the Insights
  // banner's body copy was pale grey on near-white. Each one gets a deep
  // counterpart plus the ink that stays legible on it.
  static const Color primarySoftDark = Color(0xFF2F3A2B);
  static const Color primaryInkLight = primary;
  static const Color primaryInkDark = Color(0xFFAFC4A4);
  static const Color accentSoftDark = Color(0xFF3A2A20);
  static const Color accentInkLight = accentDeep;
  static const Color accentInkDark = Color(0xFFE2A585);
  static const Color dangerSoftDark = Color(0xFF3B2420);
  static const Color dangerInkLight = danger;
  static const Color dangerInkDark = Color(0xFFE59684);

  static const Color backgroundDark = Color(0xFF171A16);
  static const Color surfaceDark = Color(0xFF22261F);
  static const Color surfaceSoftDark = Color(0xFF2C312A);
  static const Color borderDark = Color(0xFF373C34);
  static const Color textPrimaryDark = Color(0xFFF4F2EC);
  static const Color textSecondaryDark = Color(0xFFB8B3AA);
  static const Color textMutedDark = Color(0xFFA8A297);
  static const Color iconMutedDark = Color(0xFF8E887D);

  // Anxiety Breath & Meditation tokens
  static const Color anxietyTint = Color(0xFFD6E8EB);
  static const Color anxietyInk = Color(0xFF356B6F);
  static const Color anxietyCardTint = Color(0xFFE5F0F2);
  static const Color anxietyCardDark = Color(0xFF2C4345);
  static const Color anxietyTitle = Color(0xFF2B5B60);
  static const Color anxietySubtitle = Color(0xFF386367);
  static const Color anxietyProgressBg = Color(0xFFCCE0E3);
  static const Color anxietyProgressBgDark = Color(0xFF36484A);

  // Meditation action and theme tones
  static const Color forestGreen = Color(0xFF43583F);
  static const Color forestGreenGlow = Color(0x3343583F);
  static const Color forestGreenSoft = Color(0xFFE4EEE1);
  static const Color forestGreenBorder = Color(0xFFE4EDE1);

  // Setup cards
  static const Color inhaleCardTint = Color(0xFFE2EFF3);
  static const Color inhaleCardInk = Color(0xFF356B6F);
  static const Color durationCardTint = Color(0xFFECE8F4);
  static const Color durationCardInk = Color(0xFF504670);
  static const Color exhaleCardTint = Color(0xFFE3EFF4);
  static const Color exhaleCardInk = Color(0xFF426577);

  // Today's Pause Hero & Illustration
  static const Color meditationMoon = Color(0xFFF3ECE0);
  static const Color meditationCardText = Color(0xFFFAF7F2);
  static const Color meditationHillDark = Color(0xFF364433);
  static const Color meditationHillMid = Color(0xFF4A5C46);
  static const Color meditationLotusOuter = Color(0xFF7F9579);
  static const Color meditationLotusCenter = Color(0xFF9CB196);

  // Breathing Player Orb
  static const Color breathingGlow = Color(0xFF6B9B70);
  static const Color breathingOrbLight = Color(0xFFE8F3E6);
  static const Color breathingOrbMid = Color(0xFFC7DFC4);
  static const Color breathingOrbDeep = Color(0xFFAECDAA);
  static const Color breathingText = Color(0xFF2E462F);
  static const Color breathingDigits = Color(0xFF243A26);
  static const Color breathingTrack = Color(0xFFD6E5D4);
  static const Color breathingArc = Color(0xFF536E50);
  static const Color breathingWave1 = Color(0xFF7BA677);
  static const Color breathingWave2 = Color(0xFF5E8B5A);

  // Feelings Grid
  static const Color feelCalmTint = Color(0xFFE6ECE3);
  static const Color feelCalmInk = Color(0xFF3A5437);
  static const Color feelFocusedTint = Color(0xFFE0E9F2);
  static const Color feelFocusedInk = Color(0xFF33556D);
  static const Color feelGroundedTint = Color(0xFFF6ECE0);
  static const Color feelGroundedInk = Color(0xFF7B542E);
  static const Color feelRestfulTint = Color(0xFFE7E4F2);
  static const Color feelRestfulInk = Color(0xFF4A436D);
  static const Color feelRelievedTint = Color(0xFFDFEFEA);
  static const Color feelRelievedInk = Color(0xFF2F635E);
  static const Color feelEnergizedTint = Color(0xFFF7E3E3);
  static const Color feelEnergizedInk = Color(0xFF7B3B3B);

  // End Session Dialog
  static const Color sessionEndDanger = Color(0xFFB33A3A);
}
