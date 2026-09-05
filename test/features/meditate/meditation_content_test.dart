import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_practice.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/breathing_player_cubit.dart';

void main() {
  test(
    'all six categories have distinct content, bilingual guidance and bundled music',
    () {
      final practices = MeditationPractice.all;
      expect(practices.map((p) => p.id).toSet().length, practices.length);
      expect(practices.map((p) => p.category).toSet(), {
        'calm',
        'focus',
        'reset',
        'sleep',
        'breathe',
        'stress',
      });
      for (final p in practices) {
        expect(p.promptsEn.length, greaterThanOrEqualTo(6));
        expect(p.promptsId.length, p.promptsEn.length);
        expect(p.guidance(0, false), isNot(p.guidance(1, false)));
        expect(p.guidance(.5, true), isNot(p.guidance(.5, false)));
        expect(
          File('assets/audio/${p.sound}.m4a').lengthSync(),
          greaterThan(100000),
        );
      }
      expect(practices.map((p) => p.sound).toSet().length, 9);
      expect(
        File('assets/audio/forest_stream_flow.m4a').lengthSync(),
        greaterThan(100000),
      );
    },
  );
  test('local-time hero uses four real practices across midnight', () {
    expect(MeditationPractice.forHour(8).id, 'morning_reset');
    expect(MeditationPractice.forHour(13).id, 'midday_pause');
    expect(MeditationPractice.forHour(19).id, 'evening_unwind');
    expect(MeditationPractice.forHour(23).id, 'sleep');
    expect(MeditationPractice.forHour(0).id, 'sleep');
  });
  test(
    'all breathing modes finish only on tick 420 and never emit another completion',
    () async {
      for (final seconds in [7, 12, 21]) {
        final cubit = BreathingPlayerCubit(
          exhaleSeconds: seconds,
          autoStart: false,
        );
        var completions = 0;
        final subscription = cubit.stream.listen((s) {
          if (s.isCompleted) completions++;
        });
        for (var i = 0; i < 419; i++) {
          cubit.tick();
        }
        expect(cubit.state.isCompleted, false);
        expect(
          cubit.state.cycleIndex,
          seconds == 7
              ? 42
              : seconds == 12
              ? 28
              : 17,
        );
        cubit.tick();
        for (var i = 0; i < 30; i++) {
          cubit.tick();
        }
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.totalSecondsRemaining, 0);
        expect(completions, 1);
        await subscription.cancel();
        await cubit.close();
      }
    },
  );
  test('unsupported exhale values are rejected at the engine boundary', () {
    for (final seconds in [0, 3, 8, 13, 22]) {
      expect(
        () => BreathingPlayerCubit(exhaleSeconds: seconds, autoStart: false),
        throwsArgumentError,
      );
    }
  });
}
