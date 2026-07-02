import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';

void main() {
  group('SettingsRepository', () {
    late _FakeSettingsRepository repository;

    setUp(() {
      repository = _FakeSettingsRepository();
    });

    test('getThemeMode returns default system', () async {
      final String mode = await repository.getThemeMode();
      expect(mode, 'system');
    });

    test('setThemeMode persists and reads back', () async {
      await repository.setThemeMode('dark');
      expect(await repository.getThemeMode(), 'dark');

      await repository.setThemeMode('light');
      expect(await repository.getThemeMode(), 'light');
    });

    test('getLanguageCode returns default en', () async {
      expect(await repository.getLanguageCode(), 'en');
    });

    test('setLanguageCode persists and reads back', () async {
      await repository.setLanguageCode('id');
      expect(await repository.getLanguageCode(), 'id');
    });

    test('theme mode rejects invalid values', () {
      expect(() => repository.setThemeMode('invalid'), throwsArgumentError);
    });
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  String _themeMode = 'system';
  String _languageCode = 'en';

  @override
  Future<String> getThemeMode() async => _themeMode;

  @override
  Future<void> setThemeMode(String mode) async {
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
}
