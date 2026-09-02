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

/// Routine Detail loads its routine once, when its bloc is created. Editing
/// pushes a route on top, so the detail page is never rebuilt from the
/// database when the editor pops — it kept showing the pre-edit time, which
/// reads as "the save did not work" even though the alarms had already been
/// rescheduled to the new time.
void main() {
  late AppDatabase appDatabase;
  late RoutineRepository routineRepository;

  final DateTime now = DateTime(2026, 9, 2, 9);

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
            title: const Value('Drink water'),
            category: const Value('water'),
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
            reminderTime: const Value('09:40'),
            repeatDays: Value(jsonEncode(<int>[1, 2, 3])),
            snoozeMinutes: const Value(10),
            updatedAt: Value(now),
          ),
        );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Future<void> pumpDetail(WidgetTester tester) async {
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
          initialNotificationRoutineId: 'r1',
          settingsRepository: FakeSettingsRepository(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 950));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('detail shows the new time after the editor pops', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester);
    expect(find.text('9:40 AM'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Edit routine'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Edit routine'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Stands in for the editor's save: the row is already updated by the time
    // the editor pops.
    await (appDatabase.update(appDatabase.routineSchedules)
          ..where((RoutineSchedules t) => t.routineId.equals('r1')))
        .write(const RoutineSchedulesCompanion(reminderTime: Value('10:05')));

    await tester.tap(find.byIcon(Icons.close_rounded));
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
    // The editor is gone and we are back on the detail page, which is still
    // scrolled to where it was left, so assert on its body rather than the
    // off-screen title.
    expect(find.text('Edit routine'), findsOneWidget);
    expect(find.text('10:05 AM'), findsOneWidget);
    expect(find.text('9:40 AM'), findsNothing);
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
