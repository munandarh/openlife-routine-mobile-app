import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_settings_repository.dart';

void main() {
  group('SettingsRepository', () {
    late FakeSettingsRepository repository;

    setUp(() {
      repository = FakeSettingsRepository();
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

