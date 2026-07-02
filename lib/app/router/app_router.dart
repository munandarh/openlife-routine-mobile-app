import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:openlife_routine/features/routine_detail/presentation/pages/routine_detail_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/privacy_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/about_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

final class AppRouter {
  AppRouter({
    required bool hasCompletedOnboarding,
    required String? initialNotificationRoutineId,
  }) : router = GoRouter(
         initialLocation: _initialLocation(
           hasCompletedOnboarding: hasCompletedOnboarding,
           initialNotificationRoutineId: initialNotificationRoutineId,
         ),
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
             pageBuilder: (BuildContext context, GoRouterState state) {
               return _shellPage(
                 child: NewRoutinePage(
                   routineId: state.uri.queryParameters['id'],
                 ),
                 currentRoute: OpenLifeRoute.newRoutine,
               );
             },
           ),
           GoRoute(
             path: OpenLifeRoute.routineDetail.path,
             name: OpenLifeRoute.routineDetail.name,
             pageBuilder: (BuildContext context, GoRouterState state) {
               return _shellPage(
                 child: RoutineDetailPage(
                   routineId: state.uri.queryParameters['id'] ?? '',
                 ),
                 currentRoute: OpenLifeRoute.routineDetail,
               );
             },
           ),
           GoRoute(
             path: OpenLifeRoute.privacy.path,
             name: OpenLifeRoute.privacy.name,
             builder: (BuildContext context, GoRouterState state) {
               return const PrivacyPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.about.path,
             name: OpenLifeRoute.about.name,
             builder: (BuildContext context, GoRouterState state) {
               return const AboutPage();
             },
           ),
         ],
       );

  final GoRouter router;

  static String _initialLocation({
    required bool hasCompletedOnboarding,
    required String? initialNotificationRoutineId,
  }) {
    if (!hasCompletedOnboarding) {
      return OpenLifeRoute.onboarding.path;
    }
    if (initialNotificationRoutineId == null ||
        initialNotificationRoutineId.isEmpty) {
      return OpenLifeRoute.today.path;
    }
    return Uri(
      path: OpenLifeRoute.routineDetail.path,
      queryParameters: <String, String>{'id': initialNotificationRoutineId},
    ).toString();
  }
}

NoTransitionPage<void> _shellPage({
  required Widget child,
  required OpenLifeRoute currentRoute,
}) {
  return NoTransitionPage<void>(
    child: OpenLifeShell(currentRoute: currentRoute, child: child),
  );
}

enum OpenLifeRoute {
  onboarding('/onboarding', 'Onboarding', Icons.spa_outlined),
  today('/today', 'Today', Icons.today_outlined),
  routines('/routines', 'Routines', Icons.calendar_today_outlined),
  templates(
    '/routines/templates',
    'Templates',
    Icons.dashboard_customize_outlined,
  ),
  insights('/insights', 'Insights', Icons.insights_outlined),
  settings('/settings', 'Settings', Icons.settings_outlined),
  newRoutine('/routines/new', 'New Routine', Icons.add_circle_outline),
  routineDetail('/routines/detail', 'Routine Detail', Icons.more_horiz),
  privacy('/settings/privacy', 'Privacy', Icons.shield_outlined),
  about('/settings/about', 'About', Icons.code_outlined);

  const OpenLifeRoute(this.path, this.label, this.icon);

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
    OpenLifeRoute.privacy => 'privacy',
    OpenLifeRoute.about => 'about',
  };

  bool get isNestedUnderRoutines {
    return this == OpenLifeRoute.routines ||
        this == OpenLifeRoute.templates ||
        this == OpenLifeRoute.newRoutine ||
        this == OpenLifeRoute.routineDetail;
  }

  static const List<OpenLifeRoute> bottomNavRoutes = <OpenLifeRoute>[
    OpenLifeRoute.today,
    OpenLifeRoute.routines,
    OpenLifeRoute.insights,
    OpenLifeRoute.settings,
  ];
}
