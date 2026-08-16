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
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';

/// PRD §14.4 asks the UI to survive text scaling. A RenderFlex overflow
/// raises a Flutter error, which fails a widget test, so pumping the real
/// screens at a large scale is itself the assertion.
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

  Widget buildApp({required bool hasCompletedOnboarding}) {
    return OpenLifeApp(
      dependencies: AppDependencies(
        databaseConfig: const LocalDatabaseConfig.recommended(),
        notificationConfig: const NotificationStackConfig.recommended(),
        onboardingRepository: _FakeOnboardingRepository(),
        hasCompletedOnboarding: hasCompletedOnboarding,
        preferredLanguageCode: 'en',
        appDatabase: appDatabase,
        routineRepository: routineRepository,
        notificationService: AppNotificationService.noop(),
        initialNotificationRoutineId: null,
        settingsRepository: _FakeSettingsRepository(),
      ),
    );
  }

  Future<void> pumpAtScale(
    WidgetTester tester,
    Widget app, {
    required double scale,
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;

    // Set the scale on the dispatcher rather than wrapping the app in a
    // MediaQuery: MaterialApp builds its own MediaQuery.fromView at the root,
    // which shadows any ancestor one.
    tester.platformDispatcher.textScaleFactorTestValue = scale;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
  }

  testWidgets('Today survives 1.5x text scale', (WidgetTester tester) async {
    await pumpAtScale(
      tester,
      buildApp(hasCompletedOnboarding: true),
      scale: 1.5,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Nothing scheduled today'), findsOneWidget);
  });

  testWidgets('the first-run flow survives 1.5x text scale', (
    WidgetTester tester,
  ) async {
    await pumpAtScale(
      tester,
      buildApp(hasCompletedOnboarding: false),
      scale: 1.5,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Choose your language'), findsOneWidget);
  });

  testWidgets('an unlabelled IconCircleButton is hidden from screen readers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IconCircleButton(icon: Icons.notifications_none_rounded),
        ),
      ),
    );

    // Decorative chrome must not be announced as a control the user can use.
    expect(find.byType(ExcludeSemantics), findsOneWidget);
  });

  testWidgets('a labelled IconCircleButton exposes its label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconCircleButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: 'Back',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Back'), findsAtLeastNWidgets(1));
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
