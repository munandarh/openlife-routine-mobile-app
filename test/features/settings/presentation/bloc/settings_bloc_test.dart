import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_state.dart';

import '../../../../support/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;

  setUp(() {
    repository = FakeSettingsRepository();
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
