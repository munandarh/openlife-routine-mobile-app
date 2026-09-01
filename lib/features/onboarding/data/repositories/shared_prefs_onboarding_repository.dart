import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsOnboardingRepository implements OnboardingRepository {
  SharedPrefsOnboardingRepository(this._preferences);

  static const String _completedKey = 'onboarding.completed';

  final SharedPreferencesAsync _preferences;

  @override
  Future<void> completeOnboarding() async {
    await _preferences.setBool(_completedKey, true);
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return (await _preferences.getBool(_completedKey)) ?? false;
  }

  @override
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }
}
