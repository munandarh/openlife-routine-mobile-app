import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/app_locales.dart';
import 'package:openlife_routine/core/theme/app_theme.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_state.dart';

class OpenLifeApp extends StatefulWidget {
  const OpenLifeApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<OpenLifeApp> createState() => _OpenLifeAppState();
}

class _OpenLifeAppState extends State<OpenLifeApp> {
  late final AppRouter _appRouter;
  late final SettingsBloc _settingsBloc;
  StreamSubscription<String>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _settingsBloc = widget.dependencies.createSettingsBloc()
      ..add(const SettingsStarted());
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
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: widget.dependencies,
      child: BlocProvider<SettingsBloc>.value(
        value: _settingsBloc,
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (BuildContext context, SettingsState state) {
            return MaterialApp.router(
              title: 'OpenLife Routine',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: _themeModeFromString(state.themeMode),
              routerConfig: _appRouter.router,
              supportedLocales: AppLocales.supportedLocales,
              locale: AppLocales.localeFromCode(state.languageCode),
            );
          },
        ),
      ),
    );
  }

  static ThemeMode _themeModeFromString(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
