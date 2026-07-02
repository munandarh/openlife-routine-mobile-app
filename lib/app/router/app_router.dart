import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_empty_page.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/notification_permission_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:openlife_routine/features/routine_detail/presentation/pages/routine_detail_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_empty_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_empty_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/about_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/privacy_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/features/splash/presentation/pages/splash_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

final class AppRouter {
  AppRouter({
    required bool hasCompletedOnboarding,
    required String? initialNotificationRoutineId,
  }) : router = GoRouter(
         initialLocation: OpenLifeRoute.splash.path,
         routes: <RouteBase>[
           GoRoute(
             path: OpenLifeRoute.splash.path,
             name: OpenLifeRoute.splash.name,
             builder: (BuildContext context, GoRouterState state) {
               return SplashPage(
                 hasCompletedOnboarding: hasCompletedOnboarding,
                 initialNotificationRoutineId: initialNotificationRoutineId,
               );
             },
           ),
           GoRoute(
             path: OpenLifeRoute.onboarding.path,
             name: OpenLifeRoute.onboarding.name,
             builder: (BuildContext context, GoRouterState state) {
               return const OnboardingPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.notificationPermission.path,
             name: OpenLifeRoute.notificationPermission.name,
             builder: (BuildContext context, GoRouterState state) {
               return const NotificationPermissionPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.languageSelection.path,
             name: OpenLifeRoute.languageSelection.name,
             builder: (BuildContext context, GoRouterState state) {
               return const LanguageSelectionPage();
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
             builder: (BuildContext context, GoRouterState state) {
               return const TemplatesPage();
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
               return NewRoutinePage(
                 routineId: state.uri.queryParameters['id'],
               );
             },
           ),
           GoRoute(
             path: OpenLifeRoute.routineDetail.path,
             name: OpenLifeRoute.routineDetail.name,
             builder: (BuildContext context, GoRouterState state) {
               return RoutineDetailPage(
                 routineId: state.uri.queryParameters['id'] ?? '',
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
           GoRoute(
             path: OpenLifeRoute.todayEmpty.path,
             name: OpenLifeRoute.todayEmpty.name,
             builder: (BuildContext context, GoRouterState state) {
               return const TodayEmptyPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.routinesEmpty.path,
             name: OpenLifeRoute.routinesEmpty.name,
             builder: (BuildContext context, GoRouterState state) {
               return const RoutinesEmptyPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.insightsEmpty.path,
             name: OpenLifeRoute.insightsEmpty.name,
             builder: (BuildContext context, GoRouterState state) {
               return const InsightsEmptyPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.templatesEmpty.path,
             name: OpenLifeRoute.templatesEmpty.name,
             builder: (BuildContext context, GoRouterState state) {
               return const TemplatesEmptyPage();
             },
           ),
         ],
       );

  final GoRouter router;
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
  splash('/splash', 'Splash', Icons.spa_outlined),
  onboarding('/onboarding', 'Onboarding', Icons.spa_outlined),
  notificationPermission(
    '/onboarding/notification-permission',
    'Notification Permission',
    Icons.notifications_active_outlined,
  ),
  languageSelection(
    '/onboarding/language-selection',
    'Language Selection',
    Icons.language_outlined,
  ),
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
  about('/settings/about', 'About', Icons.code_outlined),
  todayEmpty('/screens/today-empty', 'Today Empty', Icons.event_note_outlined),
  routinesEmpty(
    '/screens/routines-empty',
    'Routines Empty',
    Icons.calendar_view_day_outlined,
  ),
  insightsEmpty(
    '/screens/insights-empty',
    'Insights Empty',
    Icons.insights_outlined,
  ),
  templatesEmpty(
    '/screens/templates-empty',
    'Templates Empty',
    Icons.dashboard_customize_outlined,
  );

  const OpenLifeRoute(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;

  String get name => switch (this) {
    OpenLifeRoute.splash => 'splash',
    OpenLifeRoute.onboarding => 'onboarding',
    OpenLifeRoute.notificationPermission => 'notificationPermission',
    OpenLifeRoute.languageSelection => 'languageSelection',
    OpenLifeRoute.today => 'today',
    OpenLifeRoute.routines => 'routines',
    OpenLifeRoute.templates => 'templates',
    OpenLifeRoute.insights => 'insights',
    OpenLifeRoute.settings => 'settings',
    OpenLifeRoute.newRoutine => 'newRoutine',
    OpenLifeRoute.routineDetail => 'routineDetail',
    OpenLifeRoute.privacy => 'privacy',
    OpenLifeRoute.about => 'about',
    OpenLifeRoute.todayEmpty => 'todayEmpty',
    OpenLifeRoute.routinesEmpty => 'routinesEmpty',
    OpenLifeRoute.insightsEmpty => 'insightsEmpty',
    OpenLifeRoute.templatesEmpty => 'templatesEmpty',
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
