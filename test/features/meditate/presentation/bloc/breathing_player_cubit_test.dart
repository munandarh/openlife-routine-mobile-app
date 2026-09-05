import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/breathing_player_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BreathingPlayerCubit', () {
    test('initial state has correct duration and starts at inhale', () {
      final BreathingPlayerCubit cubit = BreathingPlayerCubit(exhaleSeconds: 7);
      expect(cubit.state.phase, BreathingPhase.inhale);
      expect(cubit.state.phaseCountdown, 3);
      expect(cubit.state.totalSecondsRemaining, 420);
      expect(cubit.state.isPaused, isFalse);
      expect(cubit.state.isCompleted, isFalse);
      cubit.close();
    });

    test('manual tick transitions from inhale to exhale after 3 seconds', () {
      final BreathingPlayerCubit cubit = BreathingPlayerCubit(exhaleSeconds: 7);
      // t = 0: Inhale 3s
      expect(cubit.state.phase, BreathingPhase.inhale);
      expect(cubit.state.phaseCountdown, 3);

      // t = 1
      cubit.tick();
      expect(cubit.state.phase, BreathingPhase.inhale);
      expect(cubit.state.phaseCountdown, 2);

      // t = 2
      cubit.tick();
      expect(cubit.state.phase, BreathingPhase.inhale);
      expect(cubit.state.phaseCountdown, 1);

      // t = 3 -> transitions to exhale with 7s
      cubit.tick();
      expect(cubit.state.phase, BreathingPhase.exhale);
      expect(cubit.state.phaseCountdown, 7);
      expect(cubit.state.cycleIndex, 1);

      cubit.close();
    });

    test('manual tick transitions from exhale back to inhale', () {
      final BreathingPlayerCubit cubit = BreathingPlayerCubit(exhaleSeconds: 7);
      // Skip inhale (3 ticks)
      cubit.tick();
      cubit.tick();
      cubit.tick();
      expect(cubit.state.phase, BreathingPhase.exhale);
      expect(cubit.state.phaseCountdown, 7);

      // Tick through 7s exhale
      for (int i = 0; i < 6; i++) {
        cubit.tick();
      }
      expect(cubit.state.phase, BreathingPhase.exhale);
      expect(cubit.state.phaseCountdown, 1);

      // 7th tick completes exhale -> next inhale cycle 2
      cubit.tick();
      expect(cubit.state.phase, BreathingPhase.inhale);
      expect(cubit.state.phaseCountdown, 3);
      expect(cubit.state.cycleIndex, 2);

      cubit.close();
    });

    test('21s mode enters settle phase for last 12s and completes at 420s', () {
      final BreathingPlayerCubit cubit = BreathingPlayerCubit(
        exhaleSeconds: 21,
      );

      // 17 cycles of 24s = 408s
      for (int i = 0; i < 408; i++) {
        expect(cubit.state.isCompleted, isFalse);
        cubit.tick();
      }

      // At t = 408s, we enter the settle phase
      expect(cubit.state.phase, BreathingPhase.settle);
      expect(cubit.state.phaseCountdown, 12);
      expect(cubit.state.totalSecondsRemaining, 12);

      // Tick through 12s of settle
      for (int i = 0; i < 11; i++) {
        cubit.tick();
      }
      expect(cubit.state.phase, BreathingPhase.settle);
      expect(cubit.state.phaseCountdown, 1);
      expect(cubit.state.isCompleted, isFalse);

      // Final tick completes session at 420s
      cubit.tick();
      expect(cubit.state.isCompleted, isTrue);
      expect(cubit.state.totalSecondsRemaining, 0);

      cubit.close();
    });

    test('7s mode completes after exactly 420 seconds (42 cycles)', () {
      final BreathingPlayerCubit cubit = BreathingPlayerCubit(exhaleSeconds: 7);

      // 42 cycles of 10s = 420 ticks
      for (int i = 0; i < 419; i++) {
        cubit.tick();
        expect(cubit.state.isCompleted, isFalse);
      }
      cubit.tick();
      expect(cubit.state.isCompleted, isTrue);
      expect(cubit.state.totalSecondsRemaining, 0);

      cubit.close();
    });

    test('pause stops ticking and resume continues', () {
      final BreathingPlayerCubit cubit = BreathingPlayerCubit(exhaleSeconds: 7);
      expect(cubit.state.isPaused, isFalse);

      cubit.pause();
      expect(cubit.state.isPaused, isTrue);

      final int remainingBefore = cubit.state.totalSecondsRemaining;
      cubit.tick(); // When paused, tick does nothing
      expect(cubit.state.totalSecondsRemaining, remainingBefore);

      cubit.resume();
      expect(cubit.state.isPaused, isFalse);

      cubit.tick();
      expect(cubit.state.totalSecondsRemaining, remainingBefore - 1);

      cubit.close();
    });
  });
}
