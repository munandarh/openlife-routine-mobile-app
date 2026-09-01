abstract interface class SettingsRepository {
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);

  Future<String> getLanguageCode();
  Future<void> setLanguageCode(String code);

  /// Accessibility preference: when true the app skips celebration overlays
  /// and looping animations (PRD §14.4).
  Future<bool> getReducedMotion();
  Future<void> setReducedMotion(bool enabled);

  /// Last day the missed-state sweep completed, or null if it never ran.
  Future<DateTime?> getLastMissedSweepDate();
  Future<void> setLastMissedSweepDate(DateTime date);
}
