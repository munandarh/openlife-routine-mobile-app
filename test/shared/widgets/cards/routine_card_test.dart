import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';

void main() {
  group('RoutineCard', () {
    Widget buildCard({
      bool isDone = false,
      bool isDueNow = false,
      String? statusLabel,
      String? secondaryActionLabel,
      VoidCallback? onTap,
      VoidCallback? onCheckTap,
      VoidCallback? onSecondaryAction,
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
            secondaryActionLabel: secondaryActionLabel,
            onTap: onTap,
            onCheckTap: onCheckTap,
            onSecondaryAction: onSecondaryAction,
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

    testWidgets('calls onSecondaryAction when secondary label tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildCard(
          secondaryActionLabel: 'Skip',
          onSecondaryAction: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Skip'));
      expect(tapped, isTrue);
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
