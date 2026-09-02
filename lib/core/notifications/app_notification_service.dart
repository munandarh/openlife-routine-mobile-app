import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:openlife_routine/core/notifications/notification_actions.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppNotificationService {
  AppNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    MethodChannel? timezoneChannel,
    bool? isIOS,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _timezoneChannel =
           timezoneChannel ?? const MethodChannel('openlife_routine/timezone'),
       _isIOS = isIOS ?? defaultTargetPlatform == TargetPlatform.iOS;

  AppNotificationService.noop()
    : _plugin = FlutterLocalNotificationsPlugin(),
      _timezoneChannel = const MethodChannel('openlife_routine/timezone'),
      _isIOS = false,
      _disabled = true;

  /// iOS keeps at most [iosPendingLimit] pending notification requests and
  /// silently discards the rest, so the full-set sync has to choose which
  /// reminders survive rather than letting the OS pick arbitrarily. Android
  /// has no such cap.
  static const int iosPendingLimit = 64;

  /// Held back from the weekly budget so a snooze can always be scheduled.
  static const int _iosSnoozeReserve = 4;

  final FlutterLocalNotificationsPlugin _plugin;
  final MethodChannel _timezoneChannel;
  final bool _isIOS;
  final StreamController<String> _routineTapController =
      StreamController<String>.broadcast();
  final StreamController<String> _routineActionController =
      StreamController<String>.broadcast();
  bool _disabled = false;
  Locale _locale = const Locale('en');

  /// Set once at startup so a notification action handled while the app is
  /// alive can write the same log the background isolate would.
  AppDatabase? _database;

  void attachDatabase(AppDatabase database) {
    _database = database;
  }

  Stream<String> get routineTapStream => _routineTapController.stream;

  /// Emits when a notification action changed a routine, so open screens can
  /// reload instead of showing stale state.
  Stream<String> get routineActionStream => _routineActionController.stream;

  /// Notifications are built outside any widget tree, so the service keeps its
  /// own copy of the chosen language and resolves strings from the generated
  /// delegate directly.
  void setLanguageCode(String languageCode) {
    _locale = Locale(languageCode);
  }

  Future<AppLocalizations> _strings() {
    return AppLocalizations.delegate.isSupported(_locale)
        ? AppLocalizations.delegate.load(_locale)
        : AppLocalizations.delegate.load(const Locale('en'));
  }

  Future<String?> initialize() async {
    if (_disabled) {
      return null;
    }

    tz.initializeTimeZones();
    await _setLocalTimeZone();

    // iOS fixes its action buttons at registration time, so the categories
    // have to be built here, from the language already chosen. This is why
    // `setLanguageCode` runs before `initialize` at startup.
    final AppLocalizations strings = await _strings();

    try {
      await _plugin.initialize(
        settings: InitializationSettings(
          android: const AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            // Asked for explicitly in `requestPermissions`, after onboarding
            // has explained why, rather than in the first frame.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            notificationCategories: routineNotificationCategories(strings),
          ),
        ),
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            handleNotificationActionInBackground,
      );
    } on PlatformException catch (error) {
      // Losing reminders is bad; failing to open the app at all is worse.
      // Disable the stack and let the rest of the app run.
      debugPrint('Notification init failed (${error.code}): ${error.message}');
      _disabled = true;
      return null;
    }

    final NotificationAppLaunchDetails? launchDetails = await _plugin
        .getNotificationAppLaunchDetails();
    return RoutineNotificationPayload.decode(
      launchDetails?.notificationResponse?.payload,
    )?.routineId;
  }

  Future<void> requestPermissions() async {
    if (_disabled) {
      return;
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
    // Without this iOS never shows the permission prompt, and every reminder
    // is silently dropped with no error to notice.
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncRoutineSchedules(AppDatabase appDatabase) async {
    if (_disabled) {
      return;
    }

    final List<RoutineBundleRow> bundles = await appDatabase
        .getRoutineBundles();
    final List<domain.Routine> routines = bundles
        .map(_routineFromBundle)
        .toList();

    // Rebuild each routine's own weekly slots rather than `cancelAll()`, which
    // also dropped any pending snooze and dismissed a reminder that was on
    // screen — every time the app was opened.
    for (final domain.Routine routine in routines) {
      await cancelRoutine(routine.id);
    }

    final AppLocalizations strings = await _strings();
    for (final RoutineReminderSlot slot in plannedSlots(
      routines,
      isIOS: _isIOS,
    )) {
      await _scheduleSlot(
        routine: slot.routine,
        weekday: slot.weekday,
        strings: strings,
      );
    }
  }

  /// Every weekday of every enabled routine, in the order they will fire.
  ///
  /// On Android that is simply all of them. On iOS the list is trimmed to what
  /// the OS will actually keep, soonest first, so the reminders that survive
  /// are the next ones due rather than whichever ones iOS happened to accept.
  /// Trimming here — in the whole-set sync that runs at every launch — is what
  /// makes the surviving set deterministic.
  @visibleForTesting
  static List<RoutineReminderSlot> plannedSlots(
    List<domain.Routine> routines, {
    required bool isIOS,
  }) {
    final List<RoutineReminderSlot> slots = <RoutineReminderSlot>[];

    for (final domain.Routine routine in routines) {
      if (!routine.isEnabled) {
        continue;
      }
      for (final int weekday in routine.repeatDays) {
        slots.add(
          RoutineReminderSlot(
            routine: routine,
            weekday: weekday,
            firesAt: _nextWeeklyDate(
              weekday: weekday,
              reminderTime: routine.reminderTime,
            ),
          ),
        );
      }
    }

    if (!isIOS) {
      return slots;
    }

    slots.sort(
      (RoutineReminderSlot a, RoutineReminderSlot b) =>
          a.firesAt.compareTo(b.firesAt),
    );
    final int budget = iosPendingLimit - _iosSnoozeReserve;
    return slots.length <= budget ? slots : slots.sublist(0, budget);
  }

  static domain.Routine _routineFromBundle(RoutineBundleRow bundle) {
    return domain.Routine(
      id: bundle.routine.id,
      title: bundle.routine.title,
      category: domain.RoutineCategory.values.byName(bundle.routine.category),
      reminderTime: bundle.schedule.reminderTime,
      repeatDays: _decodeRepeatDays(bundle.schedule.repeatDays),
      isEnabled: bundle.routine.isEnabled,
      snoozeMinutes: bundle.schedule.snoozeMinutes,
      createdAt: bundle.routine.createdAt,
      updatedAt: bundle.routine.updatedAt,
    );
  }

  Future<void> scheduleRoutine(domain.Routine routine) async {
    if (_disabled) {
      return;
    }

    await cancelRoutine(routine.id);
    if (!routine.isEnabled) {
      return;
    }

    final AppLocalizations strings = await _strings();

    for (final int weekday in routine.repeatDays) {
      await _scheduleSlot(
        routine: routine,
        weekday: weekday,
        strings: strings,
      );
    }
  }

  /// One weekly reminder for one routine on one weekday.
  Future<void> _scheduleSlot({
    required domain.Routine routine,
    required int weekday,
    required AppLocalizations strings,
  }) async {
    await _zonedScheduleWithFallback(
      id: routineNotificationId(routine.id, weekday),
      title: routine.title,
      body: strings.notificationReminderBody(routine.title),
      scheduledDate: _nextWeeklyDate(
        weekday: weekday,
        reminderTime: routine.reminderTime,
      ),
      notificationDetails: routineNotificationDetails(
        strings: strings,
        snoozeMinutes: routine.snoozeMinutes,
      ),
      payload: RoutineNotificationPayload(
        routineId: routine.id,
        snoozeMinutes: routine.snoozeMinutes,
        title: routine.title,
      ).encode(),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Schedules exactly when the OS allows it, and inexactly when it does not.
  ///
  /// From Android 12 the exact-alarm permission can be refused, and from
  /// Android 14 it is not granted by default. `zonedSchedule` then throws
  /// `exact_alarms_not_permitted`. A reminder that arrives in a loose window is
  /// far better than a create-routine flow that fails, so the call is retried
  /// inexactly instead of propagating.
  Future<void> _zonedScheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } on PlatformException catch (error) {
      if (error.code != 'exact_alarms_not_permitted') {
        rethrow;
      }

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
  }

  /// Re-arms a single one-off reminder after the user snoozes, either from the
  /// notification action or from the Today screen.
  Future<void> scheduleSnoozedRoutine({
    required String routineId,
    required String title,
    required DateTime scheduledFor,
    int snoozeMinutes = 10,
    String? payload,
  }) async {
    if (_disabled) {
      return;
    }

    final AppLocalizations strings = await _strings();

    await _zonedScheduleWithFallback(
      id: routineNotificationId(routineId, routineSnoozeSlot),
      title: title,
      body: strings.notificationReminderBody(title),
      scheduledDate: tz.TZDateTime.from(scheduledFor, tz.local),
      notificationDetails: routineNotificationDetails(
        strings: strings,
        snoozeMinutes: snoozeMinutes,
      ),
      payload:
          payload ??
          RoutineNotificationPayload(
            routineId: routineId,
            snoozeMinutes: snoozeMinutes,
            title: title,
          ).encode(),
    );
  }

  /// Dismisses a reminder that is currently on screen for [routineId].
  ///
  /// Answering a routine inside the app used to leave its notification sitting
  /// in the shade, still asking.
  Future<void> dismissShownRoutine(String routineId) async {
    if (_disabled) {
      return;
    }

    for (int weekday = 1; weekday <= 7; weekday += 1) {
      await _plugin.cancel(id: routineNotificationId(routineId, weekday));
    }
    await _plugin.cancel(id: routineNotificationId(routineId, routineSnoozeSlot));
  }

  Future<void> cancelRoutine(String routineId) async {
    if (_disabled) {
      return;
    }

    for (int weekday = 1; weekday <= 7; weekday += 1) {
      await _plugin.cancel(id: routineNotificationId(routineId, weekday));
    }
    await _plugin.cancel(id: routineNotificationId(routineId, routineSnoozeSlot));
  }

  /// Cancels every reminder this app has scheduled.
  ///
  /// Only for "Reset all data": the routines are gone, so their alarms have to
  /// go with them or the user keeps getting reminders for routines that no
  /// longer exist. The launch-time sync deliberately does NOT do this — see
  /// [syncRoutineSchedules].
  Future<void> cancelAllRoutines() async {
    if (_disabled) {
      return;
    }

    await _plugin.cancelAll();
  }

  Future<void> dispose() async {
    await _routineTapController.close();
    await _routineActionController.close();
  }

  @visibleForTesting
  static int notificationIdFor(String routineId, int weekday) {
    return routineNotificationId(routineId, weekday);
  }

  @visibleForTesting
  static tz.TZDateTime nextWeeklyDateFor({
    required DateTime now,
    required int weekday,
    required String reminderTime,
  }) {
    return _nextWeeklyDate(
      weekday: weekday,
      reminderTime: reminderTime,
      now: tz.TZDateTime.from(now, tz.local),
    );
  }

  Future<void> _setLocalTimeZone() async {
    try {
      final String? timezoneName = await _timezoneChannel.invokeMethod<String>(
        'getLocalTimezone',
      );
      if (timezoneName == null || timezoneName.isEmpty) {
        return;
      }
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } on PlatformException {
      // ponytail: fall back to timezone package default when platform lookup fails.
    } on MissingPluginException {
      // ponytail: tests and unsupported platforms can stay on default timezone.
    }
  }

  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    final RoutineNotificationPayload? payload =
        RoutineNotificationPayload.decode(response.payload);
    if (payload == null) {
      return;
    }

    final String? actionId = response.actionId;
    if (actionId != null) {
      // The app is alive, so the foreground handler fires instead of the
      // background isolate; it has to do the same work.
      final AppDatabase? database = _database;
      if (database != null) {
        final NotificationActionResult result =
            await applyRoutineNotificationAction(
              database: database,
              payload: payload,
              actionId: actionId,
            );
        final DateTime? snoozedUntil = result.snoozedUntil;
        if (snoozedUntil != null) {
          await scheduleSnoozedRoutine(
            routineId: payload.routineId,
            title: payload.title,
            scheduledFor: snoozedUntil,
            snoozeMinutes: payload.snoozeMinutes,
            payload: response.payload,
          );
        }
      }

      // An action is an answer, not a request to open the routine.
      _routineActionController.add(payload.routineId);
      return;
    }

    _routineTapController.add(payload.routineId);
  }

  static List<int> _decodeRepeatDays(String encodedRepeatDays) {
    try {
      return List<int>.from(jsonDecode(encodedRepeatDays) as List<dynamic>);
    } on FormatException {
      return const <int>[];
    }
  }






  static tz.TZDateTime _nextWeeklyDate({
    required int weekday,
    required String reminderTime,
    tz.TZDateTime? now,
  }) {
    final tz.TZDateTime current = now ?? tz.TZDateTime.now(tz.local);
    final List<String> timeParts = reminderTime.split(':');
    final int hour = int.tryParse(timeParts.first) ?? 8;
    final int minute = timeParts.length > 1
        ? int.tryParse(timeParts[1]) ?? 0
        : 0;

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      current.year,
      current.month,
      current.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || !scheduled.isAfter(current)) {
      scheduled = scheduled.add(const Duration(days: 1));
      scheduled = tz.TZDateTime(
        tz.local,
        scheduled.year,
        scheduled.month,
        scheduled.day,
        hour,
        minute,
      );
    }

    return scheduled;
  }
}

/// One routine's reminder on one weekday, with the moment it next fires.
@immutable
class RoutineReminderSlot {
  const RoutineReminderSlot({
    required this.routine,
    required this.weekday,
    required this.firesAt,
  });

  final domain.Routine routine;
  final int weekday;
  final tz.TZDateTime firesAt;
}
