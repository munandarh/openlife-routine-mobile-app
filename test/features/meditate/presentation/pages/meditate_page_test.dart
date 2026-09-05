import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/meditate_page.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/anxiety_breath_card.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/feelings_grid.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/quick_start_row.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/todays_pause_card.dart';
import '../../../../support/screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScreenHarness harness;

  setUp(() {
    harness = ScreenHarness();
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('MeditatePage', () {
    testWidgets('renders all key sections correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness.wrap(const MeditatePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Top bar & Header
      expect(find.text('Meditate'), findsWidgets);
      expect(find.text('A little space for yourself.'), findsOneWidget);

      // Today's Pause Card
      expect(find.byType(TodaysPauseCard), findsOneWidget);
      expect(find.text("TODAY'S PAUSE"), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Anxiety Breath Dedicated Card
      expect(find.byType(AnxietyBreathCard), findsOneWidget);
      expect(find.text('ANXIETY BREATH'), findsOneWidget);
      expect(find.text('7 min · Guided breathing'), findsOneWidget);

      // "How do you want to feel?" Grid
      expect(find.byType(FeelingsGrid), findsOneWidget);
      expect(find.text('How do you want to feel?'), findsOneWidget);
      expect(find.text('Calm'), findsOneWidget);
      expect(find.text('Focus'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Sleep'), findsOneWidget);
      expect(find.text('Breathe'), findsNWidgets(2)); // Card button & grid item
      expect(find.text('Stress relief'), findsOneWidget);

      // Scroll down to reveal Quick Start Row
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Quick Start Row
      expect(find.byType(QuickStartRow), findsOneWidget);
      expect(find.text('Quick Start'), findsOneWidget);
      expect(find.text('3 min'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('15 min'), findsOneWidget);

      // Explore all & action buttons have surface background
      expect(find.text('Explore all'), findsOneWidget);
      final exploreButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Explore all'),
      );
      expect(exploreButton.style?.backgroundColor?.resolve({}), isNotNull);

      final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton));
      expect(
        iconButtons.any(
          (b) => b.style?.backgroundColor?.resolve({}) != null,
        ),
        isTrue,
      );
    });
  });
}
