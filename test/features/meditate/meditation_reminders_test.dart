import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/notification_actions.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  const payload = RoutineNotificationPayload(
    routineId: 'r1',
    snoozeMinutes: 10,
    title: 'Anxiety | Breath',
    reminderTime: '23:56',
    weekday: 6,
    isAnxietyBreath: true,
  );
  test('notification retains slot and original local date across midnight', () {
    final decoded = RoutineNotificationPayload.decode(payload.encode())!;
    expect(decoded.title, 'Anxiety | Breath');
    expect(decoded.isAnxietyBreath, true);
    expect(decoded.reminderTime, '23:56');
    expect(decoded.dateKeyAt(DateTime(2026, 9, 6, 0, 3)), '2026-09-05');
  });
  test('five daily reminders have unique notification and snooze slots', () {
    final slots = <int>{};
    for (var time = 0; time < 5; time++) {
      for (var day = 1; day <= 7; day++) {
        expect(
          slots.add(
            routineNotificationId(
              'r1',
              routineReminderSlot(timeIndex: time, weekday: day),
            ),
          ),
          true,
        );
      }
      expect(
        slots.add(routineNotificationId('r1', routineSnoozeSlotFor(time))),
        true,
      );
    }
    expect(slots.length, 40);
  });
  test(
    'anxiety routine enforces five unique times and fixed session rules',
    () {
      final now = DateTime.now();
      final routine = domain.Routine(
        id: 'r1',
        title: 'Breath',
        category: domain.RoutineCategory.anxietyBreath,
        reminderTimes: ['08:00', '11:00', '14:00', '17:00', '20:00'],
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );
      routine.validateMeditationSchedule();
      tz.initializeTimeZones();
      final planned = AppNotificationService.plannedSlots([
        routine,
      ], isIOS: false);
      expect(planned.length, 35);
      for (var weekday = 1; weekday <= 7; weekday++) {
        expect(
          planned
              .where((slot) => slot.weekday == weekday)
              .map((s) => s.reminderTime)
              .toSet(),
          routine.reminderTimes.toSet(),
        );
      }
      expect(routine.dailyTarget, 5);
      expect(routine.sessionDurationSec, 420);
      expect(routine.inhaleSec, 3);
      expect(
        () => routine
            .copyWith(reminderTimes: ['08:00'])
            .validateMeditationSchedule(),
        throwsArgumentError,
      );
      expect(
        () => routine
            .copyWith(
              reminderTimes: ['08:00', '08:00', '14:00', '17:00', '20:00'],
            )
            .validateMeditationSchedule(),
        throwsArgumentError,
      );
    },
  );
  test(
    'notification Done cannot bypass breathing; snooze and skip preserve occurrence',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final now = DateTime(2026, 9, 6, 0, 3);
      await applyRoutineNotificationAction(
        database: db,
        payload: payload,
        actionId: notificationDoneActionId,
        now: now,
      );
      expect(await db.getRoutineLogsByDate('2026-09-05'), isEmpty);
      await applyRoutineNotificationAction(
        database: db,
        payload: payload,
        actionId: notificationSnoozeActionId,
        now: now,
      );
      var logs = await db.getRoutineLogsByDate('2026-09-05');
      expect(logs.single.status, 'snoozed');
      expect(logs.single.reminderTime, '23:56');
      await applyRoutineNotificationAction(
        database: db,
        payload: payload,
        actionId: notificationSkipActionId,
        now: now,
      );
      logs = await db.getRoutineLogsByDate('2026-09-05');
      expect(logs.single.status, 'skipped');
      expect(await db.getRoutineLogsByDate('2026-09-06'), isEmpty);
      await db.close();
    },
  );
}
