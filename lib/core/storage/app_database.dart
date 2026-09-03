import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Routines extends Table {
  TextColumn get id => text()();

  TextColumn get title => text().withLength(min: 1, max: 60)();

  TextColumn get category => text()();

  /// Optional icon override. Null means "use the category default".
  TextColumn get iconKey => text().nullable()();

  TextColumn get notes => text().nullable()();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class RoutineSchedules extends Table {
  TextColumn get id => text()();

  TextColumn get routineId => text().references(Routines, #id)();

  /// One or more `HH:mm` values, comma-separated — the same shape
  /// [repeatDays] already uses. A medicine taken three times a day is one
  /// routine with three times, not three routines.
  TextColumn get reminderTime => text()();

  TextColumn get repeatDays => text()();

  IntColumn get snoozeMinutes => integer().withDefault(const Constant(10))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class RoutineLogs extends Table {
  TextColumn get id => text()();

  TextColumn get routineId => text().references(Routines, #id)();

  TextColumn get date => text()();

  /// Which of the routine's reminder times this log answers, as `HH:mm`.
  ///
  /// Without it a routine taken morning and night had one log a day, so
  /// marking the morning dose done marked the evening one done too. Rows
  /// written before this column existed carry the routine's first time.
  TextColumn get reminderTime => text().withDefault(const Constant(''))();

  /// One of: `done`, `skipped`, `missed`, `snoozed`.
  TextColumn get status => text()();

  /// Set only while [status] is `snoozed`: the moment the reminder is due
  /// again. Null for every other status.
  DateTimeColumn get snoozedUntil => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
      path.join(directory.path, 'openlife_routine.sqlite'),
    );

    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: <Type>[Routines, RoutineSchedules, RoutineLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.addColumn(routines, routines.notes);
      }
      if (from < 3) {
        await migrator.addColumn(routineLogs, routineLogs.snoozedUntil);
      }
      if (from < 4) {
        await migrator.addColumn(routines, routines.iconKey);
      }
      if (from < 5) {
        await migrator.addColumn(routineLogs, routineLogs.reminderTime);
        // Existing logs answered the routine's only time, so point them
        // at it. Left blank they would orphan every past completion the
        // moment a second time was added, and the streak would reset.
        await customStatement(
          'UPDATE routine_logs SET reminder_time = COALESCE(('
          'SELECT substr(s.reminder_time, 1, 5) FROM routine_schedules s '
          'WHERE s.routine_id = routine_logs.routine_id'
          "), '') WHERE reminder_time = ''",
        );
      }
    },
  );

  Future<RoutineBundleRow?> getRoutineBundleById(String routineId) async {
    final RoutineRowData? routine =
        await (select(routines)
              ..where((RoutinesTable table) => table.id.equals(routineId)))
            .getSingleOrNull();
    if (routine == null) {
      return null;
    }

    final RoutineScheduleRowData? schedule =
        await (select(routineSchedules)..where(
              (RoutineSchedulesTable table) =>
                  table.routineId.equals(routineId),
            ))
            .getSingleOrNull();
    if (schedule == null) {
      return null;
    }

    return RoutineBundleRow(routine: routine, schedule: schedule);
  }

  Future<List<RoutineBundleRow>> getRoutineBundles() async {
    final List<RoutineRowData> routineRows = await select(routines).get();
    return _hydrateRoutineBundles(routineRows);
  }

  Stream<List<RoutineBundleRow>> watchRoutineBundles() {
    return select(routines).watch().asyncMap(_hydrateRoutineBundles);
  }

  Future<List<RoutineBundleRow>> _hydrateRoutineBundles(
    List<RoutineRowData> routineRows,
  ) async {
    final List<RoutineBundleRow> bundles = <RoutineBundleRow>[];

    for (final RoutineRowData routine in routineRows) {
      final RoutineScheduleRowData? schedule =
          await (select(routineSchedules)..where(
                (RoutineSchedulesTable table) =>
                    table.routineId.equals(routine.id),
              ))
              .getSingleOrNull();
      if (schedule == null) {
        continue;
      }

      bundles.add(RoutineBundleRow(routine: routine, schedule: schedule));
    }

    return bundles;
  }
}

class RoutineBundleRow {
  const RoutineBundleRow({required this.routine, required this.schedule});

  final RoutineRowData routine;
  final RoutineScheduleRowData schedule;
}

typedef RoutinesTable = Routines;
typedef RoutineSchedulesTable = RoutineSchedules;
typedef RoutineLogsTable = RoutineLogs;
typedef RoutineRowData = Routine;
typedef RoutineScheduleRowData = RoutineSchedule;
typedef RoutineLogRowData = RoutineLog;

extension RoutineLogQueries on AppDatabase {
  Future<List<RoutineLogRowData>> getRoutineLogsByDate(String dateKey) {
    return (select(
      routineLogs,
    )..where((RoutineLogsTable table) => table.date.equals(dateKey))).get();
  }

  /// The log for one reminder of one routine on one day.
  ///
  /// [reminderTime] identifies which reminder: a routine with a morning and an
  /// evening dose keeps a log for each, and answering one must not answer the
  /// other.
  Future<RoutineLogRowData?> getRoutineLogByRoutineAndDate(
    String routineId,
    String dateKey, {
    required String reminderTime,
  }) {
    return (select(routineLogs)..where(
          (RoutineLogsTable table) =>
              table.routineId.equals(routineId) &
              table.date.equals(dateKey) &
              table.reminderTime.equals(reminderTime),
        ))
        .getSingleOrNull();
  }

  Future<void> upsertRoutineLog({
    required String routineId,
    required String dateKey,
    required String status,
    required String reminderTime,
    DateTime? snoozedUntil,
  }) async {
    final DateTime now = DateTime.now();
    final RoutineLogRowData? existingLog = await getRoutineLogByRoutineAndDate(
      routineId,
      dateKey,
      reminderTime: reminderTime,
    );

    await into(routineLogs).insertOnConflictUpdate(
      RoutineLogsCompanion(
        id: Value(existingLog?.id ?? '${routineId}_${dateKey}_$reminderTime'),
        routineId: Value(routineId),
        date: Value(dateKey),
        reminderTime: Value(reminderTime),
        status: Value(status),
        // Only a snoozed log carries a wake-up time; every other status
        // clears whatever a previous snooze left behind.
        snoozedUntil: Value(status == 'snoozed' ? snoozedUntil : null),
        createdAt: Value(existingLog?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  /// All logs between [fromDateKey] and [toDateKey] inclusive, used by the
  /// 7-day history and the missed-state sweep.
  Future<List<RoutineLogRowData>> getRoutineLogsBetween(
    String fromDateKey,
    String toDateKey,
  ) {
    return (select(routineLogs)..where(
          (RoutineLogsTable table) =>
              table.date.isBiggerOrEqualValue(fromDateKey) &
              table.date.isSmallerOrEqualValue(toDateKey),
        ))
        .get();
  }

  Future<void> deleteRoutineLog(
    String routineId,
    String dateKey, {
    required String reminderTime,
  }) {
    return (delete(routineLogs)..where(
          (RoutineLogsTable table) =>
              table.routineId.equals(routineId) &
              table.date.equals(dateKey) &
              table.reminderTime.equals(reminderTime),
        ))
        .go();
  }
}
