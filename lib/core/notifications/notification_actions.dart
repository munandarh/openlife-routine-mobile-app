import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Action ids carried on the notification and echoed back in the response.
const String notificationDoneActionId = 'done';
const String notificationSnoozeActionId = 'snooze';

/// What a notification carries so an action can be handled without the app
/// running: the routine, which of its reminder times fired, its snooze length,
/// and its title.
///
/// Pipe-delimited with the title last, so a title containing '|' still
/// round-trips. The `v2` marker distinguishes this from the payloads older
/// builds wrote (`id|minutes|title`), which are still sitting on any reminder
/// scheduled before the upgrade and must keep working.
@immutable
class RoutineNotificationPayload {
  const RoutineNotificationPayload({
    required this.routineId,
    required this.snoozeMinutes,
    required this.title,
    this.reminderTime = '',
  });

  static const String _marker = 'v2';

  final String routineId;
  final int snoozeMinutes;
  final String title;

  /// Which reminder of the day this is, as `HH:mm`.
  ///
  /// Empty on a payload written before routines could have several, which the
  /// handler reads as the routine's first time.
  final String reminderTime;

  String encode() => '$routineId|$snoozeMinutes|$_marker|$reminderTime|$title';

  static RoutineNotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final List<String> parts = raw.split('|');
    final int snoozeMinutes = parts.length > 1
        ? int.tryParse(parts[1]) ?? 10
        : 10;

    if (parts.length >= 5 && parts[2] == _marker) {
      return RoutineNotificationPayload(
        routineId: parts.first,
        snoozeMinutes: snoozeMinutes,
        reminderTime: parts[3],
        title: parts.sublist(4).join('|'),
      );
    }

    return RoutineNotificationPayload(
      routineId: parts.first,
      snoozeMinutes: snoozeMinutes,
      title: parts.length > 2 ? parts.sublist(2).join('|') : parts.first,
    );
  }
}

/// The result of applying an action, so the caller can re-arm a snooze.
@immutable
class NotificationActionResult {
  const NotificationActionResult({required this.snoozedUntil});

  final DateTime? snoozedUntil;
}

/// Writes the log a notification action implies.
///
/// Shared by the foreground handler and the background isolate so tapping
/// "Done" on a reminder has the same effect whether or not the app happens to
/// be running — before this, a notification snooze re-armed the alarm but left
/// Today showing the routine as still due.
Future<NotificationActionResult> applyRoutineNotificationAction({
  required AppDatabase database,
  required RoutineNotificationPayload payload,
  required String actionId,
  DateTime? now,
}) async {
  final DateTime moment = now ?? DateTime.now();
  final String dateKey = routineLogDateKey(moment);
  final String reminderTime = await _resolveReminderTime(database, payload);

  switch (actionId) {
    case notificationDoneActionId:
      await database.upsertRoutineLog(
        routineId: payload.routineId,
        dateKey: dateKey,
        reminderTime: reminderTime,
        status: 'done',
      );
      return const NotificationActionResult(snoozedUntil: null);

    case notificationSnoozeActionId:
      final DateTime until = moment.add(
        Duration(minutes: payload.snoozeMinutes),
      );
      await database.upsertRoutineLog(
        routineId: payload.routineId,
        dateKey: dateKey,
        reminderTime: reminderTime,
        status: 'snoozed',
        snoozedUntil: until,
      );
      return NotificationActionResult(snoozedUntil: until);
  }

  return const NotificationActionResult(snoozedUntil: null);
}

/// Which reminder the payload answers.
///
/// A payload written before routines could hold several times carries none, so
/// it answers the routine's first — the only one such a routine had when the
/// notification was scheduled.
Future<String> _resolveReminderTime(
  AppDatabase database,
  RoutineNotificationPayload payload,
) async {
  if (payload.reminderTime.isNotEmpty) {
    return payload.reminderTime;
  }

  final RoutineBundleRow? bundle = await database.getRoutineBundleById(
    payload.routineId,
  );
  final String stored = bundle?.schedule.reminderTime ?? '';
  return stored.split(',').first.trim();
}

/// `yyyy-MM-dd` key used by the logs table.
String routineLogDateKey(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

/// Handles a notification action when the app is not running.
///
/// Runs in its own isolate with no access to the app's objects, so it opens the
/// database itself and closes it again. Must stay a top-level function with the
/// `vm:entry-point` pragma or the tear-off cannot be resolved after AOT.
@pragma('vm:entry-point')
Future<void> handleNotificationActionInBackground(
  NotificationResponse response,
) async {
  final String? actionId = response.actionId;
  if (actionId == null) {
    return;
  }

  final RoutineNotificationPayload? payload = RoutineNotificationPayload.decode(
    response.payload,
  );
  if (payload == null) {
    return;
  }

  DartPluginRegistrant.ensureInitialized();

  final AppDatabase database = AppDatabase();
  try {
    final NotificationActionResult result =
        await applyRoutineNotificationAction(
          database: database,
          payload: payload,
          actionId: actionId,
        );

    final DateTime? snoozedUntil = result.snoozedUntil;
    if (snoozedUntil != null) {
      await rescheduleSnoozeFromBackground(
        payload: payload,
        scheduledFor: snoozedUntil,
      );
    }
  } finally {
    await database.close();
  }
}

/// Notification channel, duplicated here because the background isolate builds
/// its own notification without the service object.
///
/// The id carries a version suffix on purpose. Android freezes a channel's
/// importance at the moment it is created: once `routine_reminders` existed at
/// anything below high, no amount of code could raise it again — only the user
/// could, buried in system settings — and every reminder after that arrived
/// silently, with no banner and no sound. Publishing a new id is the only way
/// an app can guarantee its own importance. Bump it again if these settings
/// ever need to change.
const String routineChannelId = 'routine_reminders_high_v2';
const String routineChannelName = 'Routine reminders';
const String routineChannelDescription =
    'Reminder notifications for daily routines';

/// Channels this app created in earlier builds, deleted at startup so the
/// user's notification settings do not accumulate a dead entry per version.
const List<String> legacyRoutineChannelIds = <String>['routine_reminders'];

/// The channel as it must exist before the first reminder is posted.
///
/// Created explicitly at startup rather than left to the plugin, which only
/// creates it when a notification is first shown — by which time a reminder
/// has already been missed if anything about the channel was wrong.
const AndroidNotificationChannel routineNotificationChannel =
    AndroidNotificationChannel(
      routineChannelId,
      routineChannelName,
      description: routineChannelDescription,
      // A reminder that arrives without a banner is a reminder that does not
      // arrive: this app exists to interrupt.
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

/// iOS attaches actions to a category registered once at startup, not to the
/// individual notification the way Android does. Every routine reminder is
/// posted under this id so the Done and Snooze buttons appear on iOS too.
const String routineCategoryId = 'routine_reminder';

/// The manual "does anything arrive at all?" notification. Far outside every
/// routine's id range so it can never collide with a real reminder.
const int testReminderNotificationId = 424242;

/// Slot for a one-off snooze. Weekday slots 1-7 belong to the recurring
/// schedule, so re-arming a snooze never cancels a weekly reminder.
const int routineSnoozeSlot = 99;

/// The most reminder times one routine may hold.
///
/// The cap exists so the notification id space stays collision-free: a
/// reminder's slot is `timeIndex * 8 + weekday`, which needs the index bounded
/// to keep every routine's ids inside a predictable range, and so cancelling a
/// routine can sweep every slot it could ever have used.
const int maxReminderTimes = 8;

/// The slot for one reminder time on one weekday.
///
/// Weekdays are 1-7 and the eighth value in each block is left unused, so
/// index 0 owns 1-7, index 1 owns 9-15, and no two ever meet.
int routineReminderSlot({required int timeIndex, required int weekday}) =>
    timeIndex * 8 + weekday;

/// The snooze slot for one reminder time.
///
/// Snoozing the morning dose must not cancel a snooze on the evening one, so
/// each time gets its own. Kept well clear of the reminder blocks and of the
/// legacy [routineSnoozeSlot].
int routineSnoozeSlotFor(int timeIndex) => 900 + timeIndex;

/// The one place a routine reminder's presentation is described.
///
/// The reminder is scheduled from three places (the weekly schedule, an
/// in-app snooze, and the background isolate's snooze), and iOS was originally
/// missing from all three because each built its own [NotificationDetails]
/// with only an `android:` section. Building it here means a platform cannot
/// be forgotten in one site and remembered in another.
NotificationDetails routineNotificationDetails({
  required AppLocalizations strings,
  required int snoozeMinutes,
}) {
  return NotificationDetails(
    android: AndroidNotificationDetails(
      routineChannelId,
      routineChannelName,
      channelDescription: routineChannelDescription,
      // Importance governs the channel, priority the individual post, and
      // both have to be at the top for a heads-up banner. Losing either one
      // downgrades the reminder to a silent line in the shade.
      importance: Importance.max,
      priority: Priority.high,
      // Tells the OS this is a time-critical reminder rather than chatter,
      // which keeps it out of the notification-cooldown bucketing vendors
      // apply to ordinary posts.
      category: AndroidNotificationCategory.reminder,
      // Readable on a lock screen, which is where a morning dose is answered.
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ticker: 'reminder',
      autoCancel: true,
      // Both handled without opening the app: a reminder you have to launch
      // the app to answer is a reminder people stop answering.
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          notificationDoneActionId,
          strings.notificationDoneAction,
        ),
        AndroidNotificationAction(
          notificationSnoozeActionId,
          strings.notificationSnoozeAction(snoozeMinutes),
        ),
      ],
    ),
    iOS: const DarwinNotificationDetails(
      categoryIdentifier: routineCategoryId,
      // The buttons themselves come from the category registered at startup;
      // see [routineNotificationCategories].
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}

/// The iOS categories to register in `DarwinInitializationSettings`.
///
/// Unlike Android, iOS fixes the action labels at registration time, so the
/// snooze button cannot show each routine's own duration — hence the generic
/// label. Neither action carries `foreground`, which is what lets iOS answer
/// a reminder without opening the app, the same as Android.
List<DarwinNotificationCategory> routineNotificationCategories(
  AppLocalizations strings,
) {
  return <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      routineCategoryId,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          notificationDoneActionId,
          strings.notificationDoneAction,
        ),
        DarwinNotificationAction.plain(
          notificationSnoozeActionId,
          strings.notificationSnoozeActionGeneric,
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    ),
  ];
}

/// Stable notification id for a routine on a given slot.
int routineNotificationId(String routineId, int slot) {
  int hash = slot;
  for (final int codeUnit in routineId.codeUnits) {
    hash = ((hash * 31) + codeUnit) & 0x7fffffff;
  }
  return hash;
}

/// The language the user chose, read straight from preferences.
///
/// The background isolate has no SettingsBloc, and a reminder in the wrong
/// language is a visible regression, so the value is read from the same key the
/// settings repository writes.
Future<AppLocalizations> loadReminderStrings() async {
  String code = 'en';
  try {
    code =
        await SharedPreferencesAsync().getString('settings.language_code') ??
        'en';
  } on Object {
    // Preferences are unavailable in some isolates; English is a safe default.
  }

  final Locale locale = Locale(code);
  return AppLocalizations.delegate.isSupported(locale)
      ? AppLocalizations.delegate.load(locale)
      : AppLocalizations.delegate.load(const Locale('en'));
}

/// Re-arms the snooze reminder from the background isolate.
Future<void> rescheduleSnoozeFromBackground({
  required RoutineNotificationPayload payload,
  required DateTime scheduledFor,
}) async {
  tz.initializeTimeZones();

  final AppLocalizations strings = await loadReminderStrings();
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  final NotificationDetails details = routineNotificationDetails(
    strings: strings,
    snoozeMinutes: payload.snoozeMinutes,
  );

  try {
    await plugin.zonedSchedule(
      id: routineNotificationId(payload.routineId, routineSnoozeSlot),
      title: payload.title,
      body: strings.notificationReminderBody(payload.title),
      scheduledDate: tz.TZDateTime.from(scheduledFor, tz.local),
      notificationDetails: details,
      payload: payload.encode(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  } on PlatformException catch (error) {
    if (error.code != 'exact_alarms_not_permitted') {
      rethrow;
    }
    await plugin.zonedSchedule(
      id: routineNotificationId(payload.routineId, routineSnoozeSlot),
      title: payload.title,
      body: strings.notificationReminderBody(payload.title),
      scheduledDate: tz.TZDateTime.from(scheduledFor, tz.local),
      notificationDetails: details,
      payload: payload.encode(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
