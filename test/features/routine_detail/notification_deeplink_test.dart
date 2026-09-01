import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
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

import '../../support/fake_settings_repository.dart';

/// A routine opened from a reminder is entered with `go`, so it has no route
/// behind it. Deleting from there used to call `pop` and throw
/// "GoError: There is nothing to pop", stranding the user on a detail screen
/// for a routine that no longer existed.
void main() {
  late AppDatabase appDatabase;
  late RoutineRepository routineRepository;

  final DateTime now = DateTime(2026, 9, 1, 21);

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );

    await appDatabase
        .into(appDatabase.routines)
        .insert(
          RoutinesCompanion(
            id: const Value('r1'),
            title: const Value('Evening stretch'),
            category: const Value('breakTime'),
            isEnabled: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await appDatabase
        .into(appDatabase.routineSchedules)
        .insert(
          RoutineSchedulesCompanion(
            id: const Value('s1'),
            routineId: const Value('r1'),
            reminderTime: const Value('21:50'),
            repeatDays: Value(jsonEncode(<int>[1, 2, 3, 4, 5, 6, 7])),
            snoozeMinutes: const Value(10),
            updatedAt: Value(now),
          ),
        );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Future<void> pumpFromNotification(WidgetTester tester) async {
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
          routineRepository: routineRepository,
          notificationService: AppNotificationService.noop(),
          // Simulates the app being launched by tapping a reminder.
          initialNotificationRoutineId: 'r1',
          settingsRepository: FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 950));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('a reminder opens the routine it belongs to', (
    WidgetTester tester,
  ) async {
    await pumpFromNotification(tester);

    expect(find.text('Routine Detail'), findsOneWidget);
    expect(find.text('Evening stretch'), findsOneWidget);
  });

  testWidgets('deleting from a reminder-opened detail lands on Today', (
    WidgetTester tester,
  ) async {
    await pumpFromNotification(tester);

    // The actions sit below the fold on a phone-sized viewport.
    await tester.scrollUntilVisible(
      find.text('Delete routine'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Delete routine'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Routine Detail'), findsNothing);
    // The only routine is gone, so Today shows its empty state.
    expect(find.text('Nothing scheduled today'), findsOneWidget);
  });

  testWidgets('back from a reminder-opened detail lands on Today', (
    WidgetTester tester,
  ) async {
    await pumpFromNotification(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Routine Detail'), findsNothing);
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
