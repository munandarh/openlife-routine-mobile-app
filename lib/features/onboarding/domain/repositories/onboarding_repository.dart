abstract interface class OnboardingRepository {
  Future<bool> hasCompletedOnboarding();

  Future<void> completeOnboarding();

  Future<void> skipOnboarding();

  Future<String> getPreferredLanguageCode();

  Future<void> setPreferredLanguageCode(String languageCode);
}
