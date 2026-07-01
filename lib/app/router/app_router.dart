import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:openlife_routine/features/insights/presentation/pages/insights_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: OpenLifeRoute.today.path,
    routes: <RouteBase>[
      GoRoute(
        path: OpenLifeRoute.onboarding.path,
        name: OpenLifeRoute.onboarding.name,
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingPage();
        },
      ),
      GoRoute(
        path: OpenLifeRoute.today.path,
        name: OpenLifeRoute.today.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _shellPage(
            child: const TodayPage(),
            currentRoute: OpenLifeRoute.today,
          );
        },
      ),
      GoRoute(
        path: OpenLifeRoute.routines.path,
        name: OpenLifeRoute.routines.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _shellPage(
            child: const RoutinesPage(),
            currentRoute: OpenLifeRoute.routines,
          );
        },
      ),
      GoRoute(
        path: OpenLifeRoute.insights.path,
        name: OpenLifeRoute.insights.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _shellPage(
            child: const InsightsPage(),
            currentRoute: OpenLifeRoute.insights,
          );
        },
      ),
      GoRoute(
        path: OpenLifeRoute.settings.path,
        name: OpenLifeRoute.settings.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _shellPage(
            child: const SettingsPage(),
            currentRoute: OpenLifeRoute.settings,
          );
        },
      ),
    ],
  );

  static NoTransitionPage<void> _shellPage({
    required Widget child,
    required OpenLifeRoute currentRoute,
  }) {
    return NoTransitionPage<void>(
      child: OpenLifeShell(currentRoute: currentRoute, child: child),
    );
  }
}

enum OpenLifeRoute {
  onboarding('/onboarding'),
  today('/today'),
  routines('/routines'),
  insights('/insights'),
  settings('/settings');

  const OpenLifeRoute(this.path);

  final String path;

  String get name => switch (this) {
    OpenLifeRoute.onboarding => 'onboarding',
    OpenLifeRoute.today => 'today',
    OpenLifeRoute.routines => 'routines',
    OpenLifeRoute.insights => 'insights',
    OpenLifeRoute.settings => 'settings',
  };
}
