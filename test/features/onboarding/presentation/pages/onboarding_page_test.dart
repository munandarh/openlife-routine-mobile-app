import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/app.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/core/storage/local_database_config.dart';
import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';

import '../../../../support/fake_settings_repository.dart';

void main() {
  late AppDatabase appDatabase;
  late RoutineRepository routineRepository;

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  /// Boots the real app on a tall surface, stopping on the language screen.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      OpenLifeApp(
        dependencies: AppDependencies(
          databaseConfig: const LocalDatabaseConfig.recommended(),
          notificationConfig: const NotificationStackConfig.recommended(),
          onboardingRepository: _FakeOnboardingRepository(),
          hasCompletedOnboarding: false,
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: FakeSettingsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Boots the real app on a tall surface and walks the two pre-slide screens
  /// (language, notification permission) so each test starts on slide 1.
  Future<void> pumpOnboarding(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      OpenLifeApp(
        dependencies: AppDependencies(
          databaseConfig: const LocalDatabaseConfig.recommended(),
          notificationConfig: const NotificationStackConfig.recommended(),
          onboardingRepository: _FakeOnboardingRepository(),
          hasCompletedOnboarding: false,
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: FakeSettingsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
  }

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.byKey(onboardingPrimaryActionKey));
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding slides show their illustration asset', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                AssetVectors.onboardingBuildBetterDays.path &&
            widget.fit == BoxFit.cover,
      ),
      findsOneWidget,
    );
    expect(find.text('Build better days'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('can navigate through all four onboarding slides', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.text('1 / 4'), findsOneWidget);

    await tapNext(tester);
    expect(find.text('Never miss what matters'), findsOneWidget);

    await tapNext(tester);
    expect(find.text('Private by default'), findsOneWidget);

    await tapNext(tester);
    expect(find.text('Start with a template'), findsOneWidget);
    expect(find.text('4 / 4'), findsOneWidget);

    // Last slide swaps the arrow for a check and offers "Back" instead of
    // "Skip".
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Back'), findsOneWidget);
  });

  testWidgets(
    'starter step lists the seed templates and a start-empty option',
    (WidgetTester tester) async {
      await pumpOnboarding(tester);
      await tapNext(tester);
      await tapNext(tester);
      await tapNext(tester);

      expect(find.text('Morning Routine'), findsOneWidget);
      expect(find.text('Hydration Tracker'), findsOneWidget);
      expect(find.byKey(onboardingStartEmptyKey), findsOneWidget);
    },
  );

  testWidgets('skip onboarding navigates to today', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Nothing scheduled today'), findsOneWidget);
  });

  testWidgets('completing with start-empty creates no routines', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);
    await tapNext(tester);
    await tapNext(tester);
    await tapNext(tester);

    await tester.tap(find.byKey(onboardingPrimaryActionKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // No template picked means Today lands on the empty state.
    expect(find.text('Nothing scheduled today'), findsOneWidget);
  });

  testWidgets('picking a starter template creates its routines', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);
    await tapNext(tester);
    await tapNext(tester);
    await tapNext(tester);

    await tester.tap(find.text('Vitamin Routine'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(onboardingPrimaryActionKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The template's routines are created before Today is shown, so they are
    // already on the checklist.
    expect(find.text('Vitamin D3'), findsOneWidget);
    expect(find.text('B Complex'), findsOneWidget);
  });

  group('language selection', () {
    testWidgets('picking Indonesian translates the rest of onboarding', (
      WidgetTester tester,
    ) async {
      // Regression: the pick used to be written to the onboarding repository
      // while MaterialApp.locale read the settings repository, so choosing
      // Indonesian changed nothing.
      await pumpApp(tester);

      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Dapatkan pengingat yang lembut'), findsOneWidget);
      expect(find.text('Izinkan notifikasi'), findsOneWidget);
    });

    testWidgets('keeping English leaves the flow in English', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Get gentle reminders'), findsOneWidget);
    });

    testWidgets('the slide-1 chips retranslate the slide immediately', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      expect(find.text('Build better days'), findsOneWidget);

      await tester.tap(find.text('Bahasa'));
      await tester.pumpAndSettle();

      expect(find.text('Bangun hari yang lebih baik'), findsOneWidget);
    });
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<bool> hasCompletedOnboarding() async => false;

  @override
  Future<void> skipOnboarding() async {}
}
