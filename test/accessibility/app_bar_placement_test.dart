import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/features/routine_detail/presentation/pages/routine_detail_page.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/about_page.dart';
import 'package:openlife_routine/features/settings/presentation/pages/privacy_page.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_page.dart';
import 'package:openlife_routine/shared/navigation/openlife_shell.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';

import '../support/app_fonts.dart';
import '../support/screen_harness.dart';

/// Where the header sits, and what it carries.
///
/// Privacy and About were the last two screens still putting the header inside
/// a scroll view with no SafeArea: on a device the back button sat under the
/// status bar and scrolled away with the content, while every other pushed
/// screen pinned it below the notch.
void main() {
  late ScreenHarness harness;

  // Without the real font every glyph measures 1em square, so "does this
  // label fit?" would be answered against a typeface the app never ships.
  setUpAll(loadAppFonts);

  final DateTime seededAt = DateTime(2026, 1, 1);

  setUp(() async {
    harness = ScreenHarness(
      routineRepositoryOverride: StaticRoutineRepository(<Routine>[
        Routine(
          id: 'r1',
          title: 'Morning hydration reminder',
          category: RoutineCategory.water,
          reminderTime: '08:00',
          repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
          isEnabled: true,
          // Long enough that the old layout pushed the buttons below the fold.
          notes:
              'Two glasses before coffee, one more before the walk, and '
              'keep the bottle on the desk so it is in sight all morning.',
          createdAt: seededAt,
          updatedAt: seededAt,
        ),
      ]),
    );
    await harness.seedRoutine(
      id: 'r1',
      title: 'Morning hydration reminder',
      notes:
          'Two glasses before coffee, one more before the walk, and keep '
          'the bottle on the desk so it is in sight all morning.',
    );
  });

  tearDown(() async {
    await harness.dispose();
  });

  /// A status bar tall enough that a header ignoring it lands underneath.
  const double statusBarHeight = 48;

  Future<void> pumpWithNotch(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 1900);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: statusBarHeight * 3);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(harness.wrap(screen));
    await tester.pumpAndSettle();
  }

  for (final MapEntry<String, Widget> entry in <String, Widget>{
    'Privacy': const PrivacyPage(),
    'About': const AboutPage(),
    'Routine detail': const RoutineDetailPage(routineId: 'r1'),
  }.entries) {
    testWidgets('${entry.key} clears the status bar', (
      WidgetTester tester,
    ) async {
      await pumpWithNotch(tester, entry.value);

      final double top = tester.getTopLeft(find.byType(OpenLifeAppBar)).dy;
      expect(
        top,
        greaterThanOrEqualTo(statusBarHeight),
        reason: '${entry.key} draws its header under the status bar',
      );
    });

    testWidgets('${entry.key} keeps its header while the body scrolls', (
      WidgetTester tester,
    ) async {
      await pumpWithNotch(tester, entry.value);

      final double before = tester.getTopLeft(find.byType(OpenLifeAppBar)).dy;
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.byType(OpenLifeAppBar), findsOneWidget);
      expect(tester.getTopLeft(find.byType(OpenLifeAppBar)).dy, before);
    });
  }

  testWidgets('Today offers no add action; Routines does', (
    WidgetTester tester,
  ) async {
    await pumpWithNotch(
      tester,
      const OpenLifeShell(
        currentRoute: OpenLifeRoute.today,
        child: TodayPage(),
      ),
    );

    // Creating a routine belongs to the Routines tab. Today reads the day.
    expect(
      tester.widget<OpenLifeAppBar>(find.byType(OpenLifeAppBar)).onAddRoutine,
      isNull,
    );

    await pumpWithNotch(
      tester,
      const OpenLifeShell(
        currentRoute: OpenLifeRoute.routines,
        child: RoutinesPage(),
      ),
    );

    expect(
      tester.widget<OpenLifeAppBar>(find.byType(OpenLifeAppBar)).onAddRoutine,
      isNotNull,
    );
  });

  testWidgets('Routine detail keeps Edit and Delete on screen', (
    WidgetTester tester,
  ) async {
    await pumpWithNotch(tester, const RoutineDetailPage(routineId: 'r1'));

    final Finder edit = find.text('Edit routine');
    final Finder delete = find.text('Delete routine');
    expect(edit, findsOneWidget);
    expect(delete, findsOneWidget);

    // They used to be the last two children of the scrolling list, so on a
    // routine with notes they sat below the fold. Asserting they are outside
    // the scroll view says that directly, whatever the test surface's height.
    for (final Finder action in <Finder>[edit, delete]) {
      expect(
        find.descendant(of: find.byType(Scrollable), matching: action),
        findsNothing,
      );
    }

    // "Delete routine" shipped as "Delete rou…" when the row split 1:2.
    for (final Finder action in <Finder>[edit, delete]) {
      // Both declare ellipsis as a safety valve, so what matters is whether
      // the paragraph actually had to use it.
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        action,
      );
      expect(
        paragraph.didExceedMaxLines,
        isFalse,
        reason: 'label was truncated',
      );
    }

    final double editBottom = tester.getBottomLeft(edit).dy;

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(edit, findsOneWidget);
    expect(delete, findsOneWidget);
    expect(tester.getBottomLeft(edit).dy, editBottom);
  });
}
