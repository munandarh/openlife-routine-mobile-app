import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/core/storage/local_database_config.dart';
import 'package:openlife_routine/features/onboarding/data/repositories/shared_prefs_onboarding_repository.dart';
import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/usecases/create_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/delete_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/get_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/update_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/watch_routines_use_case.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  const AppDependencies({
    required this.databaseConfig,
    required this.notificationConfig,
    required this.onboardingRepository,
    required this.hasCompletedOnboarding,
    required this.preferredLanguageCode,
    required this.appDatabase,
    required this.routineRepository,
  });

  final LocalDatabaseConfig databaseConfig;
  final NotificationStackConfig notificationConfig;
  final OnboardingRepository onboardingRepository;
  final bool hasCompletedOnboarding;
  final String preferredLanguageCode;
  final AppDatabase appDatabase;
  final RoutineRepository routineRepository;

  static Future<AppDependencies> bootstrap() async {
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    final OnboardingRepository onboardingRepository =
        SharedPrefsOnboardingRepository(preferences);
    final bool hasCompletedOnboarding = await onboardingRepository
        .hasCompletedOnboarding();
    final String preferredLanguageCode = await onboardingRepository
        .getPreferredLanguageCode();
    final AppDatabase appDatabase = AppDatabase();
    final RoutineRepository routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );

    return AppDependencies(
      databaseConfig: const LocalDatabaseConfig.recommended(),
      notificationConfig: const NotificationStackConfig.recommended(),
      onboardingRepository: onboardingRepository,
      hasCompletedOnboarding: hasCompletedOnboarding,
      preferredLanguageCode: preferredLanguageCode,
      appDatabase: appDatabase,
      routineRepository: routineRepository,
    );
  }

  RoutineBloc createRoutineBloc() {
    return RoutineBloc(
      watchRoutinesUseCase: WatchRoutinesUseCase(routineRepository),
      createRoutineUseCase: CreateRoutineUseCase(routineRepository),
      updateRoutineUseCase: UpdateRoutineUseCase(routineRepository),
      deleteRoutineUseCase: DeleteRoutineUseCase(routineRepository),
      getRoutineUseCase: GetRoutineUseCase(routineRepository),
    );
  }

  TodayBloc createTodayBloc() {
    return TodayBloc(appDatabase: appDatabase);
  }
}
