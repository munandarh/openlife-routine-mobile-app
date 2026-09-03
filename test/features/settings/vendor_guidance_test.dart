import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/settings/presentation/pages/reminder_health_page.dart';

import '../../support/app_fonts.dart';
import '../../support/screen_harness.dart';

/// Reminders never arrived on a Xiaomi phone, and no code could fix it: MIUI
/// keeps an autostart permission that no API can read or request, and the only
/// button this screen offered opened the app's settings page — a screen that
/// does not contain that toggle at all.
void main() {
  late ScreenHarness harness;

  const MethodChannel power = MethodChannel('openlife_routine/power');
  final List<String> invoked = <String>[];

  setUpAll(loadAppFonts);

  void mockPower(String manufacturer) {
    invoked.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(power, (MethodCall call) async {
          invoked.add(call.method);
          return switch (call.method) {
            'isIgnoringBatteryOptimizations' => false,
            'manufacturer' => manufacturer,
            _ => true,
          };
        });
  }

  setUp(() {
    harness = ScreenHarness();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(power, null);
    await harness.dispose();
  });

  Future<void> openHealth(WidgetTester tester) async {
    useScreenWidth(tester, 411);
    await tester.pumpWidget(harness.wrap(const ReminderHealthPage()));
    await tester.pumpAndSettle();
  }

  testWidgets('a Xiaomi phone gets the steps that actually apply', (
    WidgetTester tester,
  ) async {
    mockPower('Xiaomi');
    await openHealth(tester);

    expect(find.textContaining('Xiaomi'), findsOneWidget);
    expect(find.textContaining('autostart'), findsWidgets);
    expect(find.text('Open autostart settings'), findsOneWidget);
    // The card grew three steps and a second button; on a narrow phone an
    // overflow here would clip the very instructions it exists to give.
    expect(tester.takeException(), isNull);
  });

  testWidgets('the vendor card fits the narrowest phone we support', (
    WidgetTester tester,
  ) async {
    mockPower('Xiaomi');
    useScreenWidth(tester, 320);
    await tester.pumpWidget(harness.wrap(const ReminderHealthPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Open autostart settings'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the autostart button opens the vendor screen, not app info', (
    WidgetTester tester,
  ) async {
    mockPower('Redmi');
    await openHealth(tester);

    await tester.tap(find.text('Open autostart settings'));
    await tester.pumpAndSettle();

    // openAppSettings lands on a page with no autostart toggle on it, which
    // is why that was never a fix.
    expect(invoked, contains('openAutostartSettings'));
    expect(invoked, isNot(contains('openAppSettings')));
  });

  testWidgets('a Pixel is not told to hunt for settings it does not have', (
    WidgetTester tester,
  ) async {
    mockPower('Google');
    await openHealth(tester);

    expect(find.text('Open autostart settings'), findsNothing);
  });

  testWidgets('the test reminder is offered whatever the phone', (
    WidgetTester tester,
  ) async {
    mockPower('Google');
    await openHealth(tester);

    // Every check above can pass while nothing arrives; this is the only
    // answer that does not depend on the OS describing itself accurately.
    expect(find.text('Send a test reminder'), findsOneWidget);
  });
}
