import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/profile/presentation/pages/profile_page.dart';

import '../../support/screen_harness.dart';

/// The avatar in the app bar used to do nothing. It now opens a profile that
/// is honest about there being no account, and shows what the device knows.
void main() {
  late ScreenHarness harness;

  setUp(() {
    harness = ScreenHarness();
  });

  tearDown(() async {
    await harness.dispose();
  });

  testWidgets('says there is no account rather than inventing one', (
    WidgetTester tester,
  ) async {
    useScreenWidth(tester, 390);

    await tester.pumpWidget(harness.wrap(const ProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('No account needed'), findsOneWidget);
  });

  testWidgets('shows the activity stats', (WidgetTester tester) async {
    useScreenWidth(tester, 390);
    await harness.seedRoutine(
      id: 'r1',
      title: 'Drink water',
      todayStatus: 'done',
    );

    await tester.pumpWidget(harness.wrap(const ProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text('Your activity'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
  });

  testWidgets('lays out without overflow on a narrow phone', (
    WidgetTester tester,
  ) async {
    useScreenWidth(tester, 320);

    await tester.pumpWidget(harness.wrap(const ProfilePage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in Indonesian', (WidgetTester tester) async {
    useScreenWidth(tester, 390);

    await tester.pumpWidget(
      harness.wrap(const ProfilePage(), locale: const Locale('id')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Tanpa akun'), findsOneWidget);
  });
}
