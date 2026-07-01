import 'package:flutter/widgets.dart';
import 'package:openlife_routine/app/app.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDependencies dependencies = await AppDependencies.bootstrap();

  runApp(OpenLifeApp(dependencies: dependencies));
}
