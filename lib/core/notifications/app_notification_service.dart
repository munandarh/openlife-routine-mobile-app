import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppNotificationService {
  AppNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    MethodChannel? timezoneChannel,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _timezoneChannel =
           timezoneChannel ?? const MethodChannel('openlife_routine/timezone');

  AppNotificationService.noop()
    : _plugin = FlutterLocalNotificationsPlugin(),
      _timezoneChannel = const MethodChannel('openlife_routine/timezone'),
      _disabled = true;

  final FlutterLocalNotificationsPlugin _plugin;
  final MethodChannel _timezoneChannel;
  final StreamController<String> _routineTapController =
      StreamController<String>.broadcast();
  bool _disabled = false;

  Stream<String> get routineTapStream => _routineTapController.stream;

  Future<String?> initialize() async {
    if (_disabled) {
      return null;
    }

    tz.initializeTimeZones();
    await _setLocalTimeZone();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    final NotificationAppLaunchDetails? launchDetails = await _plugin
        .getNotificationAppLaunchDetails();
    return _routineIdFromPayload(launchDetails?.notificationResponse?.payload);
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
  }

  Future<void> syncRoutineSchedules(AppDatabase appDatabase) async {
    if (_disabled) {
      return;
    }

    final List<RoutineBundleRow> bundles = await appDatabase
        .getRoutineBundles();

    // ponytail: app only owns local reminders right now, so reset all and rebuild.
    await _plugin.cancelAll();

    for (final RoutineBundleRow bundle in bundles) {
      final domain.Routine routine = domain.Routine(
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
      await scheduleRoutine(routine);
    }
  }

  Future<void> scheduleRoutine(domain.Routine routine) async {
    if (_disabled) {
      return;
    }

    await cancelRoutine(routine.id);
    if (!routine.isEnabled) {
      return;
    }

    for (final int weekday in routine.repeatDays) {
      await _plugin.zonedSchedule(
        id: _notificationId(routine.id, weekday),
        title: routine.title,
        body: 'Reminder for ${routine.title}',
        scheduledDate: _nextWeeklyDate(
          weekday: weekday,
          reminderTime: routine.reminderTime,
        ),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'snooze',
                'Snooze ${routine.snoozeMinutes} min',
                showsUserInterface: true,
              ),
            ],
          ),
        ),
        payload: _routinePayload(
          routineId: routine.id,
          snoozeMinutes: routine.snoozeMinutes,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelRoutine(String routineId) async {
    if (_disabled) {
      return;
    }

    for (int weekday = 1; weekday <= 7; weekday += 1) {
      await _plugin.cancel(id: _notificationId(routineId, weekday));
    }
    await _plugin.cancel(id: _notificationId(routineId, 99));
  }

  Future<void> dispose() async {
    await _routineTapController.close();
  }

  @visibleForTesting
  static int notificationIdFor(String routineId, int weekday) {
    return _notificationId(routineId, weekday);
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
    final String? routineId = _routineIdFromPayload(response.payload);
    if (routineId == null) {
      return;
    }

    if (response.actionId == 'snooze') {
      final int snoozeMinutes = _snoozeMinutesFromPayload(response.payload);
      await _plugin.zonedSchedule(
        id: _notificationId(routineId, 99),
        title: 'Snoozed reminder',
        body: 'Reminder for $routineId',
        scheduledDate: tz.TZDateTime.now(
          tz.local,
        ).add(Duration(minutes: snoozeMinutes)),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: response.payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    _routineTapController.add(routineId);
  }

  static List<int> _decodeRepeatDays(String encodedRepeatDays) {
    try {
      return List<int>.from(jsonDecode(encodedRepeatDays) as List<dynamic>);
    } on FormatException {
      return const <int>[];
    }
  }

  static String _routinePayload({
    required String routineId,
    required int snoozeMinutes,
  }) {
    return '$routineId|$snoozeMinutes';
  }

  static String? _routineIdFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    return payload.split('|').first;
  }

  static int _snoozeMinutesFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return 10;
    }
    final List<String> parts = payload.split('|');
    if (parts.length < 2) {
      return 10;
    }
    return int.tryParse(parts[1]) ?? 10;
  }

  static int _notificationId(String routineId, int weekday) {
    int hash = weekday;
    for (final int codeUnit in routineId.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
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

const String _channelId = 'routine_reminders';
const String _channelName = 'Routine reminders';
const String _channelDescription = 'Reminder notifications for daily routines';
