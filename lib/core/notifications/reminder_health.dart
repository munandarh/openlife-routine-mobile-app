import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';

/// One condition that has to hold for a reminder to actually arrive.
enum ReminderCheck {
  /// The OS will show our notifications at all.
  notifications,

  /// Alarms may fire at the exact minute. Without it Android batches them into
  /// a window, so a 07:00 reminder can land at 07:40.
  exactAlarms,

  /// The app is exempt from battery optimisation. Without it, aggressive
  /// vendors suspend the process and the alarm never runs.
  batteryOptimisation,
}

@immutable
class ReminderHealthReport {
  const ReminderHealthReport({required this.results, required this.manufacturer});

  /// A check is absent from the map when the platform cannot answer it. That
  /// is deliberately different from `false`: "we don't know" must never be
  /// shown as "you're fine".
  final Map<ReminderCheck, bool> results;

  /// Lower-case device manufacturer, used only to decide whether to warn about
  /// vendor-specific background limits.
  final String manufacturer;

  bool? operator [](ReminderCheck check) => results[check];

  /// Checks that are known to be failing.
  List<ReminderCheck> get failing => results.entries
      .where((MapEntry<ReminderCheck, bool> e) => !e.value)
      .map((MapEntry<ReminderCheck, bool> e) => e.key)
      .toList();

  bool get isHealthy => failing.isEmpty;

  /// Whether this device's vendor is known to suspend background apps beyond
  /// what the battery-optimisation flag reports.
  ///
  /// These four cover the overwhelming majority of Android phones in the
  /// markets this app targets, and all of them keep a separate "autostart" or
  /// "background run" permission that no API can read.
  bool get needsVendorGuidance => const <String>{
    'xiaomi',
    'redmi',
    'poco',
    'oppo',
    'realme',
    'vivo',
    'iqoo',
    'huawei',
    'honor',
  }.contains(manufacturer);
}

/// Answers "will my reminders actually arrive?" — the one question this app
/// exists to get right.
///
/// Every failure it reports is silent on the device: a suspended app shows no
/// error, a batched alarm looks like the app forgot, and a revoked permission
/// looks like nothing at all. Surfacing them is the difference between a user
/// fixing a setting and a user concluding the app is broken.
class ReminderHealth {
  ReminderHealth({
    required AppNotificationService notificationService,
    MethodChannel? powerChannel,
  }) : _notificationService = notificationService,
       _power =
           powerChannel ?? const MethodChannel('openlife_routine/power');

  final AppNotificationService _notificationService;
  final MethodChannel _power;

  Future<ReminderHealthReport> check() async {
    final Map<ReminderCheck, bool> results = <ReminderCheck, bool>{};

    final bool? notifications = await _notificationService
        .areNotificationsEnabled();
    if (notifications != null) {
      results[ReminderCheck.notifications] = notifications;
    }

    final bool? exact = await _notificationService.canScheduleExactAlarms();
    if (exact != null) {
      results[ReminderCheck.exactAlarms] = exact;
    }

    final bool? battery = await _invoke<bool>('isIgnoringBatteryOptimizations');
    if (battery != null) {
      results[ReminderCheck.batteryOptimisation] = battery;
    }

    final String manufacturer =
        (await _invoke<String>('manufacturer'))?.toLowerCase() ?? '';

    return ReminderHealthReport(results: results, manufacturer: manufacturer);
  }

  Future<void> openBatterySettings() => _invoke<bool>('openBatterySettings');

  Future<void> openAppSettings() => _invoke<bool>('openAppSettings');

  Future<void> requestPermissions() =>
      _notificationService.requestPermissions();

  Future<T?> _invoke<T>(String method) async {
    try {
      return await _power.invokeMethod<T>(method);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      // iOS, or a test: the channel is Android-only by design.
      return null;
    }
  }
}
