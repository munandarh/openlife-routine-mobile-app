import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/app_locales.dart';
import 'package:openlife_routine/core/theme/app_theme.dart';

class OpenLifeApp extends StatefulWidget {
  const OpenLifeApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<OpenLifeApp> createState() => _OpenLifeAppState();
}

class _OpenLifeAppState extends State<OpenLifeApp> {
  late final AppRouter _appRouter;
  StreamSubscription<String>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      hasCompletedOnboarding: widget.dependencies.hasCompletedOnboarding,
      initialNotificationRoutineId:
          widget.dependencies.initialNotificationRoutineId,
    );
    _notificationSubscription = widget
        .dependencies
        .notificationService
        .routineTapStream
        .listen((String routineId) {
          _appRouter.router.go(
            Uri(
              path: OpenLifeRoute.routineDetail.path,
              queryParameters: <String, String>{'id': routineId},
            ).toString(),
          );
        });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: widget.dependencies,
      child: MaterialApp.router(
        title: 'OpenLife Routine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
        supportedLocales: AppLocales.supportedLocales,
        locale: AppLocales.localeFromCode(
          widget.dependencies.preferredLanguageCode,
        ),
      ),
    );
  }
}
