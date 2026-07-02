import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_empty_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/notification_permission_page.dart';
import 'package:openlife_routine/features/splash/presentation/pages/splash_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';

void main() {
  group('SplashPage', () {
    testWidgets('renders splash content and advances', (
      WidgetTester tester,
    ) async {
      var advanced = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(
            hasCompletedOnboarding: false,
            initialNotificationRoutineId: null,
            onReady: (_) async {
              advanced = true;
            },
          ),
        ),
      );

      expect(find.text('OpenLife Routine'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 950));
      expect(advanced, isTrue);
    });
  });

  group('NotificationPermissionPage', () {
    testWidgets('invokes allow callback', (WidgetTester tester) async {
      var allowed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationPermissionPage(
            onAllowNotifications: (_) async {
              allowed = true;
            },
          ),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Allow notifications'),
        100,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Allow notifications'));
      await tester.pump();

      expect(allowed, isTrue);
    });
  });

  group('LanguageSelectionPage', () {
    testWidgets('captures selection and continue action', (
      WidgetTester tester,
    ) async {
      String? languageCode;

      await tester.pumpWidget(
        MaterialApp(
          home: LanguageSelectionPage(
            onLanguageSelected: (_, code) async {
              languageCode = code;
            },
          ),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Bahasa Indonesia'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(languageCode, 'id');
    });
  });

  group('Empty screens', () {
    testWidgets('today empty state action is wired', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(home: TodayEmptyPage(onCreateRoutine: () => tapped = true)),
      );

      await tester.tap(find.text('Create routine'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('insights empty state renders', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: InsightsEmptyPage()));

      expect(find.text('Insights will appear here'), findsOneWidget);
    });
  });
}
