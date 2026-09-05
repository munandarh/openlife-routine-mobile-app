import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';

void main() {
  group('MeditationSession', () {
    final DateTime started = DateTime(2026, 1, 1, 8, 0, 0);
    final DateTime completed = DateTime(2026, 1, 1, 8, 7, 0);

    final MeditationSession session = MeditationSession(
      id: 'session-1',
      type: 'anxiety_breath',
      source: 'manual',
      inhaleSec: 3,
      exhaleSec: 7,
      plannedDurationSec: 420,
      actualDurationSec: 420,
      status: 'completed',
      startedAt: started,
      completedAt: completed,
      routineId: 'routine-123',
      occurrenceId: 'occ-456',
      mood: 'calmer',
    );

    test('serializes to JSON and deserializes back correctly', () {
      final Map<String, dynamic> json = session.toJson();
      final MeditationSession restored = MeditationSession.fromJson(json);

      expect(restored, equals(session));
      expect(restored.id, 'session-1');
      expect(restored.type, 'anxiety_breath');
      expect(restored.source, 'manual');
      expect(restored.inhaleSec, 3);
      expect(restored.exhaleSec, 7);
      expect(restored.plannedDurationSec, 420);
      expect(restored.actualDurationSec, 420);
      expect(restored.status, 'completed');
      expect(restored.startedAt, started);
      expect(restored.completedAt, completed);
      expect(restored.routineId, 'routine-123');
      expect(restored.occurrenceId, 'occ-456');
      expect(restored.mood, 'calmer');
    });

    test('copyWith creates updated copy with new values', () {
      final MeditationSession updated = session.copyWith(
        status: 'cancelled',
        actualDurationSec: 120,
        mood: 'same',
      );

      expect(updated.id, session.id);
      expect(updated.status, 'cancelled');
      expect(updated.actualDurationSec, 120);
      expect(updated.mood, 'same');
      expect(updated.exhaleSec, session.exhaleSec);
    });

    test('equality and props work as expected', () {
      final MeditationSession copy = session.copyWith();
      expect(session, equals(copy));
      expect(session.hashCode, equals(copy.hashCode));
    });
  });
}
