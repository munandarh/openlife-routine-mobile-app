import 'dart:convert';

import 'package:drift/drift.dart';
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

import '../../../../support/fake_settings_repository.dart';

void main() {
  late AppDatabase appDatabase;
  late RoutineRepository routineRepository;

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  AppDependencies buildDeps() {
    return AppDependencies(
      databaseConfig: const LocalDatabaseConfig.recommended(),
      notificationConfig: const NotificationStackConfig.recommended(),
      onboardingRepository: _FakeOnboardingRepository(),
      hasCompletedOnboarding: true,
      appDatabase: appDatabase,
      routineRepository: routineRepository,
      notificationService: AppNotificationService.noop(),
      initialNotificationRoutineId: null,
      settingsRepository: FakeSettingsRepository(),
    );
  }

  Future<void> seedRoutines(int count) async {
    final DateTime now = DateTime.now();
    for (int i = 1; i <= count; i++) {
      final String routineId = 'r$i';
      await appDatabase
          .into(appDatabase.routines)
          .insert(
            RoutinesCompanion(
              id: Value(routineId),
              title: Value('Routine $i'),
              category: const Value('meal'),
              isEnabled: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final String reminderTime = '${(i + 5).toString().padLeft(2, '0')}:00';
      await appDatabase
          .into(appDatabase.routineSchedules)
          .insert(
            RoutineSchedulesCompanion(
              id: Value('s$i'),
              routineId: Value(routineId),
              reminderTime: Value(reminderTime),
              repeatDays: Value(jsonEncode(<int>[now.weekday])),
              snoozeMinutes: const Value(10),
              updatedAt: Value(now),
            ),
          );
    }
  }

  testWidgets('shows all routines and no show all button when count <= 5', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await seedRoutines(4);

    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pumpAndSettle();

    for (int i = 1; i <= 4; i++) {
      expect(find.text('Routine $i'), findsOneWidget);
    }
    expect(find.text('Show all'), findsNothing);
    expect(find.text('Tampilkan semua'), findsNothing);
  });

  testWidgets(
    'shows max 5 routines initially when count > 5, then expands on tap',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await seedRoutines(7);

      await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
      await tester.pumpAndSettle();

      // First 5 routines should be visible.
      for (int i = 1; i <= 5; i++) {
        expect(find.text('Routine $i'), findsOneWidget);
      }
      // Routine 6 and 7 should be hidden.
      expect(find.text('Routine 6'), findsNothing);
      expect(find.text('Routine 7'), findsNothing);

      // "Show all" button should be visible.
      final Finder showAllButton = find.text('Show all');
      expect(showAllButton, findsOneWidget);

      // Tap "Show all" to expand.
      await tester.tap(showAllButton);
      await tester.pumpAndSettle();

      // Now all 7 routines should be visible.
      for (int i = 1; i <= 7; i++) {
        expect(find.text('Routine $i'), findsOneWidget);
      }

      // "Show less" button should be visible.
      final Finder showLessButton = find.text('Show less');
      expect(showLessButton, findsOneWidget);

      // Tap "Show less" to collapse.
      await tester.tap(showLessButton);
      await tester.pumpAndSettle();

      // Only first 5 should be visible again.
      for (int i = 1; i <= 5; i++) {
        expect(find.text('Routine $i'), findsOneWidget);
      }
      expect(find.text('Routine 6'), findsNothing);
      expect(find.text('Routine 7'), findsNothing);
      expect(find.text('Show all'), findsOneWidget);
    },
  );

  testWidgets('displays Tampilkan semua in Indonesian locale when count > 5', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await seedRoutines(6);

    final AppDependencies deps = AppDependencies(
      databaseConfig: const LocalDatabaseConfig.recommended(),
      notificationConfig: const NotificationStackConfig.recommended(),
      onboardingRepository: _FakeOnboardingRepository(),
      hasCompletedOnboarding: true,
      appDatabase: appDatabase,
      routineRepository: routineRepository,
      notificationService: AppNotificationService.noop(),
      initialNotificationRoutineId: null,
      settingsRepository: FakeSettingsRepository(languageCode: 'id'),
    );

    await tester.pumpWidget(OpenLifeApp(dependencies: deps));
    await tester.pumpAndSettle();

    expect(find.text('Tampilkan semua'), findsOneWidget);

    await tester.tap(find.text('Tampilkan semua'));
    await tester.pumpAndSettle();

    expect(find.text('Tampilkan lebih sedikit'), findsOneWidget);
    expect(find.text('Routine 6'), findsOneWidget);
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
