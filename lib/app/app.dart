import 'package:flutter/material.dart';

import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/localization/app_locales.dart';
import 'package:openlife_routine/core/theme/app_theme.dart';

class OpenLifeApp extends StatelessWidget {
  const OpenLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenLife Routine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      supportedLocales: AppLocales.supportedLocales,
      locale: AppLocales.defaultLocale,
    );
  }
}
