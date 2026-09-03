import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/reminder_health.dart';

/// The rule this screen is built on: an unknown answer is never shown as a
/// passing one. Telling somebody their reminders are fine when the platform
/// would not say so is the single worst thing this feature could do.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel power = MethodChannel('openlife_routine/power');

  void mockPower({bool? ignoringBattery, String manufacturer = 'google'}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(power, (MethodCall call) async {
          return switch (call.method) {
            'isIgnoringBatteryOptimizations' => ignoringBattery,
            'manufacturer' => manufacturer,
            _ => null,
          };
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(power, null);
  });

  ReminderHealth healthFor() => ReminderHealth(
    // The noop service answers null for every platform question, which is
    // exactly the "cannot know" case.
    notificationService: AppNotificationService.noop(),
    powerChannel: power,
  );

  test('a check the platform cannot answer is omitted, not failed', () async {
    mockPower(ignoringBattery: null);

    final ReminderHealthReport report = await healthFor().check();

    expect(report[ReminderCheck.notifications], isNull);
    expect(report[ReminderCheck.exactAlarms], isNull);
    expect(report[ReminderCheck.batteryOptimisation], isNull);
    // Nothing is known to be wrong, so nothing is reported as wrong.
    expect(report.failing, isEmpty);
  });

  test('a battery exemption that is refused is reported as failing', () async {
    mockPower(ignoringBattery: false);

    final ReminderHealthReport report = await healthFor().check();

    expect(report[ReminderCheck.batteryOptimisation], isFalse);
    expect(report.failing, contains(ReminderCheck.batteryOptimisation));
    expect(report.isHealthy, isFalse);
  });

  test('a granted exemption passes', () async {
    mockPower(ignoringBattery: true);

    final ReminderHealthReport report = await healthFor().check();

    expect(report[ReminderCheck.batteryOptimisation], isTrue);
    expect(report.isHealthy, isTrue);
  });

  group('vendor guidance', () {
    test(
      'is shown for the makers that keep a hidden autostart switch',
      () async {
        for (final String brand in <String>[
          'xiaomi',
          'oppo',
          'vivo',
          'realme',
        ]) {
          mockPower(ignoringBattery: true, manufacturer: brand);
          final ReminderHealthReport report = await healthFor().check();
          expect(
            report.needsVendorGuidance,
            isTrue,
            reason: '$brand suspends background apps beyond the battery flag',
          );
        }
      },
    );

    test('is not shown where the battery flag tells the whole story', () async {
      for (final String brand in <String>['google', 'samsung', 'nothing']) {
        mockPower(ignoringBattery: true, manufacturer: brand);
        final ReminderHealthReport report = await healthFor().check();
        expect(report.needsVendorGuidance, isFalse, reason: brand);
      }
    });

    test('matches regardless of how the vendor cases its name', () async {
      mockPower(ignoringBattery: true, manufacturer: 'Xiaomi');

      final ReminderHealthReport report = await healthFor().check();

      expect(report.needsVendorGuidance, isTrue);
    });
  });
}
