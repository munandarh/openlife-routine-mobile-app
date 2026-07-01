import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({required OnboardingRepository repository})
    : _repository = repository,
      super(const OnboardingState.initial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingLanguageSelected>(_onLanguageSelected);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingBackPressed>(_onBackPressed);
    on<OnboardingSkipped>(_onSkipped);
    on<OnboardingCompleted>(_onCompleted);
  }

  final OnboardingRepository _repository;

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    final String languageCode = await _repository.getPreferredLanguageCode();

    emit(
      state.copyWith(
        status: OnboardingStatus.ready,
        selectedLanguageCode: languageCode,
      ),
    );
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        status: OnboardingStatus.ready,
        pageIndex: event.pageIndex,
      ),
    );
  }

  Future<void> _onLanguageSelected(
    OnboardingLanguageSelected event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.setPreferredLanguageCode(event.languageCode);

    emit(
      state.copyWith(
        status: OnboardingStatus.ready,
        selectedLanguageCode: event.languageCode,
      ),
    );
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.isLastPage) {
      add(const OnboardingCompleted());
      return;
    }

    emit(
      state.copyWith(
        status: OnboardingStatus.ready,
        pageIndex: state.pageIndex + 1,
      ),
    );
  }

  void _onBackPressed(
    OnboardingBackPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.pageIndex == 0) {
      return;
    }

    emit(
      state.copyWith(
        status: OnboardingStatus.ready,
        pageIndex: state.pageIndex - 1,
      ),
    );
  }

  Future<void> _onSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.skipOnboarding();
    emit(state.copyWith(status: OnboardingStatus.skipped));
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.completeOnboarding();
    emit(state.copyWith(status: OnboardingStatus.completed));
  }
}
