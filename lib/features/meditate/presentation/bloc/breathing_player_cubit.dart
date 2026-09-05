import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum BreathingPhase { inhale, exhale, settle }

class BreathingPlayerState extends Equatable {
  const BreathingPlayerState({
    required this.exhaleSeconds,
    this.phase = BreathingPhase.inhale,
    this.phaseCountdown = 3,
    this.totalSecondsRemaining = 420,
    this.cycleIndex = 1,
    this.isPaused = false,
    this.isCompleted = false,
  });

  final int exhaleSeconds;
  final BreathingPhase phase;
  final int phaseCountdown;
  final int totalSecondsRemaining;
  final int cycleIndex;
  final bool isPaused;
  final bool isCompleted;

  int get totalCycles => switch (exhaleSeconds) {
    7 => 42,
    12 => 28,
    21 => 17,
    _ => 42,
  };

  int get currentPhaseDuration => switch (phase) {
    BreathingPhase.inhale => 3,
    BreathingPhase.exhale => exhaleSeconds,
    BreathingPhase.settle => 12,
  };

  /// Progress from 0.0 to 1.0 within the current phase.
  double get phaseProgress {
    final int duration = currentPhaseDuration;
    if (duration <= 0) return 1.0;
    final int elapsed = duration - phaseCountdown;
    return (elapsed / duration).clamp(0.0, 1.0);
  }

  BreathingPlayerState copyWith({
    int? exhaleSeconds,
    BreathingPhase? phase,
    int? phaseCountdown,
    int? totalSecondsRemaining,
    int? cycleIndex,
    bool? isPaused,
    bool? isCompleted,
  }) {
    return BreathingPlayerState(
      exhaleSeconds: exhaleSeconds ?? this.exhaleSeconds,
      phase: phase ?? this.phase,
      phaseCountdown: phaseCountdown ?? this.phaseCountdown,
      totalSecondsRemaining:
          totalSecondsRemaining ?? this.totalSecondsRemaining,
      cycleIndex: cycleIndex ?? this.cycleIndex,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    exhaleSeconds,
    phase,
    phaseCountdown,
    totalSecondsRemaining,
    cycleIndex,
    isPaused,
    isCompleted,
  ];
}

class BreathingPlayerCubit extends Cubit<BreathingPlayerState> {
  BreathingPlayerCubit({required int exhaleSeconds, bool autoStart = true})
    : super(BreathingPlayerState(exhaleSeconds: exhaleSeconds)) {
    if (![7, 12, 21].contains(exhaleSeconds)) {
      throw ArgumentError.value(exhaleSeconds, 'exhaleSeconds');
    }
    if (autoStart) {
      start();
    }
  }

  Timer? _timer;
  final Stopwatch _clock = Stopwatch();
  int _processedSeconds = 0;

  void _synchronize() {
    final elapsed = _clock.elapsed.inSeconds;
    while (_processedSeconds < elapsed &&
        !state.isCompleted &&
        !state.isPaused) {
      _processedSeconds++;
      tick();
    }
  }

  void start() {
    _timer?.cancel();
    _clock.start();
    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _synchronize(),
    );
  }

  void pause() {
    if (state.isPaused || state.isCompleted) return;
    _synchronize();
    _clock.stop();
    _timer?.cancel();
    if (!state.isCompleted) emit(state.copyWith(isPaused: true));
  }

  void resume() {
    if (!state.isPaused || state.isCompleted) return;
    emit(state.copyWith(isPaused: false));
    _timer?.cancel();
    _clock.start();
    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _synchronize(),
    );
  }

  void tick() {
    if (state.isPaused || state.isCompleted) return;

    final int nextTotal = state.totalSecondsRemaining - 1;
    if (nextTotal <= 0) {
      _timer?.cancel();
      emit(
        state.copyWith(
          totalSecondsRemaining: 0,
          phaseCountdown: 0,
          isCompleted: true,
        ),
      );
      return;
    }

    final int nextCountdown = state.phaseCountdown - 1;
    if (nextCountdown > 0) {
      emit(
        state.copyWith(
          totalSecondsRemaining: nextTotal,
          phaseCountdown: nextCountdown,
        ),
      );
      return;
    }

    // Phase transition. Optional haptics belong to the presentation layer.

    switch (state.phase) {
      case BreathingPhase.inhale:
        emit(
          state.copyWith(
            totalSecondsRemaining: nextTotal,
            phase: BreathingPhase.exhale,
            phaseCountdown: state.exhaleSeconds,
          ),
        );
      case BreathingPhase.exhale:
        final bool isLast21Cycle =
            state.exhaleSeconds == 21 && state.cycleIndex == 17;
        if (isLast21Cycle) {
          emit(
            state.copyWith(
              totalSecondsRemaining: nextTotal,
              phase: BreathingPhase.settle,
              phaseCountdown: 12,
            ),
          );
        } else {
          emit(
            state.copyWith(
              totalSecondsRemaining: nextTotal,
              phase: BreathingPhase.inhale,
              phaseCountdown: 3,
              cycleIndex: state.cycleIndex + 1,
            ),
          );
        }
      case BreathingPhase.settle:
        emit(
          state.copyWith(
            totalSecondsRemaining: nextTotal,
            phaseCountdown: nextCountdown.clamp(0, 12),
          ),
        );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _clock.stop();
    return super.close();
  }
}
