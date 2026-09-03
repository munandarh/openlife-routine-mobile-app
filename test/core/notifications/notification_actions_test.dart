import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/notification_actions.dart';
import 'package:openlife_routine/core/storage/app_database.dart';

/// Answering a reminder from the notification used to change nothing in the
/// app: snoozing re-armed the alarm but wrote no log, so Today kept showing the
/// routine as due, and there was no way to complete one at all.
void main() {
  late AppDatabase database;

  final DateTime now = DateTime(2026, 9, 2, 7, 30);
  const RoutineNotificationPayload payload = RoutineNotificationPayload(
    routineId: 'r1',
    snoozeMinutes: 15,
    reminderTime: '08:00',
    title: 'Morning hydration',
  );

  String todayKey() => routineLogDateKey(now);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('payload', () {
    test('round-trips', () {
      final RoutineNotificationPayload decoded =
          RoutineNotificationPayload.decode(payload.encode())!;

      expect(decoded.routineId, 'r1');
      expect(decoded.snoozeMinutes, 15);
      expect(decoded.reminderTime, '08:00');
      expect(decoded.title, 'Morning hydration');
    });

    test('a title that looks like the marker still round-trips', () {
      const RoutineNotificationPayload awkward = RoutineNotificationPayload(
        routineId: 'r1',
        snoozeMinutes: 10,
        reminderTime: '09:00',
        title: 'v2',
      );

      final RoutineNotificationPayload decoded =
          RoutineNotificationPayload.decode(awkward.encode())!;
      expect(decoded.title, 'v2');
      expect(decoded.reminderTime, '09:00');
    });

    test('keeps a title containing the delimiter', () {
      const RoutineNotificationPayload awkward = RoutineNotificationPayload(
        routineId: 'r1',
        snoozeMinutes: 10,
        title: 'Water | Vitamin',
      );

      expect(
        RoutineNotificationPayload.decode(awkward.encode())!.title,
        'Water | Vitamin',
      );
    });

    test('still parses the two-field form written by older builds', () {
      final RoutineNotificationPayload decoded =
          RoutineNotificationPayload.decode('r7|20')!;

      expect(decoded.routineId, 'r7');
      expect(decoded.snoozeMinutes, 20);
    });

    test('returns null for nothing', () {
      expect(RoutineNotificationPayload.decode(null), isNull);
      expect(RoutineNotificationPayload.decode(''), isNull);
    });
  });

  group('applying an action', () {
    test(
      'a payload from an older build answers the routine first time',
      () async {
        // Reminders scheduled before this build carry no time. Writing their
        // log with an empty one would hide it from a screen that asks for the
        // routine's actual times.
        final DateTime created = DateTime(2026, 1, 1);
        await database
            .into(database.routines)
            .insert(
              RoutinesCompanion.insert(
                id: 'r1',
                title: 'Morning hydration',
                category: 'water',
                createdAt: created,
                updatedAt: created,
              ),
            );
        await database
            .into(database.routineSchedules)
            .insert(
              RoutineSchedulesCompanion.insert(
                id: 'r1_schedule',
                routineId: 'r1',
                reminderTime: '08:00,20:00',
                repeatDays: '[1,2,3,4,5,6,7]',
                updatedAt: created,
              ),
            );

        await applyRoutineNotificationAction(
          database: database,
          payload: RoutineNotificationPayload.decode(
            'r1|15|Morning hydration',
          )!,
          actionId: notificationDoneActionId,
          now: now,
        );

        final RoutineLogRowData? log = await database
            .getRoutineLogByRoutineAndDate(
              'r1',
              todayKey(),
              reminderTime: '08:00',
            );
        expect(log?.status, 'done');
      },
    );

    test('done marks the routine complete for today', () async {
      final NotificationActionResult result =
          await applyRoutineNotificationAction(
            database: database,
            payload: payload,
            actionId: notificationDoneActionId,
            now: now,
          );

      expect(result.snoozedUntil, isNull);
      final RoutineLogRowData log = (await database
          .getRoutineLogByRoutineAndDate(
            'r1',
            todayKey(),
            reminderTime: '08:00',
          ))!;
      expect(log.status, 'done');
    });

    test(
      'snooze records the wake-up time from the routine own duration',
      () async {
        final NotificationActionResult result =
            await applyRoutineNotificationAction(
              database: database,
              payload: payload,
              actionId: notificationSnoozeActionId,
              now: now,
            );

        // 15 minutes, not the 10-minute default.
        expect(result.snoozedUntil, now.add(const Duration(minutes: 15)));
        final RoutineLogRowData log = (await database
            .getRoutineLogByRoutineAndDate(
              'r1',
              todayKey(),
              reminderTime: '08:00',
            ))!;
        expect(log.status, 'snoozed');
        expect(log.snoozedUntil, now.add(const Duration(minutes: 15)));
      },
    );

    test(
      'done after a snooze replaces the snooze and clears its wake-up',
      () async {
        await applyRoutineNotificationAction(
          database: database,
          payload: payload,
          actionId: notificationSnoozeActionId,
          now: now,
        );
        await applyRoutineNotificationAction(
          database: database,
          payload: payload,
          actionId: notificationDoneActionId,
          now: now,
        );

        final RoutineLogRowData log = (await database
            .getRoutineLogByRoutineAndDate(
              'r1',
              todayKey(),
              reminderTime: '08:00',
            ))!;
        expect(log.status, 'done');
        expect(log.snoozedUntil, isNull);
      },
    );

    test('an unknown action writes nothing', () async {
      await applyRoutineNotificationAction(
        database: database,
        payload: payload,
        actionId: 'something-else',
        now: now,
      );

      expect(
        await database.getRoutineLogByRoutineAndDate(
          'r1',
          todayKey(),
          reminderTime: '08:00',
        ),
        isNull,
      );
    });
  });

  group('notification ids', () {
    test('a snooze never collides with a weekday slot', () {
      final Set<int> weekdayIds = <int>{
        for (int weekday = 1; weekday <= 7; weekday += 1)
          routineNotificationId('r1', weekday),
      };

      expect(
        weekdayIds.contains(routineNotificationId('r1', routineSnoozeSlot)),
        isFalse,
      );
    });

    test('is stable for the same routine and slot', () {
      expect(routineNotificationId('r1', 3), routineNotificationId('r1', 3));
      expect(
        routineNotificationId('r1', 3),
        isNot(routineNotificationId('r2', 3)),
      );
    });
  });
}
