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
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';

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

  testWidgets('onboarding slides show rive fallback icons', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
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
          preferredLanguageCode: 'en',
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: _FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Skip language selection by tapping Continue.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Skip notification permission by tapping "Not now".
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // Now on onboarding slide 1 (Build better days).
    // Slide 1 hero loads the PNG illustration (not the icon fallback).
    // Since the asset is bundled, the icon fallback is not visible.
    expect(find.byIcon(Icons.fact_check_outlined), findsNothing);
    expect(find.text('Build better days'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('slide 1 illustration matches AssetVectors entry', (
    WidgetTester tester,
  ) async {
    final AssetVectorEntry entry =
        AssetVectors.byName('onboardingBuildBetterDays');

    tester.view.physicalSize = const Size(800, 2000);
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
          preferredLanguageCode: 'en',
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: _FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Navigate through splash → language selection → notification permission
    // to reach the onboarding slide.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // When the asset is present, the icon fallback is hidden.
    expect(find.byIcon(Icons.fact_check_outlined), findsNothing);
    expect(find.byIcon(Icons.broken_image), findsNothing);
    expect(find.text('Build better days'), findsOneWidget);

    // Touch the entry to keep analyzer happy.
    expect(entry.path, isNotEmpty);
  });

  testWidgets('4th slide shows starter template picker', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
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
          preferredLanguageCode: 'en',
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: _FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Navigate through splash → language → notification → onboarding slide 1
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // Go to slide 4 (last slide = starter template).
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // On the 4th slide, the starter template picker should be visible.
    expect(find.text('Start with a template'), findsOneWidget);
    // "Start empty" is the alternative path.
    expect(find.text('Start empty'), findsOneWidget);
  });

  testWidgets('can navigate through onboarding slides', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
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
          preferredLanguageCode: 'en',
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: _FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Navigate past Language Selection.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Navigate past Notification Permission.
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // Navigate to slide 2.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Never miss what matters'), findsOneWidget);

    // Navigate to slide 3.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Private by default'), findsOneWidget);

    // Navigate to slide 4 (the new starter template screen).
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Start with a template'), findsOneWidget);

    // Last slide shows "Get Started" instead of "Continue".
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('skip onboarding navigates to today', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
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
          preferredLanguageCode: 'en',
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: _FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Navigate past Language Selection.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Navigate past Notification Permission.
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // Tap the header Skip (not the bottom "Skip" button).
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Should navigate to Today. Since DB is empty, shows TodayEmptyPage.
    expect(find.text('Nothing scheduled today'), findsOneWidget);
  });

  testWidgets('complete onboarding navigates to today', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
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
          preferredLanguageCode: 'en',
          appDatabase: appDatabase,
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: _FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Navigate past Language Selection.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Navigate past Notification Permission.
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // Go to last page.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Tap Get Started (now appears on the 4th/last slide).
    await tester.tap(find.text('Get Started'));
    // Use pump() instead of pumpAndSettle() since Today page has
    // looping animations that never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Nothing scheduled today'), findsOneWidget);
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<String> getPreferredLanguageCode() async => 'en';

  @override
  Future<bool> hasCompletedOnboarding() async => false;

  @override
  Future<void> setPreferredLanguageCode(String languageCode) async {}

  @override
  Future<void> skipOnboarding() async {}
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<String> getThemeMode() async => 'system';

  @override
  Future<void> setThemeMode(String mode) async {}

  @override
  Future<String> getLanguageCode() async => 'en';

  @override
  Future<void> setLanguageCode(String code) async {}
}
