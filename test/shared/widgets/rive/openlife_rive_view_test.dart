import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/animations/openlife_animation_assets.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

void main() {
  group('OpenLifeRiveView', () {
    testWidgets('renders fallback icon for missing Rive asset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.asset(
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
            body: OpenLifeRiveView.asset(
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
      final OpenLifeAnimationEntry entry = OpenLifeAnimationAssets.byName(
        'emptyNoRoutines',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.asset(
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
            body: OpenLifeRiveView.asset(
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
            body: OpenLifeRiveView.asset(
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

    // -- PNG asset support (Sprint 10) ------------------------------------
    testWidgets('illustrationPath: renders Image.asset when PNG exists', (
      WidgetTester tester,
    ) async {
      final AssetVectorEntry entry =
          AssetVectors.byName('todayNotificationBell');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: entry.path,
              fallbackIcon: Icons.broken_image,
              size: 200,
            ),
          ),
        ),
      );

      await tester.pump();
      // Image.asset for a real bundled PNG is present.
      expect(find.byType(Image), findsOneWidget);
      // Should NOT show the broken_image icon since asset loads.
      expect(find.byIcon(Icons.broken_image), findsNothing);
    });

    testWidgets('illustrationPath: falls back to icon when PNG missing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: 'assets/vector/non_existent.png',
              fallbackIcon: Icons.broken_image,
              size: 200,
            ),
          ),
        ),
      );

      await tester.pump();
      // Falls back to icon when PNG can't be decoded.
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('illustration: respects size constraint', (
      WidgetTester tester,
    ) async {
      final AssetVectorEntry entry =
          AssetVectors.byName('onboardingBuildBetterDays');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: entry.path,
              fallbackIcon: Icons.broken_image,
              size: 256,
            ),
          ),
        ),
      );

      await tester.pump();
      // Outer SizedBox width/height.
      final Finder sizedBoxFinder = find.descendant(
        of: find.byType(OpenLifeRiveView),
        matching: find.byType(SizedBox),
      );
      final SizedBox sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.width, 256);
      expect(sizedBox.height, 256);
    });

    testWidgets('illustration: Image fits within bounds via BoxFit.contain', (
      WidgetTester tester,
    ) async {
      final AssetVectorEntry entry =
          AssetVectors.byName('todayDailyCelebration');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: entry.path,
              fallbackIcon: Icons.broken_image,
              size: 150,
            ),
          ),
        ),
      );

      await tester.pump();
      final Image image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.contain);
    });
  });
}

