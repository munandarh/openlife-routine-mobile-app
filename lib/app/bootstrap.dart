import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:openlife_routine/app/app.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/features/today/domain/services/missed_state_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDependencies dependencies = await AppDependencies.bootstrap();

  // Mark routines that were pending yesterday as missed.
  unawaited(
    MissedStateService(appDatabase: dependencies.appDatabase)
        .markYesterdayPendingAsMissed(),
  );

  runApp(OpenLifeApp(dependencies: dependencies));
}
