import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/features/insights/presentation/pages/insights_page.dart';
import 'package:openlife_routine/features/routine_detail/presentation/pages/routine_detail_page.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/pages/new_routine_page.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/settings_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';

import '../support/screen_harness.dart';

/// Dark mode shipped as a v1.0 feature but was unusable: the greeting, the week
/// strip, routine titles and the navigation labels were all painted with the
/// light theme's near-black text on a near-black background, because widgets
/// referenced `AppColors.textPrimary` directly instead of resolving it from the
/// theme.
///
/// These are the invariants that would have caught it.
void main() {
  late ScreenHarness harness;

  final DateTime seededAt = DateTime(2026, 1, 1);

  setUp(() async {
    harness = ScreenHarness(
      routineRepositoryOverride: StaticRoutineRepository(<Routine>[
        Routine(
          id: 'r1',
          title: 'Morning hydration',
          category: RoutineCategory.water,
          reminderTime: '08:00',
          repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
          isEnabled: true,
          createdAt: seededAt,
          updatedAt: seededAt,
        ),
      ]),
    );
    await harness.seedRoutine(id: 'r1', title: 'Morning hydration');
  });

  tearDown(() async {
    await harness.dispose();
  });

  /// Colours that only ever make sense on a light background.
  final List<Color> lightOnlyInk = <Color>[
    AppColors.textPrimary,
    AppColors.textSecondary,
  ];

  // The tab screens have no Scaffold of their own; the router renders them
  // inside OpenLifeShell.
  final Map<String, Widget> screens = <String, Widget>{
    'Today': const OpenLifeShell(
      currentRoute: OpenLifeRoute.today,
      child: TodayPage(),
    ),
    'Routines': const OpenLifeShell(
      currentRoute: OpenLifeRoute.routines,
      child: RoutinesPage(),
    ),
    'Insights': const OpenLifeShell(
      currentRoute: OpenLifeRoute.insights,
      child: InsightsPage(),
    ),
    'Settings': const OpenLifeShell(
      currentRoute: OpenLifeRoute.settings,
      child: SettingsPage(),
    ),
    'New routine': const NewRoutinePage(),
    'Routine detail': const RoutineDetailPage(routineId: 'r1'),
  };

  group('the dark theme carries a dark palette', () {
    testWidgets('AppTheme.dark exposes the dark palette', (
      WidgetTester tester,
    ) async {
      late AppPalette palette;

      await tester.pumpWidget(
        harness.wrap(
          Builder(
            builder: (BuildContext context) {
              palette = context.palette;
              return const SizedBox.shrink();
            },
          ),
          brightness: Brightness.dark,
        ),
      );

      expect(palette.background, AppColors.backgroundDark);
      expect(palette.textPrimary, AppColors.textPrimaryDark);
      expect(palette.textSecondary, AppColors.textSecondaryDark);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('and the light theme still carries the light one', (
      WidgetTester tester,
    ) async {
      late AppPalette palette;

      await tester.pumpWidget(
        harness.wrap(
          Builder(
            builder: (BuildContext context) {
              palette = context.palette;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(palette.background, AppColors.background);
      expect(palette.textPrimary, AppColors.textPrimary);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('no screen paints light-theme ink in dark mode', () {
    screens.forEach((String name, Widget screen) {
      testWidgets(name, (WidgetTester tester) async {
        useScreenWidth(tester, 360);

        await tester.pumpWidget(
          harness.wrap(screen, brightness: Brightness.dark),
        );
        await tester.pump(const Duration(milliseconds: 400));

        final List<String> offenders = <String>[];
        for (final Element element in find.byType(Text).evaluate()) {
          final Text text = element.widget as Text;
          final Color? colour =
              text.style?.color ?? DefaultTextStyle.of(element).style.color;
          if (colour != null && lightOnlyInk.contains(colour)) {
            offenders.add('"${text.data}" -> $colour');
          }
        }

        expect(
          offenders,
          isEmpty,
          reason:
              '$name renders light-theme text colours on a dark background:\n'
              '${offenders.join('\n')}',
        );

        await tester.pumpWidget(const SizedBox.shrink());
      });
    });
  });
}
