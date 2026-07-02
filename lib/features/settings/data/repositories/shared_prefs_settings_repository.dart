import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const String _themeModeKey = 'settings.theme_mode';
  static const String _languageCodeKey = 'settings.language_code';

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
}
