import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/bootstrap.dart';
import 'package:openlife_routine/core/storage/app_database.dart';

import '../support/fake_settings_repository.dart';

void main() {
  late AppDatabase appDatabase;

  // Wednesday.
  final DateTime now = DateTime(2026, 7, 1, 9);

  String keyFor(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());

    // Created well before the sweep window: the sweep never marks a day the
    // routine did not yet exist, so a routine created "now" would close out
    // nothing.
    final DateTime created = now.subtract(const Duration(days: 60));

    await appDatabase
        .into(appDatabase.routines)
        .insert(
          RoutinesCompanion(
            id: const Value('r1'),
            title: const Value('Breakfast'),
            category: const Value('meal'),
            isEnabled: const Value(true),
            createdAt: Value(created),
            updatedAt: Value(created),
          ),
        );
    await appDatabase
        .into(appDatabase.routineSchedules)
        .insert(
          RoutineSchedulesCompanion(
            id: const Value('s1'),
            routineId: const Value('r1'),
            reminderTime: const Value('07:00'),
            repeatDays: Value(jsonEncode(<int>[1, 2, 3, 4, 5, 6, 7])),
            snoozeMinutes: const Value(10),
            updatedAt: Value(created),
          ),
        );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  group('closeOutPastDays', () {
    test('closes out days since the recorded sweep', () async {
      final FakeSettingsRepository settings = FakeSettingsRepository(
        lastMissedSweepDate: now.subtract(const Duration(days: 3)),
      );

      await closeOutPastDays(
        appDatabase: appDatabase,
        settingsRepository: settings,
        nowProvider: () => now,
      );

      for (int i = 1; i <= 2; i += 1) {
        final RoutineLogRowData? log = await appDatabase
            .getRoutineLogByRoutineAndDate(
              'r1',
              keyFor(now.subtract(Duration(days: i))),
            );
        expect(log?.status, 'missed');
      }
    });

    test('records yesterday as the new watermark, not today', () async {
      final FakeSettingsRepository settings = FakeSettingsRepository(
        lastMissedSweepDate: now.subtract(const Duration(days: 3)),
      );

      await closeOutPastDays(
        appDatabase: appDatabase,
        settingsRepository: settings,
        nowProvider: () => now,
      );

      // Recording "today" would make the sweep skip today forever once
      // tomorrow arrives.
      expect(
        await settings.getLastMissedSweepDate(),
        DateTime(2026, 6, 30),
      );
    });

    test('leaves today untouched', () async {
      final FakeSettingsRepository settings = FakeSettingsRepository(
        lastMissedSweepDate: now.subtract(const Duration(days: 3)),
      );

      await closeOutPastDays(
        appDatabase: appDatabase,
        settingsRepository: settings,
        nowProvider: () => now,
      );

      final RoutineLogRowData? todayLog = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', keyFor(now));
      expect(todayLog, isNull);
    });

    test('running twice in one day writes nothing the second time', () async {
      final FakeSettingsRepository settings = FakeSettingsRepository(
        lastMissedSweepDate: now.subtract(const Duration(days: 2)),
      );

      await closeOutPastDays(
        appDatabase: appDatabase,
        settingsRepository: settings,
        nowProvider: () => now,
      );
      final RoutineLogRowData first = (await appDatabase
          .getRoutineLogByRoutineAndDate(
            'r1',
            keyFor(now.subtract(const Duration(days: 1))),
          ))!;

      await closeOutPastDays(
        appDatabase: appDatabase,
        settingsRepository: settings,
        nowProvider: () => now,
      );
      final RoutineLogRowData second = (await appDatabase
          .getRoutineLogByRoutineAndDate(
            'r1',
            keyFor(now.subtract(const Duration(days: 1))),
          ))!;

      expect(second.updatedAt, first.updatedAt);
    });
  });
}
