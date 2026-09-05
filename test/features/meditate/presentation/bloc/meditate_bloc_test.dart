import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/domain/repositories/meditation_repository.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_bloc.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_event.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_state.dart';

class _MockMeditationRepository implements MeditationRepository {
  _MockMeditationRepository({
    this.completedCount = 2,
    this.lastExhale = 12,
    this.sessions = const <MeditationSession>[],
    this.shouldThrow = false,
  });

  final int completedCount;
  final int lastExhale;
  final List<MeditationSession> sessions;
  final bool shouldThrow;

  @override
  Future<void> saveSession(MeditationSession session) async {}

  @override
  Future<List<MeditationSession>> getSessions() async {
    if (shouldThrow) throw Exception('Storage error');
    return sessions;
  }

  @override
  Future<int> getDailyAnxietyBreathCompletedCount(DateTime date) async {
    if (shouldThrow) throw Exception('Storage error');
    return completedCount;
  }

  @override
  Future<int> getLastUsedExhaleSeconds() async {
    if (shouldThrow) throw Exception('Storage error');
    return lastExhale;
  }

  @override
  Future<void> setLastUsedExhaleSeconds(int seconds) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeditateBloc', () {
    test('initial state has initial status', () {
      final MeditateBloc bloc = MeditateBloc(
        repository: _MockMeditationRepository(),
      );
      expect(bloc.state.status, MeditateStatus.initial);
      expect(bloc.state.anxietyBreathCompletedToday, 0);
      bloc.close();
    });

    test(
      'MeditateStarted loads completed count, last exhale, and sessions',
      () async {
        final List<MeditationSession> sampleSessions = <MeditationSession>[
          MeditationSession(
            id: 's1',
            type: 'anxiety_breath',
            source: 'manual',
            inhaleSec: 3,
            exhaleSec: 7,
            plannedDurationSec: 420,
            actualDurationSec: 420,
            status: 'completed',
            startedAt: DateTime(2026, 1, 1, 10, 0),
            completedAt: DateTime(2026, 1, 1, 10, 7),
          ),
        ];

        final MeditateBloc bloc = MeditateBloc(
          repository: _MockMeditationRepository(
            completedCount: 3,
            lastExhale: 21,
            sessions: sampleSessions,
          ),
        );

        bloc.add(const MeditateStarted());
        await expectLater(
          bloc.stream,
          emitsInOrder(<dynamic>[
            const MeditateState(status: MeditateStatus.loading),
            MeditateState(
              status: MeditateStatus.loaded,
              anxietyBreathCompletedToday: 3,
              lastUsedExhale: 21,
              recentSessions: sampleSessions,
            ),
          ]),
        );

        unawaited(bloc.close());
      },
    );

    test('MeditateRefreshRequested updates data', () async {
      final MeditateBloc bloc = MeditateBloc(
        repository: _MockMeditationRepository(completedCount: 4, lastExhale: 7),
      );

      bloc.add(const MeditateRefreshRequested());
      await expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          const MeditateState(
            status: MeditateStatus.loaded,
            anxietyBreathCompletedToday: 4,
            lastUsedExhale: 7,
          ),
        ]),
      );

      unawaited(bloc.close());
    });

    test('emits failure state on repository exception', () async {
      final MeditateBloc bloc = MeditateBloc(
        repository: _MockMeditationRepository(shouldThrow: true),
      );

      bloc.add(const MeditateStarted());
      await expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          const MeditateState(status: MeditateStatus.loading),
          predicate<MeditateState>(
            (MeditateState s) =>
                s.status == MeditateStatus.failure &&
                s.errorMessage != null &&
                s.errorMessage!.contains('Storage error'),
          ),
        ]),
      );

      unawaited(bloc.close());
    });
  });
}
