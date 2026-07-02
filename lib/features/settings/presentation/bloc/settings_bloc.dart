import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required SettingsRepository repository})
    : _repository = repository,
      super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
  }

  final SettingsRepository _repository;

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      status: SettingsLoadStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final String themeMode = await _repository.getThemeMode();
      final String languageCode = await _repository.getLanguageCode();

      emit(
        state.copyWith(
          status: SettingsLoadStatus.success,
          themeMode: themeMode,
          languageCode: languageCode,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _repository.setThemeMode(event.mode);
    emit(state.copyWith(themeMode: event.mode));
  }

  Future<void> _onLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _repository.setLanguageCode(event.code);
    emit(state.copyWith(languageCode: event.code));
  }
}
