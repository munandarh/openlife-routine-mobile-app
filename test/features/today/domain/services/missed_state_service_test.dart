import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/today/domain/services/missed_state_service.dart';

void main() {
  late AppDatabase appDatabase;
  late MissedStateService service;

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    service = MissedStateService(appDatabase: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Future<void> seedRoutineWithPendingLog() async {
    // Seed a routine that repeats every day.
    await appDatabase.into(appDatabase.routines).insert(
      RoutinesCompanion(
        id: const Value('r1'),
        title: const Value('Breakfast'),
        category: const Value('meal'),
        isEnabled: const Value(true),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await appDatabase.into(appDatabase.routineSchedules).insert(
      RoutineSchedulesCompanion(
        id: const Value('s1'),
        routineId: const Value('r1'),
        reminderTime: const Value('07:00'),
        repeatDays: Value(jsonEncode(<int>[1, 2, 3, 4, 5, 6, 7])),
        snoozeMinutes: const Value(10),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  group('MissedStateService', () {
    test('markYesterdayPendingAsMissed marks pending logs from yesterday', () async {
      await seedRoutineWithPendingLog();

      // Create a pending log for yesterday.
      final DateTime yesterday = DateTime.now().subtract(
        const Duration(days: 1),
      );
      final String yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: yesterdayKey,
        status: 'pending',
      );

      final int count = await service.markYesterdayPendingAsMissed();
      expect(count, 1);

      // Verify the log was updated.
      final RoutineLogRowData? updated = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', yesterdayKey);
      expect(updated, isNotNull);
      expect(updated!.status, 'missed');
    });

    test('does not mark already-done logs', () async {
      await seedRoutineWithPendingLog();

      final DateTime yesterday = DateTime.now().subtract(
        const Duration(days: 1),
      );
      final String yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      // Done log — should not be changed.
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: yesterdayKey,
        status: 'done',
      );

      final int count = await service.markYesterdayPendingAsMissed();
      expect(count, 0);

      final RoutineLogRowData? log = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', yesterdayKey);
      expect(log!.status, 'done');
    });

    test('returns 0 when there are no pending logs', () async {
      await seedRoutineWithPendingLog();
      final int count = await service.markYesterdayPendingAsMissed();
      expect(count, 0);
    });

    test('only processes yesterday, not today', () async {
      await seedRoutineWithPendingLog();

      final DateTime now = DateTime.now();
      final String todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: todayKey,
        status: 'pending',
      );

      // markYesterday should NOT touch today's pending log.
      await service.markYesterdayPendingAsMissed();

      final RoutineLogRowData? todayLog = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', todayKey);
      expect(todayLog!.status, 'pending');
    });
  });
}
