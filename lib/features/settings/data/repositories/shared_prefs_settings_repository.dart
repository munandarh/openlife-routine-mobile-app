import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const String _themeModeKey = 'settings.theme_mode';
  static const String _languageCodeKey = 'settings.language_code';
  static const String _reducedMotionKey = 'settings.reduced_motion';
  static const String _lastMissedSweepKey = 'settings.last_missed_sweep';

  @override
  Future<String> getThemeMode() async {
    final String? mode = await _preferences.getString(_themeModeKey);
    return mode ?? 'system';
  }

  @override
  Future<void> setThemeMode(String mode) async {
    if (!<String>['system', 'light', 'dark'].contains(mode)) {
      throw ArgumentError.value(mode, 'mode', 'Must be system, light, or dark');
    }
    await _preferences.setString(_themeModeKey, mode);
  }

  @override
  Future<String> getLanguageCode() async {
    final String? code = await _preferences.getString(_languageCodeKey);
    return code ?? 'en';
  }

  @override
  Future<void> setLanguageCode(String code) async {
    await _preferences.setString(_languageCodeKey, code);
  }

  @override
  Future<bool> getReducedMotion() async {
    return await _preferences.getBool(_reducedMotionKey) ?? false;
  }

  @override
  Future<void> setReducedMotion(bool enabled) async {
    await _preferences.setBool(_reducedMotionKey, enabled);
  }

  @override
  Future<DateTime?> getLastMissedSweepDate() async {
    final String? raw = await _preferences.getString(_lastMissedSweepKey);
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> setLastMissedSweepDate(DateTime date) async {
    final DateTime dayOnly = DateTime(date.year, date.month, date.day);
    await _preferences.setString(
      _lastMissedSweepKey,
      dayOnly.toIso8601String(),
    );
  }
}
