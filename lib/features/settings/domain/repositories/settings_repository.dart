abstract interface class SettingsRepository {
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);
  Future<String> getLanguageCode();
  Future<void> setLanguageCode(String code);
}
