import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/core/storage/local_database_config.dart';
import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';

import 'fake_settings_repository.dart';
import 'localized_app.dart';

/// Everything a feature screen needs to be pumped on its own: an in-memory
/// database, the DI scope, and the app-level SettingsBloc.
class ScreenHarness {
  ScreenHarness({
    SettingsRepository? settingsRepository,
    this.routineRepositoryOverride,
  }) : appDatabase = AppDatabase.forTesting(NativeDatabase.memory()),
       settingsRepository = settingsRepository ?? FakeSettingsRepository();

  final AppDatabase appDatabase;
  final SettingsRepository settingsRepository;

  /// Replaces the Drift-backed repository.
  ///
  /// Needed for any screen that watches routines: a Drift stream never
  /// delivers under `testWidgets`, whose fake-async zone does not drive
  /// Drift's scheduler, so the widget hangs waiting for its first event.
  final RoutineRepository? routineRepositoryOverride;

  late final AppDependencies dependencies = AppDependencies(
    databaseConfig: const LocalDatabaseConfig.recommended(),
    notificationConfig: const NotificationStackConfig.recommended(),
    onboardingRepository: _FakeOnboardingRepository(),
    hasCompletedOnboarding: true,
    appDatabase: appDatabase,
    routineRepository:
        routineRepositoryOverride ??
        DriftRoutineRepository(RoutineLocalDataSource(appDatabase)),
    notificationService: AppNotificationService.noop(),
    initialNotificationRoutineId: null,
    settingsRepository: settingsRepository,
  );

  Future<void> dispose() => appDatabase.close();

  /// Seeds a routine plus its schedule and, optionally, a log for today.
  Future<void> seedRoutine({
    required String id,
    required String title,
    String category = 'water',
    List<String> reminderTimes = const <String>['08:00'],
    List<int> repeatDays = const <int>[1, 2, 3, 4, 5, 6, 7],
    String? notes,
    String? iconKey,
    String? todayStatus,
    DateTime? createdAt,
  }) async {
    final DateTime created = createdAt ?? DateTime(2026, 1, 1);

    await appDatabase
        .into(appDatabase.routines)
        .insert(
          RoutinesCompanion(
            id: drift.Value(id),
            title: drift.Value(title),
            category: drift.Value(category),
            iconKey: drift.Value(iconKey),
            notes: drift.Value(notes),
            isEnabled: const drift.Value(true),
            createdAt: drift.Value(created),
            updatedAt: drift.Value(created),
          ),
        );
    await appDatabase
        .into(appDatabase.routineSchedules)
        .insert(
          RoutineSchedulesCompanion(
            id: drift.Value('${id}_schedule'),
            routineId: drift.Value(id),
            reminderTime: drift.Value(reminderTimes.join(',')),
            repeatDays: drift.Value('[${repeatDays.join(',')}]'),
            snoozeMinutes: const drift.Value(10),
            updatedAt: drift.Value(created),
          ),
        );

    if (todayStatus != null) {
      final DateTime now = DateTime.now();
      final String key =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      await appDatabase.upsertRoutineLog(
        routineId: id,
        dateKey: key,
        reminderTime: reminderTimes.first,
        status: todayStatus,
      );
    }
  }

  /// Wraps [screen] in the scope and providers a real route would give it.
  Widget wrap(
    Widget screen, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
  }) {
    return AppScope(
      dependencies: dependencies,
      child: BlocProvider<SettingsBloc>(
        create: (_) =>
            SettingsBloc(repository: settingsRepository)
              ..add(const SettingsStarted()),
        child: localizedApp(screen, locale: locale, brightness: brightness),
      ),
    );
  }
}

/// Sizes the test surface to a phone of [logicalWidth] dp.
void useScreenWidth(WidgetTester tester, double logicalWidth) {
  tester.view.physicalSize = Size(logicalWidth * 3, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
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

/// A [RoutineRepository] whose `watchRoutines` is a plain synchronous stream,
/// so screens that listen to it settle immediately in a widget test.
class StaticRoutineRepository implements RoutineRepository {
  StaticRoutineRepository(this.routines);

  final List<domain.Routine> routines;

  @override
  Stream<List<domain.Routine>> watchRoutines() =>
      Stream<List<domain.Routine>>.value(routines);

  @override
  Future<domain.Routine?> getRoutineById(String id) async {
    for (final domain.Routine routine in routines) {
      if (routine.id == id) {
        return routine;
      }
    }
    return null;
  }

  @override
  Future<void> createRoutine(domain.Routine routine) async {}

  @override
  Future<void> updateRoutine(domain.Routine routine) async {}

  @override
  Future<void> deleteRoutine(String id) async {}
}
