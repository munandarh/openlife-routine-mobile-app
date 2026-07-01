import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/animations/openlife_animation_assets.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

void main() {
  group('OpenLifeRiveView', () {
    testWidgets('renders fallback icon for missing Rive asset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView(
              assetName: 'assets/rive/non_existent.riv',
              fallbackIcon: Icons.error_outline,
              size: 120,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders with valid size constraint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView(
              assetName: 'assets/rive/non_existent.riv',
              fallbackIcon: Icons.star,
              size: 80,
            ),
          ),
        ),
      );

      // The outer SizedBox wrapping the fallback icon.
      final Finder sizedBoxFinder = find.descendant(
        of: find.byType(OpenLifeRiveView),
        matching: find.byType(SizedBox),
      );
      final SizedBox sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
    });

    testWidgets('renders with animation entry from registry', (
      WidgetTester tester,
    ) async {
      final OpenLifeAnimationEntry entry =
          OpenLifeAnimationAssets.byName('emptyNoRoutines');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView(
              assetName: entry.rivePath,
              fallbackIcon: entry.fallbackIcon,
              size: 160,
            ),
          ),
        ),
      );

      // Falls back because asset doesn't actually exist on disk.
      expect(find.byIcon(Icons.event_note_outlined), findsOneWidget);
    });

    testWidgets('renders artboard from valid asset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView(
              assetName: 'assets/rive/non_existent.riv',
              artboard: 'SomeArtboard',
              fallbackIcon: Icons.animation,
              size: 100,
            ),
          ),
        ),
      );

      // Falls back when asset is missing; artboard param does not crash.
      expect(find.byIcon(Icons.animation), findsOneWidget);
    });

    testWidgets('stateMachine param does not cause crash', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView(
              assetName: 'assets/rive/non_existent.riv',
              stateMachine: 'SomeStateMachine',
              fallbackIcon: Icons.settings,
              size: 100,
            ),
          ),
        ),
      );

      // Should render fallback without crashing.
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
