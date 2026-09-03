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
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';

import '../../support/fake_settings_repository.dart';

/// Today's empty state had its own "Create routine" button that navigated
/// without telling Today to reload. After saving, Today kept insisting nothing
/// was scheduled — while the routine existed and its reminder was already
/// queued with the OS. Found on an emulator, not by a test.
void main() {
  late AppDatabase appDatabase;

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await appDatabase.close();
  });

  testWidgets('Today hands the empty state a handler that can reload it', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
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
          hasCompletedOnboarding: true,
          appDatabase: appDatabase,
          routineRepository: DriftRoutineRepository(
            RoutineLocalDataSource(appDatabase),
          ),
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: FakeSettingsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TodayEmptyPage), findsOneWidget);

    // The regression was `const TodayEmptyPage()` — no handler, so the button
    // pushed the editor itself and nothing reloaded Today on the way back.
    final TodayEmptyPage empty = tester.widget<TodayEmptyPage>(
      find.byType(TodayEmptyPage),
    );
    expect(empty.onCreateRoutine, isNotNull);
  });

  testWidgets('the empty state still offers Profile and Notifications', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
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
          hasCompletedOnboarding: true,
          appDatabase: appDatabase,
          routineRepository: DriftRoutineRepository(
            RoutineLocalDataSource(appDatabase),
          ),
          notificationService: AppNotificationService.noop(),
          initialNotificationRoutineId: null,
          settingsRepository: FakeSettingsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The empty state used to replace the whole screen, app bar included, so
    // a new user could not reach either destination at all.
    expect(find.byType(OpenLifeAppBar), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<bool> hasCompletedOnboarding() async => true;

  @override
  Future<void> skipOnboarding() async {}
}
