import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/notifications/presentation/pages/notifications_page.dart';

import '../../support/screen_harness.dart';

/// The bell in the app bar used to do nothing. It now opens the reminders
/// that are actually queued, built from the same arithmetic as the scheduler.
void main() {
  late ScreenHarness harness;

  setUp(() {
    harness = ScreenHarness();
  });

  tearDown(() async {
    await harness.dispose();
  });

  testWidgets('lists the routines that will remind you', (
    WidgetTester tester,
  ) async {
    useScreenWidth(tester, 390);
    await harness.seedRoutine(
      id: 'r1',
      title: 'Drink water',
      reminderTimes: <String>['08:00'],
    );
    await harness.seedRoutine(
      id: 'r2',
      title: 'Evening stretch',
      reminderTimes: <String>['21:00'],
    );

    await tester.pumpWidget(harness.wrap(const NotificationsPage()));
    await tester.pumpAndSettle();

    // The heading is the screen title now; the old 'Upcoming reminders'
    // subheading was redundant above a list of exactly that.
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Drink water'), findsWidgets);
    expect(find.text('Evening stretch'), findsWidgets);
  });

  testWidgets('says so plainly when nothing is scheduled', (
    WidgetTester tester,
  ) async {
    useScreenWidth(tester, 390);

    await tester.pumpWidget(harness.wrap(const NotificationsPage()));
    await tester.pumpAndSettle();

    expect(find.text('No reminders scheduled'), findsOneWidget);
  });

  testWidgets('a disabled routine is not promised a reminder', (
    WidgetTester tester,
  ) async {
    useScreenWidth(tester, 390);
    await harness.seedRoutine(id: 'r1', title: 'Drink water');
    await (harness.appDatabase.update(harness.appDatabase.routines)
          ..where((Routines t) => t.id.equals('r1')))
        .write(const RoutinesCompanion(isEnabled: drift.Value(false)));

    await tester.pumpWidget(harness.wrap(const NotificationsPage()));
    await tester.pumpAndSettle();

    expect(find.text('No reminders scheduled'), findsOneWidget);
    expect(find.text('Drink water'), findsNothing);
  });

  testWidgets('lays out without overflow on a narrow phone', (
    WidgetTester tester,
  ) async {
    useScreenWidth(tester, 320);
    await harness.seedRoutine(
      id: 'r1',
      title: 'A routine with a fairly long name to wrap',
    );

    await tester.pumpWidget(harness.wrap(const NotificationsPage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in Indonesian', (WidgetTester tester) async {
    useScreenWidth(tester, 390);

    await tester.pumpWidget(
      harness.wrap(const NotificationsPage(), locale: const Locale('id')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
  });
}
