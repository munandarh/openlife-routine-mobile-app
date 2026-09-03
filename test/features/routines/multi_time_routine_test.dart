import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/notification_actions.dart';
import 'package:openlife_routine/core/storage/app_database.dart'
    show AppDatabase, RoutineLogQueries;
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// A vitamin or a prescription is taken several times a day, and every part of
/// the app used to assume exactly one: one schedule row, one log a day, one
/// notification slot per weekday. Marking the morning dose done marked the
/// evening one done with it.
void main() {
  late AppDatabase database;
  late RoutineRepository repository;

  final DateTime now = DateTime(2026, 9, 3, 9);

  Routine threeTimesADay() {
    return Routine(
      id: 'r-med',
      title: 'Antibiotic',
      category: RoutineCategory.medicine,
      reminderTimes: const <String>['08:00', '14:00', '20:00'],
      repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUpAll(() {
    // plannedSlots computes the next firing moment, which needs a zone.
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  });

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRoutineRepository(RoutineLocalDataSource(database));
  });

  tearDown(() async {
    await database.close();
  });

  group('storage', () {
    test('round-trips every time', () async {
      await repository.createRoutine(threeTimesADay());

      final Routine? stored = await repository.getRoutineById('r-med');
      expect(stored?.reminderTimes, <String>['08:00', '14:00', '20:00']);
    });

    test('a schedule written before this feature reads as one time', () {
      // The column held a bare 'HH:mm' until it started holding a list.
      expect(decodeReminderTimes('07:30'), <String>['07:30']);
    });

    test('times are sorted and de-duplicated', () {
      final Routine routine = threeTimesADay().copyWith(
        reminderTimes: <String>['20:00', '08:00', '08:00'],
      );

      // The notification slot a reminder occupies is its index here, so a
      // changed order would silently re-point live alarms.
      expect(routine.reminderTimes, <String>['08:00', '20:00']);
    });
  });

  group('logs', () {
    test('answering one dose leaves the others open', () async {
      await repository.createRoutine(threeTimesADay());

      await database.upsertRoutineLog(
        routineId: 'r-med',
        dateKey: '2026-09-03',
        reminderTime: '08:00',
        status: 'done',
      );

      expect(
        (await database.getRoutineLogByRoutineAndDate(
          'r-med',
          '2026-09-03',
          reminderTime: '08:00',
        ))?.status,
        'done',
      );
      // This is the bug: one log a day meant the 14:00 and 20:00 doses were
      // marked done by the morning one.
      expect(
        await database.getRoutineLogByRoutineAndDate(
          'r-med',
          '2026-09-03',
          reminderTime: '14:00',
        ),
        isNull,
      );
      expect(
        await database.getRoutineLogByRoutineAndDate(
          'r-med',
          '2026-09-03',
          reminderTime: '20:00',
        ),
        isNull,
      );
    });

    test('each dose keeps its own row rather than overwriting', () async {
      await repository.createRoutine(threeTimesADay());

      for (final String time in <String>['08:00', '14:00', '20:00']) {
        await database.upsertRoutineLog(
          routineId: 'r-med',
          dateKey: '2026-09-03',
          reminderTime: time,
          status: 'done',
        );
      }

      expect((await database.getRoutineLogsByDate('2026-09-03')).length, 3);
    });
  });

  group('notifications', () {
    test('every time gets a slot on every repeat day', () {
      final List<RoutineReminderSlot> slots =
          AppNotificationService.plannedSlots(<Routine>[
            threeTimesADay(),
          ], isIOS: false);

      // Three times across seven days: twenty-one alarms, not seven.
      expect(slots.length, 21);
      expect(
        slots.map((RoutineReminderSlot s) => s.reminderTime).toSet(),
        <String>{'08:00', '14:00', '20:00'},
      );
    });

    test('no two slots of one routine share a notification id', () {
      final List<RoutineReminderSlot> slots =
          AppNotificationService.plannedSlots(<Routine>[
            threeTimesADay(),
          ], isIOS: false);

      final Set<int> ids = slots
          .map(
            (RoutineReminderSlot slot) => routineNotificationId(
              slot.routine.id,
              routineReminderSlot(
                timeIndex: slot.timeIndex,
                weekday: slot.weekday,
              ),
            ),
          )
          .toSet();

      // A collision would mean one alarm silently replacing another.
      expect(ids.length, slots.length);
    });

    test('a snooze slot never collides with a reminder slot', () {
      final Set<int> reminders = <int>{
        for (int index = 0; index < maxReminderTimes; index += 1)
          for (int weekday = 1; weekday <= 7; weekday += 1)
            routineReminderSlot(timeIndex: index, weekday: weekday),
      };
      final Set<int> snoozes = <int>{
        for (int index = 0; index < maxReminderTimes; index += 1)
          routineSnoozeSlotFor(index),
      };

      expect(reminders.intersection(snoozes), isEmpty);
      expect(snoozes.contains(routineSnoozeSlot), isFalse);
      expect(snoozes.length, maxReminderTimes);
    });
  });

  group('summaries', () {
    test('a routine with several times reports how many', () {
      expect(threeTimesADay().hasMultipleTimes, isTrue);
      expect(threeTimesADay().reminderTimes.length, 3);
      expect(threeTimesADay().firstReminderTime, '08:00');
    });

    test('a single-time routine is not treated as multi', () {
      final Routine once = threeTimesADay().copyWith(
        reminderTimes: <String>['09:15'],
      );

      expect(once.hasMultipleTimes, isFalse);
      expect(once.firstReminderTime, '09:15');
    });
  });

  group('categories', () {
    test('only doses and custom offer more than one time', () {
      expect(RoutineCategory.vitamin.supportsMultipleTimes, isTrue);
      expect(RoutineCategory.medicine.supportsMultipleTimes, isTrue);
      expect(RoutineCategory.custom.supportsMultipleTimes, isTrue);

      expect(RoutineCategory.water.supportsMultipleTimes, isFalse);
      expect(RoutineCategory.meal.supportsMultipleTimes, isFalse);
      expect(RoutineCategory.sleep.supportsMultipleTimes, isFalse);
      expect(RoutineCategory.exercise.supportsMultipleTimes, isFalse);
      expect(RoutineCategory.breakTime.supportsMultipleTimes, isFalse);
    });
  });
}
