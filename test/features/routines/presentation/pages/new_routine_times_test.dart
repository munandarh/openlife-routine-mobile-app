import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';

import '../../../../support/app_fonts.dart';
import '../../../../support/screen_harness.dart';

/// The count of doses and the hours they land on are the two things a person
/// setting up a prescription has to get right, so both are checked against
/// what the screen actually renders.
void main() {
  late ScreenHarness harness;

  setUpAll(loadAppFonts);

  setUp(() {
    harness = ScreenHarness();
  });

  tearDown(() async {
    await harness.dispose();
  });

  Future<void> openForm(WidgetTester tester) async {
    useScreenWidth(tester, 411);
    await tester.pumpWidget(harness.wrap(const NewRoutinePage()));
    await tester.pumpAndSettle();
  }

  /// Taps the category tile, scrolling it into view first.
  Future<void> pickCategory(WidgetTester tester, String label) async {
    await tester.scrollUntilVisible(
      find.text(label),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> tapCount(WidgetTester tester, String count) async {
    await tester.scrollUntilVisible(
      find.text('Times a day'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(count));
    await tester.pumpAndSettle();
  }

  testWidgets('water keeps a single time and offers no count', (
    WidgetTester tester,
  ) async {
    await openForm(tester);

    // Water is not a category anyone doses; the form must not grow a control
    // it has no use for.
    expect(find.text('Times a day'), findsNothing);
    expect(find.text('Time'), findsOneWidget);
  });

  testWidgets('medicine offers a count and spreads the times evenly', (
    WidgetTester tester,
  ) async {
    await openForm(tester);
    await pickCategory(tester, 'Medicine');

    expect(find.text('Times a day'), findsOneWidget);
    // One time until asked otherwise.
    expect(find.text('Time 1'), findsOneWidget);
    expect(find.text('Time 2'), findsNothing);

    await tapCount(tester, '3');

    // Twelve hours from 08:00, split in two: the shape of a three-a-day dose.
    expect(find.text('Time 3'), findsOneWidget);
    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('2:00 PM'), findsOneWidget);
    expect(find.text('8:00 PM'), findsOneWidget);
  });

  testWidgets('lowering the count drops the later times', (
    WidgetTester tester,
  ) async {
    await openForm(tester);
    await pickCategory(tester, 'Vitamin');
    await tapCount(tester, '4');
    expect(find.text('Time 4'), findsOneWidget);

    await tapCount(tester, '2');

    expect(find.text('Time 3'), findsNothing);
    expect(find.text('Time 4'), findsNothing);
    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('8:00 PM'), findsOneWidget);
  });

  testWidgets('the times fit a narrow screen', (WidgetTester tester) async {
    useScreenWidth(tester, 320);
    await tester.pumpWidget(harness.wrap(const NewRoutinePage()));
    await tester.pumpAndSettle();
    await pickCategory(tester, 'Medicine');
    await tapCount(tester, '4');

    expect(tester.takeException(), isNull);
  });

  test('custom is a dosing category too', () {
    // The escape hatch for everything the fixed categories do not describe.
    expect(RoutineCategory.custom.supportsMultipleTimes, isTrue);
  });
}
