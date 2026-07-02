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
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';

void main() {
  late AppDatabase appDatabase;
  late RoutineRepository routineRepository;

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );

    // Seed a routine that is enabled and repeats today.
    final String routineId = 'r1';
    await appDatabase.into(appDatabase.routines).insert(
      RoutinesCompanion(
        id: Value(routineId),
        title: const Value('Breakfast'),
        category: const Value('meal'),
        isEnabled: const Value(true),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final DateTime now = DateTime.now();
    await appDatabase.into(appDatabase.routineSchedules).insert(
      RoutineSchedulesCompanion(
        id: Value('s1'),
        routineId: Value(routineId),
        reminderTime: const Value('07:00'),
        repeatDays: Value(jsonEncode(<int>[
          now.weekday,
        ])),
        snoozeMinutes: const Value(10),
        updatedAt: Value(now),
      ),
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
      preferredLanguageCode: 'en',
      appDatabase: appDatabase,
      routineRepository: routineRepository,
      notificationService: AppNotificationService.noop(),
      initialNotificationRoutineId: null,
          settingsRepository: _FakeSettingsRepository(),
    );
  }

  testWidgets('today page shows daily progress with routines', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Daily Progress'), findsOneWidget);
    expect(find.text('Daily routine'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
  });

  testWidgets('marking routine done updates progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Tap the check circle.
    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();

    // Should now show done icon.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('daily complete celebration appears when all done', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Complete the only routine.
    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();

    // Celebration overlay should be visible.
    expect(find.text('All Done!'), findsOneWidget);
  });

  testWidgets('celebration can be dismissed', (WidgetTester tester) async {
    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Complete the only routine.
    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();

    // Dismiss celebration.
    expect(find.text('All Done!'), findsOneWidget);
    await tester.tap(find.text('All Done!'));
    await tester.pumpAndSettle();

    // Overlay should be gone.
    expect(find.text('All Done!'), findsNothing);
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
