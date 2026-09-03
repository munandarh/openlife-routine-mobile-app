import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/app_database.dart'
    show AppDatabase;
import 'package:openlife_routine/core/storage/local_database_config.dart';
import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';

import '../../../../support/fake_settings_repository.dart';
import '../../../../support/localized_app.dart';

/// The repeat row read as broken on a device: seven fixed-width chips overflowed
/// a 360dp screen by 20px, which collapsed every gap and clipped Sunday, and the
/// only feedback on tap was a faint text-colour change.
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

  Widget buildPage() {
    return AppScope(
      dependencies: AppDependencies(
        databaseConfig: const LocalDatabaseConfig.recommended(),
        notificationConfig: const NotificationStackConfig.recommended(),
        onboardingRepository: _FakeOnboardingRepository(),
        hasCompletedOnboarding: true,
        appDatabase: appDatabase,
        routineRepository: routineRepository,
        notificationService: AppNotificationService.noop(),
        initialNotificationRoutineId: null,
        settingsRepository: FakeSettingsRepository(),
      ),
      child: const NewRoutinePage(),
    );
  }

  /// Narrowest phone width we support layout on.
  void useNarrowPhone(WidgetTester tester, {double logicalWidth = 360}) {
    tester.view.physicalSize = Size(logicalWidth * 3, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> scrollToRepeat(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.bySemanticsLabel('Fri'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }

  for (final double width in <double>[320, 360, 411]) {
    testWidgets('the repeat row fits a ${width.toInt()}dp screen', (
      WidgetTester tester,
    ) async {
      useNarrowPhone(tester, logicalWidth: width);

      await tester.pumpWidget(localizedApp(buildPage()));
      await tester.pumpAndSettle();
      await scrollToRepeat(tester);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('every weekday is reachable and tappable', (
    WidgetTester tester,
  ) async {
    useNarrowPhone(tester);
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(localizedApp(buildPage()));
    await tester.pumpAndSettle();
    await scrollToRepeat(tester);

    for (final String day in <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ]) {
      final Finder chip = find.bySemanticsLabel(day);
      expect(chip, findsOneWidget, reason: '$day is missing');
      // A clipped chip cannot be hit-tested; this is what actually broke.
      await tester.tap(chip);
      await tester.pump();
    }

    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('tapping a day flips its selected state', (
    WidgetTester tester,
  ) async {
    useNarrowPhone(tester);
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(localizedApp(buildPage()));
    await tester.pumpAndSettle();
    await scrollToRepeat(tester);

    // Assert on the fill the user actually sees rather than an internal flag.
    Color fillOf(String label) {
      return tester
          .widget<Material>(
            find
                .descendant(
                  of: find.bySemanticsLabel(label),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color!;
    }

    // Friday starts unselected (the form defaults to Mon/Tue/Wed).
    final Color unselected = fillOf('Fri');
    expect(unselected, fillOf('Thu'));

    await tester.tap(find.bySemanticsLabel('Fri'));
    await tester.pumpAndSettle();

    expect(fillOf('Fri'), isNot(unselected));
    expect(fillOf('Fri'), fillOf('Mon'));

    // And back off again.
    await tester.tap(find.bySemanticsLabel('Fri'));
    await tester.pumpAndSettle();
    expect(fillOf('Fri'), unselected);

    handle.dispose();
  });

  testWidgets('a selected day is filled, not just recoloured text', (
    WidgetTester tester,
  ) async {
    useNarrowPhone(tester);

    await tester.pumpWidget(localizedApp(buildPage()));
    await tester.pumpAndSettle();
    await scrollToRepeat(tester);

    Color fillOf(String label) {
      // The chip's Material sits inside its Semantics wrapper, not above it.
      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.bySemanticsLabel(label),
              matching: find.byType(Material),
            )
            .first,
      );
      return material.color!;
    }

    // Monday is on by default, Friday is not: they must not look the same.
    expect(fillOf('Mon'), isNot(fillOf('Fri')));
  });

  testWidgets('chips keep a 44px tap height', (WidgetTester tester) async {
    useNarrowPhone(tester);

    await tester.pumpWidget(localizedApp(buildPage()));
    await tester.pumpAndSettle();
    await scrollToRepeat(tester);

    final Size size = tester.getSize(find.bySemanticsLabel('Wed'));
    expect(size.height, greaterThanOrEqualTo(44));
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
