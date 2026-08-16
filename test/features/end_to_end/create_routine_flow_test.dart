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

/// End-to-end cover for PRD §14.2's "create routine and schedule" path.
///
/// Drives the real widget tree — Today, the router, RoutineBloc, the Drift
/// database and TodayBloc — rather than any single layer, so a break in the
/// wiring between them fails here even when every unit test still passes.
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

  Widget buildApp() {
    return OpenLifeApp(
      dependencies: AppDependencies(
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
      ),
    );
  }

  testWidgets('a routine created from Today is persisted and listed', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    // A fresh install lands on Today with nothing scheduled.
    expect(find.text('Nothing scheduled today'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('New Routine'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Morning Yoga');
    await tester.pumpAndSettle();

    // The form defaults to Mon-Wed. Make sure today is included, so the
    // routine is due on the day the test runs.
    final int weekday = DateTime.now().weekday;
    if (weekday > 3) {
      final Finder repeatChips = find.byWidgetPredicate(
        (Widget widget) => widget.runtimeType.toString() == '_RepeatChip',
      );
      expect(repeatChips, findsNWidgets(7));
      await tester.tap(repeatChips.at(weekday - 1));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Save Routine'));
    await tester.pumpAndSettle();

    // The routine and its schedule reached the database.
    final List<RoutineBundleRow> bundles = await appDatabase
        .getRoutineBundles();
    expect(bundles, hasLength(1));
    expect(bundles.first.routine.title, 'Morning Yoga');
    expect(bundles.first.schedule.reminderTime, isNotEmpty);
    expect(bundles.first.schedule.repeatDays, contains('$weekday'));

    // And Today reloaded, so it is on screen rather than behind a restart.
    expect(find.text('Morning Yoga'), findsOneWidget);
    expect(find.text('Nothing scheduled today'), findsNothing);
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<String> getPreferredLanguageCode() async => 'en';

  @override
  Future<bool> hasCompletedOnboarding() async => true;

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
