import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_empty_page.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_history_page.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/anxiety_breath_setup_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/breathing_player_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/meditate_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/session_complete_page.dart';
import 'package:openlife_routine/features/notifications/presentation/pages/notifications_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/notification_permission_page.dart';
import 'package:openlife_routine/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:openlife_routine/features/profile/presentation/pages/profile_page.dart';
import 'package:openlife_routine/features/routine_detail/presentation/pages/routine_detail_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_empty_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_empty_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/about_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/privacy_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/reminder_health_page.dart';
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
             path: OpenLifeRoute.meditate.path,
             name: OpenLifeRoute.meditate.name,
             pageBuilder: (BuildContext context, GoRouterState state) {
               return _shellPage(
                 child: const MeditatePage(),
                 currentRoute: OpenLifeRoute.meditate,
               );
             },
           ),
           GoRoute(
             path: OpenLifeRoute.anxietyBreathSetup.path,
             name: OpenLifeRoute.anxietyBreathSetup.name,
             builder: (BuildContext context, GoRouterState state) {
               return AnxietyBreathSetupPage(
                 source: state.uri.queryParameters['source'] ?? 'manual',
                 routineId: state.uri.queryParameters['routineId'],
                 reminderTime: state.uri.queryParameters['reminderTime'],
                 occurrenceDate: state.uri.queryParameters['occurrenceDate'],
               );
             },
           ),
           GoRoute(
             path: OpenLifeRoute.breathingPlayer.path,
             name: OpenLifeRoute.breathingPlayer.name,
             redirect: (context, state) => state.extra is AnxietyBreathSetupAuthorization ? null : Uri(path: OpenLifeRoute.anxietyBreathSetup.path, queryParameters: state.uri.queryParameters).toString(),
             builder: (BuildContext context, GoRouterState state) {
               final int exhaleSeconds = int.tryParse(
                 state.uri.queryParameters['exhaleSeconds'] ?? '7',
               ) ?? 7;
               return BreathingPlayerPage(
                 exhaleSeconds: exhaleSeconds,
                 source: state.uri.queryParameters['source'] ?? 'manual',
                 routineId: state.uri.queryParameters['routineId'],
                 reminderTime: state.uri.queryParameters['reminderTime'],
                 occurrenceDate: state.uri.queryParameters['occurrenceDate'],
               );
             },
           ),
           GoRoute(
             path: OpenLifeRoute.sessionComplete.path,
             name: OpenLifeRoute.sessionComplete.name,
             builder: (BuildContext context, GoRouterState state) {
               final int completedCount = int.tryParse(
                 state.uri.queryParameters['completedCount'] ?? '1',
               ) ?? 1;
               return SessionCompletePage(
                 completedCount: completedCount,
                 sessionId: state.uri.queryParameters['sessionId'],
                 minutes: int.tryParse(state.uri.queryParameters['minutes'] ?? '') ?? 7,
                 type: state.uri.queryParameters['type'] ?? 'anxiety_breath',
                 source: state.uri.queryParameters['source'] ?? 'manual',
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
             path: OpenLifeRoute.insightsHistory.path,
             name: OpenLifeRoute.insightsHistory.name,
             builder: (BuildContext context, GoRouterState state) {
               return const InsightsHistoryPage();
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
             path: OpenLifeRoute.notifications.path,
             name: OpenLifeRoute.notifications.name,
             builder: (BuildContext context, GoRouterState state) {
               return const NotificationsPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.reminderHealth.path,
             name: OpenLifeRoute.reminderHealth.name,
             builder: (BuildContext context, GoRouterState state) {
               return const ReminderHealthPage();
             },
           ),
           GoRoute(
             path: OpenLifeRoute.profile.path,
             name: OpenLifeRoute.profile.name,
             builder: (BuildContext context, GoRouterState state) {
               return const ProfilePage();
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
  meditate('/meditate', 'Meditate', Icons.eco_outlined),
  anxietyBreathSetup(
    '/meditate/anxiety-breath/setup',
    'Choose your exhale',
    Icons.air_rounded,
  ),
  breathingPlayer(
    '/meditate/anxiety-breath/session',
    'Anxiety Breath',
    Icons.air_rounded,
  ),
  sessionComplete(
    '/meditate/session-complete',
    'Session Complete',
    Icons.check_circle_outline_rounded,
  ),
  templates(
    '/routines/templates',
    'Templates',
    Icons.dashboard_customize_outlined,
  ),
  insights('/insights', 'Insights', Icons.insights_outlined),
  insightsHistory('/insights/history', '7-Day History', Icons.history_outlined),
  settings('/settings', 'Settings', Icons.settings_outlined),
  notifications(
    '/notifications',
    'Notifications',
    Icons.notifications_none_rounded,
  ),
  profile('/profile', 'Profile', Icons.person_outline),
  reminderHealth(
    '/settings/reminder-health',
    'Reminder Health',
    Icons.health_and_safety_outlined,
  ),
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
    OpenLifeRoute.notifications => 'notifications',
    OpenLifeRoute.profile => 'profile',
    OpenLifeRoute.reminderHealth => 'reminderHealth',
    OpenLifeRoute.today => 'today',
    OpenLifeRoute.routines => 'routines',
    OpenLifeRoute.meditate => 'meditate',
    OpenLifeRoute.anxietyBreathSetup => 'anxietyBreathSetup',
    OpenLifeRoute.breathingPlayer => 'breathingPlayer',
    OpenLifeRoute.sessionComplete => 'sessionComplete',
    OpenLifeRoute.templates => 'templates',
    OpenLifeRoute.insights => 'insights',
    OpenLifeRoute.insightsHistory => 'insightsHistory',
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
    OpenLifeRoute.meditate,
    OpenLifeRoute.insights,
    OpenLifeRoute.settings,
  ];
}
