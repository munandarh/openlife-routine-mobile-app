import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';

/// In-memory [SettingsRepository] shared by the settings, onboarding, today and
/// app-level tests, so adding a preference does not mean editing five fakes.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    String themeMode = 'system',
    String languageCode = 'en',
    bool reducedMotion = false,
    DateTime? lastMissedSweepDate,
  }) : _themeMode = themeMode,
       _languageCode = languageCode,
       _reducedMotion = reducedMotion,
       _lastMissedSweepDate = lastMissedSweepDate;

  String _themeMode;
  String _languageCode;
  bool _reducedMotion;
  DateTime? _lastMissedSweepDate;

  @override
  Future<String> getThemeMode() async => _themeMode;

  @override
  Future<void> setThemeMode(String mode) async {
    // Mirrors the real repository's guard so tests can assert on it.
    if (!<String>['system', 'light', 'dark'].contains(mode)) {
      throw ArgumentError.value(mode, 'mode', 'Must be system, light, or dark');
    }
    _themeMode = mode;
  }

  @override
  Future<String> getLanguageCode() async => _languageCode;

  @override
  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
  }

  @override
  Future<bool> getReducedMotion() async => _reducedMotion;

  @override
  Future<void> setReducedMotion(bool enabled) async {
    _reducedMotion = enabled;
  }

  @override
  Future<DateTime?> getLastMissedSweepDate() async => _lastMissedSweepDate;

  @override
  Future<void> setLastMissedSweepDate(DateTime date) async {
    _lastMissedSweepDate = DateTime(date.year, date.month, date.day);
  }
}
