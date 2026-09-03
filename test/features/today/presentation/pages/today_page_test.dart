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
import 'package:openlife_routine/shared/widgets/progress/progress_ring.dart';

import '../../../../support/fake_settings_repository.dart';

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
    await appDatabase
        .into(appDatabase.routines)
        .insert(
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
    await appDatabase
        .into(appDatabase.routineSchedules)
        .insert(
          RoutineSchedulesCompanion(
            id: Value('s1'),
            routineId: Value(routineId),
            reminderTime: const Value('07:00'),
            repeatDays: Value(jsonEncode(<int>[now.weekday])),
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
      appDatabase: appDatabase,
      routineRepository: routineRepository,
      notificationService: AppNotificationService.noop(),
      initialNotificationRoutineId: null,
      settingsRepository: FakeSettingsRepository(),
    );
  }

  testWidgets('today page shows daily progress with routines', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pumpAndSettle();

    // The gradient "Daily Progress" hero card is gone; the count now lives in
    // the dial beside the greeting, which is what buys the list its room.
    expect(find.byType(ProgressRing), findsOneWidget);
    expect(find.text('done'), findsOneWidget);
    expect(find.text('Daily routine'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('marking routine done updates progress', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pumpAndSettle();

    // Tap the check circle.
    // The open circle is drawn as a border, not an icon; its accessible
    // name is the stable handle.
    await tester.tap(find.bySemanticsLabel(RegExp('Mark .* as done')));
    await tester.pumpAndSettle();

    // Should now show done icon.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    handle.dispose();
  });

  testWidgets('daily complete celebration appears when all done', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pumpAndSettle();

    // Complete the only routine.
    // The open circle is drawn as a border, not an icon; its accessible
    // name is the stable handle.
    await tester.tap(find.bySemanticsLabel(RegExp('Mark .* as done')));
    await tester.pumpAndSettle();

    // Celebration overlay should be visible.
    expect(find.text('All Done!'), findsOneWidget);

    // The PNG illustration (from AssetVectors) should be rendered
    // instead of the icon fallback.
    expect(find.byIcon(Icons.celebration_outlined), findsNothing);
    handle.dispose();
  });

  testWidgets('celebration shows the PNG illustration', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pumpAndSettle();

    // Complete the only routine.
    // The open circle is drawn as a border, not an icon; its accessible
    // name is the stable handle.
    await tester.tap(find.bySemanticsLabel(RegExp('Mark .* as done')));
    await tester.pumpAndSettle();

    // The celebration overlay is visible.
    expect(find.text('All Done!'), findsOneWidget);
    // Image widget is rendered with the daily celebration asset.
    final Finder imageFinder = find.byType(Image);
    expect(imageFinder, findsWidgets);
    handle.dispose();
  });

  testWidgets('celebration can be dismissed', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(OpenLifeApp(dependencies: buildDeps()));
    await tester.pumpAndSettle();

    // Complete the only routine.
    // The open circle is drawn as a border, not an icon; its accessible
    // name is the stable handle.
    await tester.tap(find.bySemanticsLabel(RegExp('Mark .* as done')));
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
  Future<bool> hasCompletedOnboarding() async => false;

  @override
  Future<void> skipOnboarding() async {}
}
