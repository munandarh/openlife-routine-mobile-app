import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

void main() {
  group('Notification bell illustration', () {
    testWidgets('OpenLifeRiveView.illustration renders bell asset', (
    WidgetTester tester,
    ) async {
      final AssetVectorEntry entry = AssetVectors.todayNotificationBell;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: entry.path,
              fallbackIcon: Icons.notifications_active_outlined,
              size: 80,
            ),
          ),
        ),
      );

      await tester.pump();
      // Image widget rendered with the bell asset.
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('Insights workspace illustration', () {
    testWidgets('OpenLifeRiveView.illustration renders insights asset', (
    WidgetTester tester,
    ) async {
      final AssetVectorEntry entry = AssetVectors.todayInsightsWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: entry.path,
              fallbackIcon: Icons.insights_outlined,
              size: 200,
            ),
          ),
        ),
      );

      await tester.pump();
      // Image widget rendered with the insights asset.
      expect(find.byType(Image), findsOneWidget);
      // The Image is sized correctly.
      final Finder imageFinder = find.descendant(
        of: find.byType(OpenLifeRiveView),
        matching: find.byType(Image),
      );
      final Image image = tester.widget<Image>(imageFinder);
      expect(image.fit, BoxFit.contain);
    });
  });

  group('Illustration registry coverage', () {
    test('all MVP vector assets are present and non-empty', () {
      final List<AssetVectorEntry> mvpAssets = <AssetVectorEntry>[
        AssetVectors.onboardingBuildBetterDays,
        AssetVectors.onboardingSmartRoutines,
        AssetVectors.onboardingPrivateByDefault,
        AssetVectors.onboardingStarterTemplate,
        AssetVectors.todayNotificationBell,
        AssetVectors.todaySleepRoutine,
        AssetVectors.todayWaterHydration,
        AssetVectors.todayVitaminRoutine,
        AssetVectors.todayDailyCelebration,
        AssetVectors.todayInsightsWorkspace,
      ];

      expect(mvpAssets.length, 10);
      for (final AssetVectorEntry entry in mvpAssets) {
        expect(entry.name, isNotEmpty);
        expect(entry.path, isNotEmpty);
        expect(entry.path, startsWith('assets/vector/'));
        expect(entry.path, endsWith('.png'));
      }
    });
  });
}
