import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/domain/repositories/meditation_repository.dart';

/// Stable session ids make retries idempotent across the two local stores.
/// A crash after history is saved can be retried without duplicating history.
class MeditationSessionWriter {
  const MeditationSessionWriter(this.repository, this.database);
  final MeditationRepository repository;
  final AppDatabase database;
  Future<void> reconcileCompletedOccurrences() async {
    final sessions = await repository.getSessions();
    for (final session in sessions.where(
      (s) => s.status == 'completed' && s.occurrenceId != null,
    )) {
      final parts = session.occurrenceId!.split('|');
      if (parts.length == 3 &&
          parts[0] == session.routineId &&
          DateTime.tryParse(parts[1]) != null) {
        await save(session, occurrenceDate: parts[1], reminderTime: parts[2]);
      }
    }
  }

  Future<void> save(
    MeditationSession session, {
    String? occurrenceDate,
    String? reminderTime,
  }) async {
    if (session.status == 'completed' &&
        (session.actualDurationSec < session.plannedDurationSec ||
            session.completedAt == null)) {
      throw ArgumentError('An unfinished session cannot be marked complete.');
    }
    await repository.saveSession(session);
    if (session.status != 'completed' ||
        session.routineId == null ||
        occurrenceDate == null ||
        reminderTime == null) {
      return;
    }
    final existing = await database.getRoutineLogByRoutineAndDate(
      session.routineId!,
      occurrenceDate,
      reminderTime: reminderTime,
    );
    final bundle = await database.getRoutineBundleById(session.routineId!);
    if (bundle == null ||
        existing?.status == 'skipped' ||
        existing?.status == 'done') {
      return;
    }
    if (!bundle.schedule.reminderTime.split(',').contains(reminderTime)) return;
    await database.upsertRoutineLog(
      routineId: session.routineId!,
      dateKey: occurrenceDate,
      status: 'done',
      reminderTime: reminderTime,
    );
  }
}
