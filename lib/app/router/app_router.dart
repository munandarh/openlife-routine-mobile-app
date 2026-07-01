import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:openlife_routine/features/routine_detail/presentation/pages/routine_detail_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

final class AppRouter {
  AppRouter({required bool hasCompletedOnboarding})
    : router = GoRouter(
        initialLocation: hasCompletedOnboarding
            ? OpenLifeRoute.today.path
            : OpenLifeRoute.onboarding.path,
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
            path: OpenLifeRoute.templates.path,
            name: OpenLifeRoute.templates.name,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return _shellPage(
                child: const TemplatesPage(),
                currentRoute: OpenLifeRoute.templates,
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
          GoRoute(
            path: OpenLifeRoute.newRoutine.path,
            name: OpenLifeRoute.newRoutine.name,
            builder: (BuildContext context, GoRouterState state) {
              return const NewRoutinePage();
            },
          ),
          GoRoute(
            path: OpenLifeRoute.routineDetail.path,
            name: OpenLifeRoute.routineDetail.name,
            builder: (BuildContext context, GoRouterState state) {
              return const RoutineDetailPage();
            },
          ),
        ],
      );

  final GoRouter router;

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
  onboarding(
    path: '/onboarding',
    label: 'Onboarding',
    icon: Icons.spa_outlined,
  ),
  today(path: '/today', label: 'Today', icon: Icons.today_outlined),
  routines(
    path: '/routines',
    label: 'Routines',
    icon: Icons.calendar_today_outlined,
  ),
  templates(
    path: '/routines/templates',
    label: 'Templates',
    icon: Icons.dashboard_customize_outlined,
  ),
  insights(path: '/insights', label: 'Insights', icon: Icons.insights_outlined),
  settings(path: '/settings', label: 'Settings', icon: Icons.settings_outlined),
  newRoutine(
    path: '/routines/new',
    label: 'New Routine',
    icon: Icons.add_circle_outline,
  ),
  routineDetail(
    path: '/routines/detail',
    label: 'Routine Detail',
    icon: Icons.more_horiz,
  );

  const OpenLifeRoute({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;

  String get name => switch (this) {
    OpenLifeRoute.onboarding => 'onboarding',
    OpenLifeRoute.today => 'today',
    OpenLifeRoute.routines => 'routines',
    OpenLifeRoute.templates => 'templates',
    OpenLifeRoute.insights => 'insights',
    OpenLifeRoute.settings => 'settings',
    OpenLifeRoute.newRoutine => 'newRoutine',
    OpenLifeRoute.routineDetail => 'routineDetail',
  };

  bool get isNestedUnderRoutines =>
      this == OpenLifeRoute.routines ||
      this == OpenLifeRoute.templates ||
      this == OpenLifeRoute.newRoutine ||
      this == OpenLifeRoute.routineDetail;

  static const List<OpenLifeRoute> bottomNavRoutes = <OpenLifeRoute>[
    OpenLifeRoute.today,
    OpenLifeRoute.routines,
    OpenLifeRoute.insights,
    OpenLifeRoute.settings,
  ];
}
