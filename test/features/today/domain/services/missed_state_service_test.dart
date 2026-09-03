import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/today/domain/services/missed_state_service.dart';

void main() {
  late AppDatabase appDatabase;

  /// Fixed clock so the sweep window is deterministic. 2026-09-01 is a Tuesday.
  final DateTime now = DateTime(2026, 9, 1, 10);
  DateTime nowProvider() => now;

  MissedStateService serviceWith({int maxLookbackDays = 30}) {
    return MissedStateService(
      appDatabase: appDatabase,
      nowProvider: nowProvider,
      maxLookbackDays: maxLookbackDays,
    );
  }

  String keyFor(DateTime date) => MissedStateService.dateKey(date);

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Future<void> seedRoutine({
    String id = 'r1',
    List<int> repeatDays = const <int>[1, 2, 3, 4, 5, 6, 7],
    bool isEnabled = true,
    DateTime? createdAt,
  }) async {
    final DateTime created =
        createdAt ?? now.subtract(const Duration(days: 60));
    await appDatabase
        .into(appDatabase.routines)
        .insert(
          RoutinesCompanion(
            id: Value(id),
            title: Value('Routine $id'),
            category: const Value('meal'),
            isEnabled: Value(isEnabled),
            createdAt: Value(created),
            updatedAt: Value(created),
          ),
        );
    await appDatabase
        .into(appDatabase.routineSchedules)
        .insert(
          RoutineSchedulesCompanion(
            id: Value('${id}_schedule'),
            routineId: Value(id),
            reminderTime: const Value('07:00'),
            repeatDays: Value(jsonEncode(repeatDays)),
            snoozeMinutes: const Value(10),
            updatedAt: Value(now),
          ),
        );
  }

  group('sweepMissedDays', () {
    test('marks an unlogged past day as missed', () async {
      await seedRoutine();
      final DateTime yesterday = now.subtract(const Duration(days: 1));

      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 2)),
      );

      expect(written, 1);
      final RoutineLogRowData? log = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', keyFor(yesterday));
      expect(log, isNotNull);
      expect(log!.status, 'missed');
    });

    test('never touches today', () async {
      await seedRoutine();

      await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 2)),
      );

      final RoutineLogRowData? todayLog = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', keyFor(now));
      expect(todayLog, isNull);
    });

    test('leaves a resolved day alone', () async {
      await seedRoutine();
      final DateTime yesterday = now.subtract(const Duration(days: 1));
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(yesterday),
        status: 'done',
      );

      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 2)),
      );

      expect(written, 0);
      final RoutineLogRowData? log = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', keyFor(yesterday));
      expect(log!.status, 'done');
    });

    test('a skipped day stays skipped', () async {
      await seedRoutine();
      final DateTime yesterday = now.subtract(const Duration(days: 1));
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(yesterday),
        status: 'skipped',
      );

      await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 2)),
      );

      final RoutineLogRowData? log = await appDatabase
          .getRoutineLogByRoutineAndDate('r1', keyFor(yesterday));
      expect(log!.status, 'skipped');
    });

    test(
      'a snooze left hanging over the end of the day becomes missed',
      () async {
        await seedRoutine();
        final DateTime yesterday = now.subtract(const Duration(days: 1));
        await appDatabase.upsertRoutineLog(
          routineId: 'r1',
          dateKey: keyFor(yesterday),
          status: 'snoozed',
          snoozedUntil: yesterday,
        );

        await serviceWith().sweepMissedDays(
          since: now.subtract(const Duration(days: 2)),
        );

        final RoutineLogRowData? log = await appDatabase
            .getRoutineLogByRoutineAndDate('r1', keyFor(yesterday));
        expect(log!.status, 'missed');
        expect(log.snoozedUntil, isNull);
      },
    );

    test(
      'catches up on every day since the last sweep, not just yesterday',
      () async {
        await seedRoutine();

        // App last swept 5 days ago, so days -4 .. -1 must all be closed out.
        final int written = await serviceWith().sweepMissedDays(
          since: now.subtract(const Duration(days: 5)),
        );

        expect(written, 4);
        for (int i = 1; i <= 4; i += 1) {
          final RoutineLogRowData? log = await appDatabase
              .getRoutineLogByRoutineAndDate(
                'r1',
                keyFor(now.subtract(Duration(days: i))),
              );
          expect(log?.status, 'missed', reason: 'day -$i should be missed');
        }
      },
    );

    test('skips weekdays the routine does not repeat on', () async {
      // Repeats on Tuesdays only; the sweep window below contains exactly one.
      await seedRoutine(repeatDays: <int>[DateTime.tuesday]);

      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 8)),
      );

      expect(written, 1);
    });

    test('ignores disabled routines', () async {
      await seedRoutine(isEnabled: false);

      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 3)),
      );

      expect(written, 0);
    });

    test('does nothing when it already ran for yesterday', () async {
      await seedRoutine();

      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 1)),
      );

      expect(written, 0);
    });

    test('a first run is capped by the lookback window', () async {
      await seedRoutine();

      // No previous sweep: with a 3-day window only days -3, -2 and -1 close.
      final int written = await serviceWith(
        maxLookbackDays: 3,
      ).sweepMissedDays();

      expect(written, 3);
    });

    test('never marks days before the routine was created', () async {
      // Created two days ago: only yesterday and the day before can be missed.
      await seedRoutine(createdAt: now.subtract(const Duration(days: 2)));

      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 10)),
      );

      expect(written, 2);
      final RoutineLogRowData? beforeCreation = await appDatabase
          .getRoutineLogByRoutineAndDate(
            'r1',
            keyFor(now.subtract(const Duration(days: 5))),
          );
      expect(beforeCreation, isNull);
    });

    test('a routine created today is never back-filled as missed', () async {
      await seedRoutine(createdAt: now);

      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 10)),
      );

      expect(written, 0);
    });

    test('returns 0 when there are no routines at all', () async {
      final int written = await serviceWith().sweepMissedDays(
        since: now.subtract(const Duration(days: 3)),
      );

      expect(written, 0);
    });
  });
}
