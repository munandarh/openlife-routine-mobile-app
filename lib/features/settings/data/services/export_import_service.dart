import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:openlife_routine/core/storage/app_database.dart';

class ExportImportService {
  ExportImportService({required AppDatabase appDatabase})
    : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

  Future<String> exportToJson() async {
    final Map<String, dynamic> data = <String, dynamic>{};

    final List<RoutineRowData> routines = await _appDatabase
        .select(_appDatabase.routines)
        .get();
    data['routines'] = routines.map(_routineToJson).toList();

    final List<RoutineScheduleRowData> schedules = await _appDatabase
        .select(_appDatabase.routineSchedules)
        .get();
    data['routineSchedules'] = schedules.map(_scheduleToJson).toList();

    final List<RoutineLogRowData> logs = await _appDatabase
        .select(_appDatabase.routineLogs)
        .get();
    data['routineLogs'] = logs.map(_logToJson).toList();

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<int> importFromJson(String jsonString) async {
    final Map<String, dynamic> data =
        jsonDecode(jsonString) as Map<String, dynamic>;

    int count = 0;

    if (data.containsKey('routines')) {
      final List<dynamic> routines = data['routines'] as List<dynamic>;
      for (final dynamic r in routines) {
        final Map<String, dynamic> map = r as Map<String, dynamic>;
        await _appDatabase.into(_appDatabase.routines).insertOnConflictUpdate(
          RoutinesCompanion(
            id: drift.Value(map['id'] as String),
            title: drift.Value(map['title'] as String),
            category: drift.Value(map['category'] as String),
            isEnabled: drift.Value((map['isEnabled'] as bool?) ?? true),
            createdAt: drift.Value(DateTime.parse(
              map['createdAt'] as String,
            )),
            updatedAt: drift.Value(DateTime.parse(
              map['updatedAt'] as String,
            )),
          ),
        );
        count += 1;
      }
    }

    if (data.containsKey('routineSchedules')) {
      final List<dynamic> schedules =
          data['routineSchedules'] as List<dynamic>;
      for (final dynamic s in schedules) {
        final Map<String, dynamic> map = s as Map<String, dynamic>;
        await _appDatabase
            .into(_appDatabase.routineSchedules)
            .insertOnConflictUpdate(
              RoutineSchedulesCompanion(
                id: drift.Value(map['id'] as String),
                routineId: drift.Value(map['routineId'] as String),
                reminderTime: drift.Value(map['reminderTime'] as String),
                repeatDays: drift.Value(map['repeatDays'] as String),
                snoozeMinutes: drift.Value(
                  (map['snoozeMinutes'] as int?) ?? 10,
                ),
                updatedAt: drift.Value(DateTime.parse(
                  map['updatedAt'] as String,
                )),
              ),
            );
      }
    }

    if (data.containsKey('routineLogs')) {
      final List<dynamic> logs = data['routineLogs'] as List<dynamic>;
      for (final dynamic l in logs) {
        final Map<String, dynamic> map = l as Map<String, dynamic>;
        await _appDatabase.into(_appDatabase.routineLogs).insertOnConflictUpdate(
          RoutineLogsCompanion(
            id: drift.Value(map['id'] as String),
            routineId: drift.Value(map['routineId'] as String),
            date: drift.Value(map['date'] as String),
            status: drift.Value(map['status'] as String),
            createdAt: drift.Value(DateTime.parse(
              map['createdAt'] as String,
            )),
            updatedAt: drift.Value(DateTime.parse(
              map['updatedAt'] as String,
            )),
          ),
        );
      }
    }

    return count;
  }

  Future<void> resetAllData() async {
    await _appDatabase.delete(_appDatabase.routineLogs).go();
    await _appDatabase.delete(_appDatabase.routineSchedules).go();
    await _appDatabase.delete(_appDatabase.routines).go();
  }

  Map<String, dynamic> _routineToJson(RoutineRowData r) {
    return <String, dynamic>{
      'id': r.id,
      'title': r.title,
      'category': r.category,
      'isEnabled': r.isEnabled,
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _scheduleToJson(RoutineScheduleRowData s) {
    return <String, dynamic>{
      'id': s.id,
      'routineId': s.routineId,
      'reminderTime': s.reminderTime,
      'repeatDays': s.repeatDays,
      'snoozeMinutes': s.snoozeMinutes,
      'updatedAt': s.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _logToJson(RoutineLogRowData l) {
    return <String, dynamic>{
      'id': l.id,
      'routineId': l.routineId,
      'date': l.date,
      'status': l.status,
      'createdAt': l.createdAt.toIso8601String(),
      'updatedAt': l.updatedAt.toIso8601String(),
    };
  }
}
