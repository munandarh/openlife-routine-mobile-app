import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

import '../../../../support/screen_harness.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
  });

  tearDown(() async {
    await harness.dispose();
  });

  testWidgets('settings rows space title and trailing to opposite ends', (
    WidgetTester tester,
  ) async {
    useScreenWidth(tester, 400);

    await tester.pumpWidget(
      harness.wrap(
        const OpenLifeShell(
          currentRoute: OpenLifeRoute.settings,
          child: SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the Theme text and System text
    final themeFinder = find.text('Theme');
    final systemFinder = find.text('System');
    expect(themeFinder, findsOneWidget);
    expect(systemFinder, findsOneWidget);

    final themeTopLeft = tester.getTopLeft(themeFinder);
    final systemTopRight = tester.getTopRight(systemFinder);

    // There should be substantial horizontal space between "Theme" and "System"
    expect(systemTopRight.dx, greaterThan(themeTopLeft.dx + 150));

    // The chevron icon should be to the right of "System"
    final chevronFinder = find.byIcon(Icons.chevron_right_rounded);
    expect(chevronFinder, findsWidgets);

    final firstChevron = tester.getTopRight(chevronFinder.first);
    expect(firstChevron.dx, greaterThan(systemTopRight.dx));
  });
}
