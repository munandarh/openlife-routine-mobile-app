import 'package:flutter/material.dart';

class OpenLifeAnimationEntry {
  const OpenLifeAnimationEntry({
    required this.name,
    required this.rivePath,
    required this.fallbackIcon,
  });

  final String name;
  final String rivePath;
  final IconData fallbackIcon;
}

final class OpenLifeAnimationAssets {
  const OpenLifeAnimationAssets._();

  static const OpenLifeAnimationEntry onboardingBuildBetterDays =
      OpenLifeAnimationEntry(
        name: 'onboardingBuildBetterDays',
        rivePath: 'assets/rive/onboarding_build_better_days.riv',
        fallbackIcon: Icons.checklist_rtl_outlined,
      );

  static const OpenLifeAnimationEntry onboardingPrivateByDefault =
      OpenLifeAnimationEntry(
        name: 'onboardingPrivateByDefault',
        rivePath: 'assets/rive/onboarding_private_by_default.riv',
        fallbackIcon: Icons.lock_outline_rounded,
      );

  static const OpenLifeAnimationEntry emptyNoRoutines = OpenLifeAnimationEntry(
    name: 'emptyNoRoutines',
    rivePath: 'assets/rive/empty_no_routines.riv',
    fallbackIcon: Icons.event_note_outlined,
  );

  static const OpenLifeAnimationEntry routineDoneCheck = OpenLifeAnimationEntry(
    name: 'routineDoneCheck',
    rivePath: 'assets/rive/routine_done_check.riv',
    fallbackIcon: Icons.check_circle_outline_rounded,
  );

  static const OpenLifeAnimationEntry dailyCompleteCelebration =
      OpenLifeAnimationEntry(
        name: 'dailyCompleteCelebration',
        rivePath: 'assets/rive/daily_complete_celebration.riv',
        fallbackIcon: Icons.celebration_outlined,
      );

  static const OpenLifeAnimationEntry reminderActiveBell =
      OpenLifeAnimationEntry(
        name: 'reminderActiveBell',
        rivePath: 'assets/rive/reminder_active_bell.riv',
        fallbackIcon: Icons.notifications_active_outlined,
      );

  static const List<OpenLifeAnimationEntry> entries = <OpenLifeAnimationEntry>[
    onboardingBuildBetterDays,
    onboardingPrivateByDefault,
    emptyNoRoutines,
    routineDoneCheck,
    dailyCompleteCelebration,
    reminderActiveBell,
  ];

  static OpenLifeAnimationEntry byName(String name) {
    for (final OpenLifeAnimationEntry entry in entries) {
      if (entry.name == name) {
        return entry;
      }
    }
    throw ArgumentError.value(name, 'name', 'Unknown animation entry');
  }
}
