import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';

void main() {
  group('AppEmptyState', () {
    testWidgets('renders title and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No routines yet',
              description: 'Create your first routine.',
              buttonLabel: 'Get Started',
              icon: Icons.event_note_outlined,
            ),
          ),
        ),
      );

      expect(find.text('No routines yet'), findsOneWidget);
      expect(find.text('Create your first routine.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('renders icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Empty',
              description: 'Nothing here.',
              buttonLabel: 'Add',
              icon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('calls onPressed when button tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Empty',
              description: 'Nothing.',
              buttonLabel: 'Go',
              icon: Icons.add,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      expect(tapped, isTrue);
    });

    testWidgets('does not crash without onPressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Empty',
              description: 'Nothing.',
              buttonLabel: 'Go',
              icon: Icons.add,
            ),
          ),
        ),
      );

      // Should not throw when tapping button without callback.
      await tester.tap(find.text('Go'));
      expect(find.text('Empty'), findsOneWidget);
    });
  });
}
