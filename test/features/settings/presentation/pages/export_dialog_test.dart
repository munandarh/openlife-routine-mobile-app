import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

import '../../../../support/screen_harness.dart';

/// Export used to render the backup as read-only text with no way to get it off
/// the screen, which does not meet "user can save/share backup file"
/// (PRD §12.7). Copying to the clipboard hands it to the system share sheet.
void main() {
  late ScreenHarness harness;
  final List<MethodCall> platformCalls = <MethodCall>[];

  setUp(() async {
    harness = ScreenHarness();
    await harness.seedRoutine(
      id: 'r1',
      title: 'Morning hydration',
      notes: 'Two glasses',
      iconKey: 'water_drop',
    );

    platformCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          platformCalls.add(call);
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await harness.dispose();
  });

  Future<void> openExport(WidgetTester tester) async {
    useScreenWidth(tester, 360);
    await tester.pumpWidget(
      harness.wrap(
        const OpenLifeShell(
          currentRoute: OpenLifeRoute.settings,
          child: SettingsPage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.text('Export routines'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Export routines'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('the export dialog offers a copy action', (
    WidgetTester tester,
  ) async {
    await openExport(tester);

    expect(find.text('Export Data'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('copying puts the backup on the clipboard and confirms', (
    WidgetTester tester,
  ) async {
    await openExport(tester);

    await tester.tap(find.text('Copy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final MethodCall copy = platformCalls.firstWhere(
      (MethodCall call) => call.method == 'Clipboard.setData',
    );
    final String text =
        (copy.arguments as Map<Object?, Object?>)['text']! as String;

    // The backup is the real export, including the fields that used to be
    // dropped.
    expect(text, contains('"routines"'));
    expect(text, contains('Morning hydration'));
    expect(text, contains('"notes": "Two glasses"'));
    expect(text, contains('"iconKey": "water_drop"'));

    expect(find.text('Backup copied to the clipboard.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('dialog actions sit on one row rather than stacking', (
    WidgetTester tester,
  ) async {
    await openExport(tester);

    // The app's filledButtonTheme stretches buttons to full width; a dialog
    // button that inherited it wrapped the action row.
    final Size copy = tester.getSize(find.widgetWithText(FilledButton, 'Copy'));
    expect(copy.width, lessThan(200));

    final Offset copyPos = tester.getTopLeft(
      find.widgetWithText(FilledButton, 'Copy'),
    );
    final Offset closePos = tester.getTopLeft(
      find.widgetWithText(TextButton, 'Close'),
    );
    expect(copyPos.dy, closePos.dy);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
