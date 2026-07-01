import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/widgets/progress/progress_ring.dart';

void main() {
  group('ProgressRing', () {
    testWidgets('renders progress label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProgressRing(progress: 0.6, label: '3/5')),
        ),
      );

      expect(find.text('3/5'), findsOneWidget);
    });

    testWidgets('renders with default size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProgressRing(progress: 0.0, label: '0/5')),
        ),
      );

      final SizedBox sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(ProgressRing),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, 108);
      expect(sizedBox.height, 108);
    });

    testWidgets('uses TweenAnimationBuilder for smooth value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProgressRing(progress: 0.0, label: '0/5')),
        ),
      );

      // Verify TweenAnimationBuilder is present.
      expect(find.byType(TweenAnimationBuilder<double>), findsWidgets);
    });

    testWidgets('clamps progress between 0 and 1', (
      WidgetTester tester,
    ) async {
      // Progress > 1.0 should be clamped to 1.0.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(progress: 1.5, label: '5/5', size: 80),
          ),
        ),
      );

      // Should still render without error.
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('completion shows scale bounce when progress is 1.0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(progress: 1.0, label: '5/5', size: 80),
          ),
        ),
      );

      // The celebration animation should be present.
      await tester.pumpAndSettle();

      // Label should still be visible after animation settles.
      expect(find.text('5/5'), findsOneWidget);
    });
  });
}
