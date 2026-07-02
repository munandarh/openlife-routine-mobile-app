import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;

class RoutineLocalDataSource {
  RoutineLocalDataSource(this._database);

  final AppDatabase _database;

  Future<void> createRoutine(domain.Routine routine) async {
    await _database.transaction(() async {
      await _database
          .into(_database.routines)
          .insert(
            RoutinesCompanion.insert(
              id: routine.id,
              title: routine.title,
              category: routine.category.name,
              notes: Value(routine.notes),
              isEnabled: Value(routine.isEnabled),
              createdAt: routine.createdAt,
              updatedAt: routine.updatedAt,
            ),
          );

      await _database
          .into(_database.routineSchedules)
          .insert(
            RoutineSchedulesCompanion.insert(
              id: '${routine.id}_schedule',
              routineId: routine.id,
              reminderTime: routine.reminderTime,
              repeatDays: jsonEncode(routine.repeatDays),
              snoozeMinutes: Value(routine.snoozeMinutes),
              updatedAt: routine.updatedAt,
            ),
          );
    });
  }

  Future<void> deleteRoutine(String id) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.routineLogs,
      )..where((RoutineLogsTable table) => table.routineId.equals(id))).go();
      await (_database.delete(
            _database.routineSchedules,
          )..where((RoutineSchedulesTable table) => table.routineId.equals(id)))
          .go();
      await (_database.delete(
        _database.routines,
      )..where((RoutinesTable table) => table.id.equals(id))).go();
    });
  }

  Future<domain.Routine?> getRoutineById(String id) async {
    final RoutineBundleRow? bundle = await _database.getRoutineBundleById(id);
    return bundle == null ? null : _mapBundle(bundle);
  }

  Future<void> updateRoutine(domain.Routine routine) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.routines,
      )..where((RoutinesTable table) => table.id.equals(routine.id))).write(
        RoutinesCompanion(
          title: Value(routine.title),
          category: Value(routine.category.name),
          isEnabled: Value(routine.isEnabled),
          updatedAt: Value(routine.updatedAt),
        ),
      );

      await (_database.update(_database.routineSchedules)..where(
            (RoutineSchedulesTable table) => table.routineId.equals(routine.id),
          ))
          .write(
            RoutineSchedulesCompanion(
              reminderTime: Value(routine.reminderTime),
              repeatDays: Value(jsonEncode(routine.repeatDays)),
              snoozeMinutes: Value(routine.snoozeMinutes),
              updatedAt: Value(routine.updatedAt),
            ),
          );
    });
  }

  Stream<List<domain.Routine>> watchRoutines() {
    return _database.watchRoutineBundles().map(
      (List<RoutineBundleRow> bundles) =>
          bundles.map(_mapBundle).toList()
            ..sort((domain.Routine a, domain.Routine b) {
              return a.reminderTime.compareTo(b.reminderTime);
            }),
    );
  }

  domain.Routine _mapBundle(RoutineBundleRow bundle) {
    return domain.Routine(
      id: bundle.routine.id,
      title: bundle.routine.title,
      category: domain.RoutineCategory.values.byName(bundle.routine.category),
      reminderTime: bundle.schedule.reminderTime,
      repeatDays: (jsonDecode(bundle.schedule.repeatDays) as List<dynamic>)
          .cast<int>(),
      isEnabled: bundle.routine.isEnabled,
      snoozeMinutes: bundle.schedule.snoozeMinutes,
      createdAt: bundle.routine.createdAt,
      updatedAt: bundle.routine.updatedAt,
    );
  }
}
