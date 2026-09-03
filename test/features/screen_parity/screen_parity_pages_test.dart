import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_empty_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/notification_permission_page.dart';
import 'package:openlife_routine/features/splash/presentation/pages/splash_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';

import '../../support/localized_app.dart';

void main() {
  /// The default 800x600 test window is not a phone: content that fits a real
  /// screen scrolls off the bottom of it, and taps then miss.
  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('SplashPage', () {
    testWidgets('renders splash content and advances', (
      WidgetTester tester,
    ) async {
      var advanced = false;

      await tester.pumpWidget(
        localizedApp(
          SplashPage(
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
      usePhone(tester);
      var allowed = false;

      await tester.pumpWidget(
        localizedApp(
          NotificationPermissionPage(
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
        localizedApp(
          LanguageSelectionPage(
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
        localizedApp(TodayEmptyPage(onCreateRoutine: () => tapped = true)),
      );

      await tester.tap(find.text('Create routine'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('insights empty state renders', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(const InsightsEmptyPage()));

      expect(find.text('Insights will appear here'), findsOneWidget);
    });
  });

  group('Localization parity', () {
    testWidgets('language selection renders Indonesian copy', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await tester.pumpWidget(
        localizedApp(const LanguageSelectionPage(), locale: const Locale('id')),
      );

      expect(find.text('Pilih bahasamu'), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);
    });

    testWidgets('today empty state renders Indonesian copy', (
      WidgetTester tester,
    ) async {
      usePhone(tester);
      await tester.pumpWidget(
        localizedApp(const TodayEmptyPage(), locale: const Locale('id')),
      );

      expect(find.text('Belum ada jadwal hari ini'), findsOneWidget);
      expect(find.text('Buat rutinitas'), findsOneWidget);
    });
  });
}
