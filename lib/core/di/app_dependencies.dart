import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/core/storage/local_database_config.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_bloc.dart';
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
import 'package:openlife_routine/features/settings/data/repositories/shared_prefs_settings_repository.dart';
import 'package:openlife_routine/features/settings/data/services/export_import_service.dart';
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/templates/domain/repositories/template_repository.dart';
import 'package:openlife_routine/features/templates/domain/usecases/apply_template_use_case.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_bloc.dart';
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  const AppDependencies({
    required this.databaseConfig,
    required this.notificationConfig,
    required this.onboardingRepository,
    required this.hasCompletedOnboarding,
    required this.appDatabase,
    required this.routineRepository,
    required this.notificationService,
    required this.initialNotificationRoutineId,
    required this.settingsRepository,
  });

  final LocalDatabaseConfig databaseConfig;
  final NotificationStackConfig notificationConfig;
  final OnboardingRepository onboardingRepository;
  final bool hasCompletedOnboarding;
  final AppDatabase appDatabase;
  final RoutineRepository routineRepository;
  final AppNotificationService notificationService;
  final String? initialNotificationRoutineId;
  final SettingsRepository settingsRepository;

  static Future<AppDependencies> bootstrap() async {
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    final OnboardingRepository onboardingRepository =
        SharedPrefsOnboardingRepository(preferences);
    final bool hasCompletedOnboarding = await onboardingRepository
        .hasCompletedOnboarding();
    final AppDatabase appDatabase = AppDatabase();
    final RoutineRepository routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );
    final SettingsRepository settingsRepository = SharedPrefsSettingsRepository(
      preferences,
    );
    final AppNotificationService notificationService = AppNotificationService();
    // Reminder text is rendered by the service, so it needs the chosen
    // language before any schedule is written — and before `initialize`,
    // because iOS bakes the action labels into the category it registers
    // there and cannot relabel them afterwards.
    notificationService.setLanguageCode(
      await settingsRepository.getLanguageCode(),
    );
    final String? initialNotificationRoutineId = await notificationService
        .initialize();
    // Lets a notification action handled while the app is alive write the same
    // log the background isolate would.
    notificationService.attachDatabase(appDatabase);
    await notificationService.syncRoutineSchedules(appDatabase);

    return AppDependencies(
      databaseConfig: const LocalDatabaseConfig.recommended(),
      notificationConfig: const NotificationStackConfig.recommended(),
      onboardingRepository: onboardingRepository,
      hasCompletedOnboarding: hasCompletedOnboarding,
      appDatabase: appDatabase,
      routineRepository: routineRepository,
      notificationService: notificationService,
      initialNotificationRoutineId: initialNotificationRoutineId,
      settingsRepository: settingsRepository,
    );
  }

  RoutineBloc createRoutineBloc() {
    return RoutineBloc(
      watchRoutinesUseCase: WatchRoutinesUseCase(routineRepository),
      createRoutineUseCase: CreateRoutineUseCase(routineRepository),
      updateRoutineUseCase: UpdateRoutineUseCase(routineRepository),
      deleteRoutineUseCase: DeleteRoutineUseCase(routineRepository),
      getRoutineUseCase: GetRoutineUseCase(routineRepository),
      notificationService: notificationService,
    );
  }

  TodayBloc createTodayBloc() {
    return TodayBloc(
      appDatabase: appDatabase,
      notificationService: notificationService,
    );
  }

  TemplateBloc createTemplateBloc() {
    return TemplateBloc(repository: const TemplateRepository());
  }

  InsightsBloc createInsightsBloc() {
    return InsightsBloc(appDatabase: appDatabase);
  }

  SettingsBloc createSettingsBloc() {
    return SettingsBloc(repository: settingsRepository);
  }

  ApplyTemplateUseCase createApplyTemplateUseCase() {
    return ApplyTemplateUseCase(
      repository: routineRepository,
      notificationService: notificationService,
    );
  }

  ExportImportService createExportImportService() {
    return ExportImportService(
      appDatabase: appDatabase,
      notificationService: notificationService,
    );
  }
}
