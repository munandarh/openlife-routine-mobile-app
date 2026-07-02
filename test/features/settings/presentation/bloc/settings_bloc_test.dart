import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_state.dart';

void main() {
  late _FakeSettingsRepository repository;

  setUp(() {
    repository = _FakeSettingsRepository();
  });

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'loads initial settings on start',
      build: () => SettingsBloc(repository: repository),
      act: (SettingsBloc bloc) => bloc.add(const SettingsStarted()),
      verify: (SettingsBloc bloc) {
        expect(bloc.state.status, SettingsLoadStatus.success);
        expect(bloc.state.themeMode, 'system');
        expect(bloc.state.languageCode, 'en');
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'theme mode changed persists and emits',
      build: () => SettingsBloc(repository: repository),
      seed: () => const SettingsState(
        status: SettingsLoadStatus.success,
        themeMode: 'system',
        languageCode: 'en',
      ),
      act: (SettingsBloc bloc) => bloc.add(const SettingsThemeChanged('dark')),
      verify: (SettingsBloc bloc) {
        expect(bloc.state.themeMode, 'dark');
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'language changed persists and emits',
      build: () => SettingsBloc(repository: repository),
      seed: () => const SettingsState(
        status: SettingsLoadStatus.success,
        themeMode: 'system',
        languageCode: 'en',
      ),
      act: (SettingsBloc bloc) => bloc.add(const SettingsLanguageChanged('id')),
      verify: (SettingsBloc bloc) {
        expect(bloc.state.languageCode, 'id');
      },
    );
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
