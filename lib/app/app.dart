import 'package:flutter/material.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/app_locales.dart';
import 'package:openlife_routine/core/theme/app_theme.dart';

class OpenLifeApp extends StatelessWidget {
  const OpenLifeApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: dependencies,
      child: MaterialApp.router(
        title: 'OpenLife Routine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter(
          hasCompletedOnboarding: dependencies.hasCompletedOnboarding,
        ).router,
        supportedLocales: AppLocales.supportedLocales,
        locale: AppLocales.localeFromCode(dependencies.preferredLanguageCode),
      ),
    );
  }
}
