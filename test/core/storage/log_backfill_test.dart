import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';

/// Logs written before this schema knew about reminder times carry none.
///
/// Left blank they would match no reminder the routine actually has, so every
/// past completion would vanish from Today and the streak would reset to zero
/// on upgrade. The migration points them at the routine's first time; this
/// covers the statement that does it.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> seedRoutine(String id, String storedTimes) async {
    final DateTime created = DateTime(2026, 1, 1);
    await database
        .into(database.routines)
        .insert(
          RoutinesCompanion.insert(
            id: id,
            title: 'Routine $id',
            category: 'medicine',
            createdAt: created,
            updatedAt: created,
          ),
        );
    await database
        .into(database.routineSchedules)
        .insert(
          RoutineSchedulesCompanion.insert(
            id: '${id}_schedule',
            routineId: id,
            reminderTime: storedTimes,
            repeatDays: '[1,2,3,4,5,6,7]',
            updatedAt: created,
          ),
        );
  }

  Future<void> insertLegacyLog(String routineId, String date) async {
    final DateTime created = DateTime(2026, 1, 1);
    await database
        .into(database.routineLogs)
        .insert(
          RoutineLogsCompanion.insert(
            id: '${routineId}_$date',
            routineId: routineId,
            date: date,
            status: 'done',
            createdAt: created,
            updatedAt: created,
          ),
        );
  }

  /// The statement the v5 migration runs.
  Future<void> runBackfill() {
    return database.customStatement(
      'UPDATE routine_logs SET reminder_time = COALESCE(('
      'SELECT substr(s.reminder_time, 1, 5) FROM routine_schedules s '
      'WHERE s.routine_id = routine_logs.routine_id'
      "), '') WHERE reminder_time = ''",
    );
  }

  test('an old log adopts its routine only time', () async {
    await seedRoutine('r1', '07:30');
    await insertLegacyLog('r1', '2026-02-01');

    await runBackfill();

    final RoutineLogRowData? log = await database.getRoutineLogByRoutineAndDate(
      'r1',
      '2026-02-01',
      reminderTime: '07:30',
    );
    expect(log?.status, 'done');
  });

  test(
    'with several times stored it takes the first, not the whole list',
    () async {
      // substr(...,1,5) is what keeps this from writing '08:00,14:00,20:00'
      // into a column every lookup compares against a single 'HH:mm'.
      await seedRoutine('r2', '08:00,14:00,20:00');
      await insertLegacyLog('r2', '2026-02-02');

      await runBackfill();

      expect(
        (await database.getRoutineLogByRoutineAndDate(
          'r2',
          '2026-02-02',
          reminderTime: '08:00',
        ))?.status,
        'done',
      );
    },
  );

  test(
    'a log whose routine is gone is left blank rather than nulled',
    () async {
      // A null would break the not-null column; the COALESCE is load-bearing.
      await insertLegacyLog('orphan', '2026-02-03');

      await runBackfill();

      final List<RoutineLogRowData> logs = await database.getRoutineLogsByDate(
        '2026-02-03',
      );
      expect(logs.single.reminderTime, '');
    },
  );

  test('a log that already names a time is left alone', () async {
    await seedRoutine('r3', '09:00');
    await database.upsertRoutineLog(
      routineId: 'r3',
      dateKey: '2026-02-04',
      reminderTime: '21:00',
      status: 'done',
    );

    await runBackfill();

    expect(
      (await database.getRoutineLogsByDate('2026-02-04')).single.reminderTime,
      '21:00',
    );
  });
}
