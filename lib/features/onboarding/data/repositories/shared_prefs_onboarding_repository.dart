import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsOnboardingRepository implements OnboardingRepository {
  SharedPrefsOnboardingRepository(this._preferences);

  static const String _completedKey = 'onboarding.completed';
  static const String _languageKey = 'onboarding.language_code';

  final SharedPreferencesAsync _preferences;

  @override
  Future<void> completeOnboarding() async {
    await _preferences.setBool(_completedKey, true);
  }

  @override
  Future<String> getPreferredLanguageCode() async {
    return (await _preferences.getString(_languageKey)) ?? 'en';
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return (await _preferences.getBool(_completedKey)) ?? false;
  }

  @override
  Future<void> setPreferredLanguageCode(String languageCode) async {
    await _preferences.setString(_languageKey, languageCode);
  }

  @override
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }
}
