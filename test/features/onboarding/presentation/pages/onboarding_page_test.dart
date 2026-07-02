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

    // Slide 1 should show checklist icon via Rive fallback.
    expect(find.byIcon(Icons.fact_check_outlined), findsOneWidget);
    expect(find.text('Build better days'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('can navigate through onboarding slides', (
    WidgetTester tester,
  ) async {
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

    // Navigate to slide 2.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Never miss what matters'), findsOneWidget);

    // Navigate to slide 3.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Private by default'), findsOneWidget);

    // Last slide shows "Get Started" instead of "Continue".
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('skip onboarding navigates to today', (
    WidgetTester tester,
  ) async {
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

    // Tap the header Skip (not the bottom "Skip" button).
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Should navigate to Today.
    expect(find.text('Daily Progress'), findsOneWidget);
  });

  testWidgets('complete onboarding navigates to today', (
    WidgetTester tester,
  ) async {
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

    // Go to last page.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Tap Get Started.
    await tester.tap(find.text('Get Started'));
    // Use pump() instead of pumpAndSettle() since Today page has
    // looping animations that never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Daily Progress'), findsOneWidget);
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
  Future<String> getThemeMode() async => "system";

  @override
  Future<void> setThemeMode(String mode) async {}

  @override
  Future<String> getLanguageCode() async => "en";

  @override
  Future<void> setLanguageCode(String code) async {}
}
