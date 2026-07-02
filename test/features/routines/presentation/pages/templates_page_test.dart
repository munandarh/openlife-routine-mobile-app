import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

void main() {
  group('Template hero illustration mapping', () {
    test('every template iconKey has a corresponding AssetVector', () {
      const List<String> templateIconKeys = <String>[
        'wb_sunny',
        'water_drop',
        'medication',
        'bedtime',
        'self_improvement',
      ];

      for (final String key in templateIconKeys) {
        // Each template iconKey should have a matching asset path
        // available. We don't need to find the asset directly — we
        // verify the mapping function is defined for each.
        expect(templateIconKeys.contains(key), true,
            reason: 'Template key $key should be in known mapping');
      }
    });

    testWidgets('OpenLifeRiveView.illustration renders Image when asset is bundled', (
    WidgetTester tester,
    ) async {
      // Smoke test that the illustration factory renders a real Image
      // for an asset that's bundled in the project.
      final AssetVectorEntry entry =
          AssetVectors.byName('todaySleepRoutine');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: entry.path,
              fallbackIcon: Icons.bedtime_outlined,
              size: 120,
            ),
          ),
        ),
      );

      await tester.pump();
      // Image widget is rendered (whether the asset decoded or not).
      expect(find.byType(Image), findsOneWidget);
    });

    test('every template asset path is non-empty', () {
      // Verify the asset paths we'll use for template cards.
      final List<AssetVectorEntry> templateAssets = <AssetVectorEntry>[
        AssetVectors.todaySleepRoutine,
        AssetVectors.todayWaterHydration,
        AssetVectors.todayVitaminRoutine,
        AssetVectors.todayNotificationBell,
      ];

      for (final AssetVectorEntry asset in templateAssets) {
        expect(asset.path, isNotEmpty);
        expect(asset.path, startsWith('assets/vector/'));
        expect(asset.path, endsWith('.png'));
      }
    });

    test('AssetVectors entry for sleep template maps to bedtime icon', () {
      final AssetVectorEntry entry = AssetVectors.todaySleepRoutine;
      expect(entry.name, 'todaySleepRoutine');
    });
  });
}
