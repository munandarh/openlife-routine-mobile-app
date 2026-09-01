import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_empty_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/notification_permission_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_empty_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';

import '../support/localized_app.dart';

/// PRD §14.4 requires the UI to survive OS-level text scaling. Flutter reports
/// a layout overflow as a framework exception, so pumping each screen at a
/// large scale and asserting no exception is a real regression guard.
void main() {
  /// A phone-sized surface: scaling text on a tall canvas would hide overflow
  /// that a real device would show.
  void useSmallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  final Map<String, Widget> screens = <String, Widget>{
    'today empty': const TodayEmptyPage(),
    'routines empty': const RoutinesEmptyPage(),
    'insights empty': const InsightsEmptyPage(),
    'language selection': const LanguageSelectionPage(),
    'notification permission': const NotificationPermissionPage(),
  };

  for (final double scale in <double>[1.3, 2.0]) {
    group('at ${scale}x text scale', () {
      screens.forEach((String name, Widget screen) {
        testWidgets('$name lays out without overflow', (
          WidgetTester tester,
        ) async {
          useSmallPhone(tester);

          await tester.pumpWidget(localizedApp(screen, textScale: scale));
          await tester.pump(const Duration(milliseconds: 500));

          expect(tester.takeException(), isNull);
        });
      });

      testWidgets('routine card lays out without overflow', (
        WidgetTester tester,
      ) async {
        useSmallPhone(tester);

        await tester.pumpWidget(
          localizedApp(
            Scaffold(
              // Cards always live inside a scroll view in the app, so the
              // harness mirrors that rather than pinning the card to the
              // viewport height.
              body: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  RoutineCard(
                    title: 'Afternoon hydration reminder',
                    timeLabel: '15:00',
                    statusLabel: 'Snoozed until 15:30',
                    icon: Icons.water_drop_outlined,
                    iconBackground: const Color(0xFFDDEBF5),
                    iconColor: const Color(0xFF5B8DB8),
                    actions: <RoutineCardAction>[
                      RoutineCardAction(label: 'Skip', onPressed: () {}),
                      RoutineCardAction(label: 'Snooze', onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
            textScale: scale,
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    });
  }

  group('tap targets', () {
    testWidgets('the completion circle is at least 44x44', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: RoutineCard(
              title: 'Breakfast',
              timeLabel: '07:00',
              icon: Icons.restaurant_outlined,
              iconBackground: const Color(0xFFFFF1C8),
              iconColor: const Color(0xFFC39B42),
              checkSemanticLabel: 'Done',
              onCheckTap: () {},
            ),
          ),
        ),
      );

      final Size size = tester.getSize(
        find.byIcon(Icons.circle_outlined).hitTestable(),
      );
      expect(size.width, greaterThanOrEqualTo(24));

      final Size target = tester.getSize(
        find
            .ancestor(
              of: find.byIcon(Icons.circle_outlined),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(target.width, greaterThanOrEqualTo(44));
      expect(target.height, greaterThanOrEqualTo(44));
    });

    testWidgets('action chips are at least 44 wide', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: RoutineCard(
              title: 'Breakfast',
              timeLabel: '07:00',
              icon: Icons.restaurant_outlined,
              iconBackground: const Color(0xFFFFF1C8),
              iconColor: const Color(0xFFC39B42),
              actions: <RoutineCardAction>[
                RoutineCardAction(label: 'Skip', onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      final Size size = tester.getSize(
        find
            .ancestor(of: find.text('Skip'), matching: find.byType(Container))
            .first,
      );
      expect(size.width, greaterThanOrEqualTo(44));
    });
  });
}
