import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  test('notification ids are stable per routine and weekday', () {
    expect(
      AppNotificationService.notificationIdFor('routine-1', 1),
      AppNotificationService.notificationIdFor('routine-1', 1),
    );
    expect(
      AppNotificationService.notificationIdFor('routine-1', 1),
      isNot(AppNotificationService.notificationIdFor('routine-1', 2)),
    );
  });

  test('next weekly date rolls forward to the requested weekday and time', () {
    final date = AppNotificationService.nextWeeklyDateFor(
      now: DateTime(2026, 7, 1, 9),
      weekday: DateTime.wednesday,
      reminderTime: '08:00',
    );

    expect(date.weekday, DateTime.wednesday);
    expect(date.hour, 8);
    expect(date.minute, 0);
    expect(date.isAfter(DateTime(2026, 7, 1, 9)), true);
  });
}
