import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/widgets/forms/week_date_selector.dart';

void main() {
  group('WeekDateSelector', () {
    List<WeekDateItem> buildItems() {
      const List<String> weekdays = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return List<WeekDateItem>.generate(7, (int i) {
        return WeekDateItem(weekday: weekdays[i], dayNumber: '${i + 1}');
      });
    }

    Widget buildSelector({
      int selectedIndex = 0,
      ValueChanged<int>? onSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: WeekDateSelector(
            selectedIndex: selectedIndex,
            items: buildItems(),
            onSelected: onSelected,
          ),
        ),
      );
    }

    testWidgets('renders all 7 day items', (WidgetTester tester) async {
      await tester.pumpWidget(buildSelector());

      // Each weekday letter should appear at least once.
      expect(find.text('M'), findsOneWidget);
      // 'T' appears twice (Tuesday, Thursday) — verify widget count >= 2.
      expect(find.text('T'), findsWidgets);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      // 'S' appears twice (Saturday, Sunday).
      expect(find.text('S'), findsWidgets);
    });

    testWidgets('uses AnimatedContainer for selected day', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSelector(selectedIndex: 0));

      // Verify AnimatedContainer is present for smooth pill transition.
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('calls onSelected when day tapped', (
      WidgetTester tester,
    ) async {
      int? tapped;
      await tester.pumpWidget(buildSelector(onSelected: (int i) => tapped = i));

      // Tap the third day.
      await tester.tap(find.text('3').last);
      expect(tapped, 2); // 0-based index.
    });

    testWidgets('changing selectedIndex animates the pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSelector(selectedIndex: 0));
      await tester.pumpWidget(buildSelector(selectedIndex: 3));

      // Start animation.
      await tester.pump();

      // Should complete without error.
      await tester.pumpAndSettle();
      expect(find.text('M'), findsOneWidget);
    });
  });
}
