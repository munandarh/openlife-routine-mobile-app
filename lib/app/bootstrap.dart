import 'package:flutter/widgets.dart';
import 'package:openlife_routine/app/app.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/settings/domain/repositories/settings_repository.dart';
import 'package:openlife_routine/features/today/domain/services/missed_state_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDependencies dependencies = await AppDependencies.bootstrap();

  await closeOutPastDays(
    appDatabase: dependencies.appDatabase,
    settingsRepository: dependencies.settingsRepository,
  );

  runApp(OpenLifeApp(dependencies: dependencies));
}

/// Runs the missed-state sweep for every day since it last completed.
///
/// Awaited before the first frame so Today and Insights never render a stale
/// "pending" for a day that is already over. It is cheap on repeat launches:
/// the sweep short-circuits once the cursor reaches today.
Future<void> closeOutPastDays({
  required AppDatabase appDatabase,
  required SettingsRepository settingsRepository,
  DateTime Function()? nowProvider,
}) async {
  final DateTime Function() now = nowProvider ?? DateTime.now;
  final DateTime? lastSweep = await settingsRepository.getLastMissedSweepDate();

  await MissedStateService(
    appDatabase: appDatabase,
    nowProvider: now,
  ).sweepMissedDays(since: lastSweep);

  // Record the last day actually closed out — yesterday — so tomorrow's run
  // picks up today. Recording "today" would skip it forever.
  final DateTime today = now();
  await settingsRepository.setLastMissedSweepDate(
    DateTime(today.year, today.month, today.day).subtract(
      const Duration(days: 1),
    ),
  );
}
