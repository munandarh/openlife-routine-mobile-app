import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_history_page.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_page.dart';
import 'package:openlife_routine/features/routine_detail/presentation/pages/routine_detail_page.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/about_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/privacy_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

import '../support/screen_harness.dart';

/// A layout sweep over every real screen, at the narrowest phone we support and
/// in both languages.
///
/// This exists because the Repeat day picker shipped with a row that overflowed
/// a 360dp screen and pushed Sunday out of reach: in a release build the
/// overflow is clipped silently, so nothing surfaces it except a check like
/// this one. Indonesian is included because its copy is frequently longer than
/// the English.
void main() {
  late ScreenHarness harness;

  final DateTime seededAt = DateTime(2026, 1, 1);

  setUp(() async {
    harness = ScreenHarness(
      // Screens that watch routines need a stream that actually delivers under
      // testWidgets; Drift's does not.
      routineRepositoryOverride: StaticRoutineRepository(<Routine>[
        Routine(
          id: 'r1',
          title: 'Morning hydration reminder',
          category: RoutineCategory.water,
          reminderTime: '08:00',
          repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
          isEnabled: true,
          notes: 'Two glasses before coffee',
          createdAt: seededAt,
          updatedAt: seededAt,
        ),
        Routine(
          id: 'r2',
          title: 'Evening stretch',
          category: RoutineCategory.breakTime,
          reminderTime: '20:30',
          repeatDays: const <int>[1, 2, 3, 4, 5],
          isEnabled: true,
          iconKey: 'self_improvement',
          createdAt: seededAt,
          updatedAt: seededAt,
        ),
      ]),
    );
    await harness.seedRoutine(
      id: 'r1',
      title: 'Morning hydration reminder',
      notes: 'Two glasses before coffee',
      todayStatus: 'done',
    );
    await harness.seedRoutine(
      id: 'r2',
      title: 'Evening stretch',
      category: 'breakTime',
      reminderTime: '20:30',
      iconKey: 'self_improvement',
    );
  });

  tearDown(() async {
    await harness.dispose();
  });

  // The four tab screens have no Scaffold of their own: the router renders
  // them inside OpenLifeShell, so the harness does too. That also puts the
  // bottom navigation under test at each width.
  final Map<String, Widget> screens = <String, Widget>{
    'Today': const OpenLifeShell(
      currentRoute: OpenLifeRoute.today,
      child: TodayPage(),
    ),
    'Routines': const OpenLifeShell(
      currentRoute: OpenLifeRoute.routines,
      child: RoutinesPage(),
    ),
    'Templates': const TemplatesPage(),
    'Insights': const OpenLifeShell(
      currentRoute: OpenLifeRoute.insights,
      child: InsightsPage(),
    ),
    'Insights history': const InsightsHistoryPage(),
    'Settings': const OpenLifeShell(
      currentRoute: OpenLifeRoute.settings,
      child: SettingsPage(),
    ),
    'Privacy': const PrivacyPage(),
    'About': const AboutPage(),
    'New routine': const NewRoutinePage(),
    'Edit routine': const NewRoutinePage(routineId: 'r1'),
    'Routine detail': const RoutineDetailPage(routineId: 'r1'),
  };

  /// Scrolls the whole screen so content below the fold is laid out too — an
  /// overflow further down would otherwise never be built.
  Future<void> scrollThrough(WidgetTester tester) async {
    final Finder scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isEmpty) {
      return;
    }
    for (int i = 0; i < 6; i += 1) {
      await tester.drag(scrollable.first, const Offset(0, -400));
      await tester.pump();
    }
  }

  for (final double width in <double>[320, 360, 411]) {
    for (final Locale locale in <Locale>[
      const Locale('en'),
      const Locale('id'),
    ]) {
      group('${width.toInt()}dp / ${locale.languageCode}', () {
        screens.forEach((String name, Widget screen) {
          testWidgets('$name lays out without overflow', (
            WidgetTester tester,
          ) async {
            useScreenWidth(tester, width);

            await tester.pumpWidget(harness.wrap(screen, locale: locale));
            await tester.pump(const Duration(milliseconds: 400));
            await scrollThrough(tester);

            expect(tester.takeException(), isNull);

            // Unmount before tearDown closes the database: RoutineBloc holds a
            // live Drift stream, and closing underneath it deadlocks.
            await tester.pumpWidget(const SizedBox.shrink());
          });
        });
      });
    }
  }
}
