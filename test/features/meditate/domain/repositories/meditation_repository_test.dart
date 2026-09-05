import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import '../../../../support/fake_meditation_repository.dart';

void main() {
  group('MeditationRepository contract', () {
    late FakeMeditationRepository repository;

    setUp(() {
      repository = FakeMeditationRepository();
    });

    test('default last used exhale is 7 seconds', () async {
      expect(await repository.getLastUsedExhaleSeconds(), 7);
    });

    test('setLastUsedExhaleSeconds persists and reads back', () async {
      await repository.setLastUsedExhaleSeconds(12);
      expect(await repository.getLastUsedExhaleSeconds(), 12);

      await repository.setLastUsedExhaleSeconds(21);
      expect(await repository.getLastUsedExhaleSeconds(), 21);
    });

    test(
      'saveSession inserts new sessions and updates existing ones',
      () async {
        final DateTime now = DateTime.now();
        final MeditationSession session1 = MeditationSession(
          id: 's-1',
          type: 'anxiety_breath',
          source: 'manual',
          inhaleSec: 3,
          exhaleSec: 7,
          plannedDurationSec: 420,
          actualDurationSec: 420,
          status: 'completed',
          startedAt: now,
        );

        await repository.saveSession(session1);
        List<MeditationSession> all = await repository.getSessions();
        expect(all.length, 1);
        expect(all.first.id, 's-1');

        // Update session1 with mood
        final MeditationSession updated = session1.copyWith(mood: 'calmer');
        await repository.saveSession(updated);
        all = await repository.getSessions();
        expect(all.length, 1);
        expect(all.first.mood, 'calmer');

        // Insert session2
        final MeditationSession session2 = MeditationSession(
          id: 's-2',
          type: 'anxiety_breath',
          source: 'routine',
          inhaleSec: 3,
          exhaleSec: 12,
          plannedDurationSec: 420,
          actualDurationSec: 420,
          status: 'completed',
          startedAt: now,
        );
        await repository.saveSession(session2);
        all = await repository.getSessions();
        expect(all.length, 2);
      },
    );

    test(
      'getDailyAnxietyBreathCompletedCount only counts completed sessions on given date',
      () async {
        final DateTime today = DateTime(2026, 3, 15, 10, 0);
        final DateTime yesterday = DateTime(2026, 3, 14, 15, 0);

        // Session 1: completed today
        await repository.saveSession(
          MeditationSession(
            id: 's-1',
            type: 'anxiety_breath',
            source: 'manual',
            inhaleSec: 3,
            exhaleSec: 7,
            plannedDurationSec: 420,
            actualDurationSec: 420,
            status: 'completed',
            startedAt: today,
          ),
        );

        // Session 2: completed today
        await repository.saveSession(
          MeditationSession(
            id: 's-2',
            type: 'anxiety_breath',
            source: 'manual',
            inhaleSec: 3,
            exhaleSec: 12,
            plannedDurationSec: 420,
            actualDurationSec: 420,
            status: 'completed',
            startedAt: today.add(const Duration(hours: 2)),
          ),
        );

        // Session 3: cancelled today (not completed)
        await repository.saveSession(
          MeditationSession(
            id: 's-3',
            type: 'anxiety_breath',
            source: 'manual',
            inhaleSec: 3,
            exhaleSec: 7,
            plannedDurationSec: 420,
            actualDurationSec: 100,
            status: 'cancelled',
            startedAt: today.add(const Duration(hours: 4)),
          ),
        );

        // Session 4: completed yesterday
        await repository.saveSession(
          MeditationSession(
            id: 's-4',
            type: 'anxiety_breath',
            source: 'manual',
            inhaleSec: 3,
            exhaleSec: 7,
            plannedDurationSec: 420,
            actualDurationSec: 420,
            status: 'completed',
            startedAt: yesterday,
          ),
        );

        final int todayCount = await repository
            .getDailyAnxietyBreathCompletedCount(today);
        expect(todayCount, 2);

        final int yesterdayCount = await repository
            .getDailyAnxietyBreathCompletedCount(yesterday);
        expect(yesterdayCount, 1);
      },
    );
  });
}
