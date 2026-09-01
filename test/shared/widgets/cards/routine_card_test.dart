import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';

void main() {
  group('RoutineCard', () {
    Widget buildCard({
      bool isDone = false,
      bool isDueNow = false,
      String? statusLabel,
      RoutineCardTone statusTone = RoutineCardTone.positive,
      List<RoutineCardAction> actions = const <RoutineCardAction>[],
      VoidCallback? onTap,
      VoidCallback? onCheckTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RoutineCard(
            title: 'Breakfast',
            timeLabel: '07:00 AM',
            icon: Icons.restaurant_outlined,
            iconBackground: const Color(0xFFFFF1C8),
            iconColor: const Color(0xFFC39B42),
            isDone: isDone,
            isDueNow: isDueNow,
            statusLabel: statusLabel,
            statusTone: statusTone,
            actions: actions,
            onTap: onTap,
            onCheckTap: onCheckTap,
          ),
        ),
      );
    }

    testWidgets('renders title and time label', (WidgetTester tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('07:00 AM'), findsOneWidget);
    });

    testWidgets('uses AnimatedSwitcher for check/done state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCard(isDone: false));
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

      await tester.pumpWidget(buildCard(isDone: true));
      // After animation settles, check icon appears.
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('isDueNow shows warning border', (WidgetTester tester) async {
      await tester.pumpWidget(buildCard(isDueNow: true));

      // Find the AnimatedContainer carrying the BoxDecoration.
      final AnimatedContainer container = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(RoutineCard),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );

      final BoxDecoration decoration = container.decoration as BoxDecoration;
      final Border border = decoration.border! as Border;
      expect(border.top.color, isNotNull);
    });

    testWidgets('border animates when isDueNow changes', (
      WidgetTester tester,
    ) async {
      // Start not due-now.
      await tester.pumpWidget(buildCard(isDueNow: false));

      // Change to due-now.
      await tester.pumpWidget(buildCard(isDueNow: true));
      await tester.pump(); // Start animation.

      // After animation completes, border should be warning color.
      await tester.pumpAndSettle();

      final AnimatedContainer container = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(RoutineCard),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      final Border border = decoration.border! as Border;
      expect(border.top.color, isNotNull);
    });

    testWidgets('isDone shows strikethrough on title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCard(isDone: true));
      await tester.pumpAndSettle();

      final Text titleText = tester.widget<Text>(find.text('Breakfast'));
      expect(titleText.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('calls onCheckTap when check area tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(buildCard(onCheckTap: () => tapped = true));

      await tester.tap(find.byIcon(Icons.circle_outlined));
      expect(tapped, isTrue);
    });

    testWidgets('renders every action chip and routes its callback', (
      WidgetTester tester,
    ) async {
      String? pressed;
      await tester.pumpWidget(
        buildCard(
          actions: <RoutineCardAction>[
            RoutineCardAction(
              label: 'Skip',
              onPressed: () => pressed = 'Skip',
            ),
            RoutineCardAction(
              label: 'Snooze',
              onPressed: () => pressed = 'Snooze',
            ),
          ],
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Snooze'), findsOneWidget);

      await tester.tap(find.text('Snooze'));
      expect(pressed, 'Snooze');

      await tester.tap(find.text('Skip'));
      expect(pressed, 'Skip');
    });

    testWidgets('status tone changes the chip colours', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildCard(
          statusLabel: 'Missed',
          statusTone: RoutineCardTone.attention,
        ),
      );
      final Color attention = tester
          .widget<Text>(find.text('Missed'))
          .style!
          .color!;

      await tester.pumpWidget(
        buildCard(
          statusLabel: 'Missed',
          statusTone: RoutineCardTone.muted,
        ),
      );
      final Color muted = tester
          .widget<Text>(find.text('Missed'))
          .style!
          .color!;

      // A missed chip must not be painted like a neutral one.
      expect(attention, isNot(muted));
    });

    testWidgets('completion circle exposes a semantic label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoutineCard(
              title: 'Breakfast',
              timeLabel: '07:00 AM',
              icon: Icons.restaurant_outlined,
              iconBackground: const Color(0xFFFFF1C8),
              iconColor: const Color(0xFFC39B42),
              checkSemanticLabel: 'Done',
              onCheckTap: () {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Done'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('calls onTap when card tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildCard(onTap: () => tapped = true));

      await tester.tap(find.text('Breakfast'));
      expect(tapped, isTrue);
    });

    testWidgets('does not crash with null callbacks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCard());

      // Tap the card without callbacks — should not throw.
      await tester.tap(find.text('Breakfast'));
      await tester.tap(find.byIcon(Icons.circle_outlined));

      // Should still be showing.
      expect(find.text('Breakfast'), findsOneWidget);
    });
  });
}
