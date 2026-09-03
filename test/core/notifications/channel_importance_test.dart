import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/notification_actions.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// On a real phone every reminder arrived silently or not at all.
///
/// Android freezes a channel's importance when the channel is created: a
/// channel that ever existed below high can never be raised by code again.
/// These assertions are the contract that keeps a reminder loud, and the id
/// check is what makes a future change to that contract actually take effect.
void main() {
  late AppLocalizations strings;

  setUpAll(() async {
    strings = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('the channel is created at the highest importance', () {
    expect(routineNotificationChannel.importance, Importance.max);
    expect(routineNotificationChannel.playSound, isTrue);
    expect(routineNotificationChannel.enableVibration, isTrue);
  });

  test('the channel id is versioned away from the one shipped before', () {
    // Reusing 'routine_reminders' would inherit whatever importance that
    // channel was first created with on the user's phone, which is exactly
    // the bug this replaced.
    expect(routineNotificationChannel.id, routineChannelId);
    expect(legacyRoutineChannelIds, contains('routine_reminders'));
    expect(legacyRoutineChannelIds, isNot(contains(routineChannelId)));
  });

  test('a reminder posts at high priority in the same channel', () {
    final AndroidNotificationDetails? android = routineNotificationDetails(
      strings: strings,
      snoozeMinutes: 10,
    ).android;

    expect(android, isNotNull);
    // Importance governs the channel and priority the post; a heads-up banner
    // needs both, and losing either downgrades the reminder to a silent line.
    expect(android!.importance, Importance.max);
    expect(android.priority, Priority.high);
    expect(android.channelId, routineChannelId);
    expect(android.category, AndroidNotificationCategory.reminder);
    expect(android.visibility, NotificationVisibility.public);
  });

  test('the test reminder cannot collide with a routine slot', () {
    final Set<int> routineSlots = <int>{
      for (int index = 0; index < maxReminderTimes; index += 1) ...<int>{
        for (int weekday = 1; weekday <= 7; weekday += 1)
          routineReminderSlot(timeIndex: index, weekday: weekday),
        routineSnoozeSlotFor(index),
      },
    };

    expect(routineSlots, isNot(contains(testReminderNotificationId)));
  });
}
