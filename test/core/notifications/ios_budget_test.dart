import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// iOS keeps only 64 pending notification requests and silently discards the
/// rest. Seven weekly slots per routine means a tenth routine already pushes
/// past the cap, and which reminders survived was left to the OS. The
/// whole-set sync now trims the list itself, soonest first, so the reminders
/// that survive are the next ones due. Android has no such cap.
void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  });

  /// [count] routines that each repeat on all seven days, at staggered times
  /// so "soonest first" has a defined order.
  List<Routine> routines(int count, {bool isEnabled = true}) {
    final DateTime now = DateTime(2026, 9, 2, 9);
    return List<Routine>.generate(count, (int i) {
      return Routine(
        id: 'r$i',
        title: 'Routine $i',
        category: RoutineCategory.water,
        reminderTime: '${(6 + i % 12).toString().padLeft(2, '0')}:00',
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: isEnabled,
        snoozeMinutes: 10,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  test('iOS stays under the pending cap with a large library', () {
    // 20 x 7 = 140 slots, far past what iOS will hold.
    final List<RoutineReminderSlot> slots = AppNotificationService.plannedSlots(
      routines(20),
      isIOS: true,
    );

    expect(slots.length, lessThan(AppNotificationService.iosPendingLimit));
  });

  test('the cap leaves room for a snooze to be scheduled later', () {
    final List<RoutineReminderSlot> slots = AppNotificationService.plannedSlots(
      routines(20),
      isIOS: true,
    );

    expect(
      AppNotificationService.iosPendingLimit - slots.length,
      greaterThanOrEqualTo(1),
    );
  });

  test('Android schedules every slot, having no such cap', () {
    final List<RoutineReminderSlot> slots = AppNotificationService.plannedSlots(
      routines(20),
      isIOS: false,
    );

    expect(slots, hasLength(140));
  });

  test('the reminders iOS keeps are the ones due soonest', () {
    final List<RoutineReminderSlot> kept = AppNotificationService.plannedSlots(
      routines(20),
      isIOS: true,
    );
    final List<RoutineReminderSlot> all = AppNotificationService.plannedSlots(
      routines(20),
      isIOS: false,
    );

    final List<tz.TZDateTime> keptTimes = kept
        .map((RoutineReminderSlot s) => s.firesAt)
        .toList();
    final List<tz.TZDateTime> everyTimeInOrder =
        all.map((RoutineReminderSlot s) => s.firesAt).toList()..sort();

    // What survived is exactly the front of the queue: nothing later was kept
    // in place of something earlier.
    expect(keptTimes, everyTimeInOrder.take(kept.length).toList());
  });

  test('a small library is scheduled in full on iOS too', () {
    final List<RoutineReminderSlot> slots = AppNotificationService.plannedSlots(
      routines(3),
      isIOS: true,
    );

    expect(slots, hasLength(21));
  });

  test('a disabled routine takes none of the budget', () {
    final List<RoutineReminderSlot> slots = AppNotificationService.plannedSlots(
      routines(3, isEnabled: false),
      isIOS: true,
    );

    expect(slots, isEmpty);
  });

  test('every slot fires in the future', () {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    for (final RoutineReminderSlot slot in AppNotificationService.plannedSlots(
      routines(5),
      isIOS: true,
    )) {
      expect(slot.firesAt.isAfter(now), isTrue);
    }
  });
}
