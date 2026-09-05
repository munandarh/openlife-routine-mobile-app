import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExportImportService {
  ExportImportService({
    required AppDatabase appDatabase,
    AppNotificationService? notificationService,
    SharedPreferencesAsync? meditationPreferences,
  }) : _appDatabase = appDatabase,
       _notificationService = notificationService,
       _meditationPreferences = meditationPreferences;

  final AppDatabase _appDatabase;
  final SharedPreferencesAsync? _meditationPreferences;

  /// Reminders live in the OS, not in the database, so both destructive and
  /// restorative data operations have to reach out and fix them too.
  final AppNotificationService? _notificationService;

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

    final meditation = await _meditationPreferences?.getString(
      'meditation.sessions',
    );
    if (meditation != null) data['meditationSessions'] = jsonDecode(meditation);
    final favorites = await _meditationPreferences?.getStringList(
      'meditation.favorites',
    );
    if (favorites != null) data['meditationFavorites'] = favorites;
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
        await _appDatabase
            .into(_appDatabase.routines)
            .insertOnConflictUpdate(
              RoutinesCompanion(
                id: drift.Value(map['id'] as String),
                title: drift.Value(map['title'] as String),
                category: drift.Value(map['category'] as String),
                iconKey: drift.Value(map['iconKey'] as String?),
                notes: drift.Value(map['notes'] as String?),
                isEnabled: drift.Value((map['isEnabled'] as bool?) ?? true),
                createdAt: drift.Value(
                  DateTime.parse(map['createdAt'] as String),
                ),
                updatedAt: drift.Value(
                  DateTime.parse(map['updatedAt'] as String),
                ),
              ),
            );
        count += 1;
      }
    }

    if (data.containsKey('routineSchedules')) {
      final List<dynamic> schedules = data['routineSchedules'] as List<dynamic>;
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
                updatedAt: drift.Value(
                  DateTime.parse(map['updatedAt'] as String),
                ),
              ),
            );
      }
    }

    if (data.containsKey('routineLogs')) {
      final List<dynamic> logs = data['routineLogs'] as List<dynamic>;
      for (final dynamic l in logs) {
        final Map<String, dynamic> map = l as Map<String, dynamic>;
        await _appDatabase
            .into(_appDatabase.routineLogs)
            .insertOnConflictUpdate(
              RoutineLogsCompanion(
                id: drift.Value(map['id'] as String),
                routineId: drift.Value(map['routineId'] as String),
                date: drift.Value(map['date'] as String),
                // Absent in a backup taken before a routine could hold more
                // than one time; those logs answered the routine's only one.
                reminderTime: drift.Value(
                  (map['reminderTime'] as String?) ?? '',
                ),
                status: drift.Value(map['status'] as String),
                snoozedUntil: drift.Value(
                  map['snoozedUntil'] == null
                      ? null
                      : DateTime.tryParse(map['snoozedUntil'] as String),
                ),
                createdAt: drift.Value(
                  DateTime.parse(map['createdAt'] as String),
                ),
                updatedAt: drift.Value(
                  DateTime.parse(map['updatedAt'] as String),
                ),
              ),
            );
      }
    }

    // An imported backup is worthless if it never reminds you of anything, so
    // schedule the routines it brought in rather than waiting for the next
    // cold start to sync them.
    await _notificationService?.syncRoutineSchedules(_appDatabase);

    if (_meditationPreferences != null && data['meditationSessions'] is List) {
      final current =
          jsonDecode(
                await _meditationPreferences.getString('meditation.sessions') ??
                    '[]',
              )
              as List<dynamic>;
      final byId = <String, dynamic>{
        for (final item in current)
          (item as Map<String, dynamic>)['id'] as String: item,
      };
      for (final item in data['meditationSessions'] as List<dynamic>) {
        if (item is Map<String, dynamic> &&
            item['id'] is String &&
            item['startedAt'] is String &&
            DateTime.tryParse(item['startedAt'] as String) != null) {
          byId[item['id'] as String] = item;
        }
      }
      await _meditationPreferences.setString(
        'meditation.sessions',
        jsonEncode(byId.values.toList()),
      );
    }
    if (data['meditationFavorites'] is List) {
      await _meditationPreferences?.setStringList(
        'meditation.favorites',
        (data['meditationFavorites'] as List).whereType<String>().toList(),
      );
    }
    return count;
  }

  Future<void> resetAllData() async {
    await _meditationPreferences?.clear(
      allowList: {
        'meditation.sessions',
        'meditation.favorites',
        'meditation.last_used_exhale',
        'meditation.music',
        'meditation.events',
      },
    );
    await _appDatabase.delete(_appDatabase.routineLogs).go();
    await _appDatabase.delete(_appDatabase.routineSchedules).go();
    await _appDatabase.delete(_appDatabase.routines).go();

    // Deleting the rows does not unschedule anything: without this the user
    // keeps being reminded of routines that no longer exist, and tapping one
    // opens a detail page for a missing routine.
    await _notificationService?.cancelAllRoutines();
  }

  Map<String, dynamic> _routineToJson(RoutineRowData r) {
    return <String, dynamic>{
      'id': r.id,
      'title': r.title,
      'category': r.category,
      'iconKey': r.iconKey,
      'notes': r.notes,
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
      'reminderTime': l.reminderTime,
      'status': l.status,
      'snoozedUntil': l.snoozedUntil?.toIso8601String(),
      'createdAt': l.createdAt.toIso8601String(),
      'updatedAt': l.updatedAt.toIso8601String(),
    };
  }
}
