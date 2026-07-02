class AssetVectorEntry {
  const AssetVectorEntry({required this.name, required this.path});

  /// Stable identifier used by code to look up the asset.
  final String name;

  /// Asset path under the `assets/` folder (e.g. `assets/vector/foo.png`).
  final String path;
}

final class AssetVectors {
  const AssetVectors._();

  // -- Onboarding (4 slides) -----------------------------------------------
  static const AssetVectorEntry onboardingBuildBetterDays = AssetVectorEntry(
    name: 'onboardingBuildBetterDays',
    path: 'assets/vector/onboarding_build_better_days.png',
  );

  static const AssetVectorEntry onboardingSmartRoutines = AssetVectorEntry(
    name: 'onboardingSmartRoutines',
    path: 'assets/vector/onboarding_smart_routines.png',
  );

  static const AssetVectorEntry onboardingPrivateByDefault = AssetVectorEntry(
    name: 'onboardingPrivateByDefault',
    path: 'assets/vector/onboarding_private_by_default.png',
  );

  static const AssetVectorEntry onboardingStarterTemplate = AssetVectorEntry(
    name: 'onboardingStarterTemplate',
    path: 'assets/vector/onboarding_starter_template.png',
  );

  // -- Today screen ---------------------------------------------------------
  static const AssetVectorEntry todayNotificationBell = AssetVectorEntry(
    name: 'todayNotificationBell',
    path: 'assets/vector/today_notification_bell.png',
  );

  static const AssetVectorEntry todaySleepRoutine = AssetVectorEntry(
    name: 'todaySleepRoutine',
    path: 'assets/vector/today_sleep_routine.png',
  );

  static const AssetVectorEntry todayWaterHydration = AssetVectorEntry(
    name: 'todayWaterHydration',
    path: 'assets/vector/today_water_hydration.png',
  );

  static const AssetVectorEntry todayVitaminRoutine = AssetVectorEntry(
    name: 'todayVitaminRoutine',
    path: 'assets/vector/today_vitamin_routine.png',
  );

  static const AssetVectorEntry todayDailyCelebration = AssetVectorEntry(
    name: 'todayDailyCelebration',
    path: 'assets/vector/today_daily_celebration.png',
  );

  static const AssetVectorEntry todayInsightsWorkspace = AssetVectorEntry(
    name: 'todayInsightsWorkspace',
    path: 'assets/vector/today_insights_workspace.png',
  );

  /// All MVP-scope vector entries. The two `onboarding_build_better_days_alt.png`
  /// and `future_family_care_*.png` files are intentionally excluded from
  /// this registry so they don't ship in the app bundle. They remain in
  /// `assets/vector/` for reference but are not loaded.
  static const List<AssetVectorEntry> entries = <AssetVectorEntry>[
    onboardingBuildBetterDays,
    onboardingSmartRoutines,
    onboardingPrivateByDefault,
    onboardingStarterTemplate,
    todayNotificationBell,
    todaySleepRoutine,
    todayWaterHydration,
    todayVitaminRoutine,
    todayDailyCelebration,
    todayInsightsWorkspace,
  ];

  static AssetVectorEntry byName(String name) {
    for (final AssetVectorEntry entry in entries) {
      if (entry.name == name) {
        return entry;
      }
    }
    throw ArgumentError.value(name, 'name', 'Unknown vector entry');
  }
}
