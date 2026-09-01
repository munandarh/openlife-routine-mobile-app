/// Persists first-run state only.
///
/// Language is deliberately *not* here: it is owned by `SettingsRepository`,
/// which is what `MaterialApp.locale` reads. Two repositories storing the
/// language under different keys is how the onboarding language pick used to
/// be silently discarded.
abstract interface class OnboardingRepository {
  Future<bool> hasCompletedOnboarding();

  Future<void> completeOnboarding();

  Future<void> skipOnboarding();
}
