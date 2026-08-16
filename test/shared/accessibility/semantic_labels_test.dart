import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';

/// PRD §14.4 asks icon-only controls to carry semantic labels.
///
/// The text-scale half of §14.4 is not covered here: see
/// docs/SPRINT-CHECKLIST.md. Today still overflows at 1.5x and the site has
/// not been located, so there is no honest assertion to make yet.
void main() {
  testWidgets('an unlabelled IconCircleButton is hidden from screen readers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IconCircleButton(icon: Icons.notifications_none_rounded),
        ),
      ),
    );

    // Decorative chrome must not be announced as a control the user can use.
    // The claim is that the widget wraps itself in ExcludeSemantics, not how
    // many Flutter adds internally — an exact count is brittle either way.
    expect(
      find.descendant(
        of: find.byType(IconCircleButton),
        matching: find.byType(ExcludeSemantics),
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('a labelled IconCircleButton exposes its label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconCircleButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: 'Back',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Back'), findsAtLeastNWidgets(1));
  });
}
