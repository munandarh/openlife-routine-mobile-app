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
  int get schemaVersion => 4;

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

  Future<RoutineLogRowData?> getRoutineLogByRoutineAndDate(
    String routineId,
    String dateKey,
  ) {
    return (select(routineLogs)..where(
          (RoutineLogsTable table) =>
              table.routineId.equals(routineId) & table.date.equals(dateKey),
        ))
        .getSingleOrNull();
  }

  Future<void> upsertRoutineLog({
    required String routineId,
    required String dateKey,
    required String status,
    DateTime? snoozedUntil,
  }) async {
    final DateTime now = DateTime.now();
    final RoutineLogRowData? existingLog = await getRoutineLogByRoutineAndDate(
      routineId,
      dateKey,
    );

    await into(routineLogs).insertOnConflictUpdate(
      RoutineLogsCompanion(
        id: Value(existingLog?.id ?? '${routineId}_$dateKey'),
        routineId: Value(routineId),
        date: Value(dateKey),
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

  Future<void> deleteRoutineLog(String routineId, String dateKey) {
    return (delete(routineLogs)..where(
          (RoutineLogsTable table) =>
              table.routineId.equals(routineId) & table.date.equals(dateKey),
        ))
        .go();
  }
}
