import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/settings/data/services/export_import_service.dart';

/// Reminders live in the OS alarm table, not in the database. Deleting the
/// rows leaves the alarms behind, so "Reset all data" kept reminding the user
/// of routines that no longer existed; importing a backup did the opposite and
/// restored routines that would never remind anyone.
void main() {
  late AppDatabase appDatabase;
  late _RecordingNotificationService notifications;
  late ExportImportService service;

  final DateTime now = DateTime(2026, 9, 2, 9);

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    notifications = _RecordingNotificationService();
    service = ExportImportService(
      appDatabase: appDatabase,
      notificationService: notifications,
    );

    await appDatabase
        .into(appDatabase.routines)
        .insert(
          RoutinesCompanion(
            id: const Value('r1'),
            title: const Value('Drink water'),
            category: const Value('water'),
            isEnabled: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await appDatabase
        .into(appDatabase.routineSchedules)
        .insert(
          RoutineSchedulesCompanion(
            id: const Value('s1'),
            routineId: const Value('r1'),
            reminderTime: const Value('09:40'),
            repeatDays: Value(jsonEncode(<int>[1, 2, 3])),
            snoozeMinutes: const Value(10),
            updatedAt: Value(now),
          ),
        );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('reset cancels the reminders it just deleted the routines for', () async {
    await service.resetAllData();

    expect(notifications.cancelAllCount, 1);
    expect(await appDatabase.select(appDatabase.routines).get(), isEmpty);
  });

  test('import schedules reminders for the routines it restored', () async {
    final String backup = await service.exportToJson();
    await service.resetAllData();

    final int imported = await service.importFromJson(backup);

    expect(imported, 1);
    expect(notifications.syncCount, 1);
  });

  test('a restored routine keeps its reminder time', () async {
    final String backup = await service.exportToJson();
    await service.resetAllData();
    await service.importFromJson(backup);

    final List<RoutineScheduleRowData> schedules = await appDatabase
        .select(appDatabase.routineSchedules)
        .get();

    expect(schedules, hasLength(1));
    expect(schedules.single.reminderTime, '09:40');
  });
}

class _RecordingNotificationService extends AppNotificationService {
  _RecordingNotificationService() : super.noop();

  int cancelAllCount = 0;
  int syncCount = 0;

  @override
  Future<void> cancelAllRoutines() async {
    cancelAllCount += 1;
  }

  @override
  Future<void> syncRoutineSchedules(AppDatabase appDatabase) async {
    syncCount += 1;
  }
}
