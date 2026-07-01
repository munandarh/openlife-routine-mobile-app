import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/local_database_config.dart';
import 'package:openlife_routine/features/onboarding/data/repositories/shared_prefs_onboarding_repository.dart';
import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  const AppDependencies({
    required this.databaseConfig,
    required this.notificationConfig,
    required this.onboardingRepository,
    required this.hasCompletedOnboarding,
    required this.preferredLanguageCode,
  });

  final LocalDatabaseConfig databaseConfig;
  final NotificationStackConfig notificationConfig;
  final OnboardingRepository onboardingRepository;
  final bool hasCompletedOnboarding;
  final String preferredLanguageCode;

  static Future<AppDependencies> bootstrap() async {
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    final OnboardingRepository onboardingRepository =
        SharedPrefsOnboardingRepository(preferences);
    final bool hasCompletedOnboarding = await onboardingRepository
        .hasCompletedOnboarding();
    final String preferredLanguageCode = await onboardingRepository
        .getPreferredLanguageCode();

    return AppDependencies(
      databaseConfig: const LocalDatabaseConfig.recommended(),
      notificationConfig: const NotificationStackConfig.recommended(),
      onboardingRepository: onboardingRepository,
      hasCompletedOnboarding: hasCompletedOnboarding,
      preferredLanguageCode: preferredLanguageCode,
    );
  }
}
