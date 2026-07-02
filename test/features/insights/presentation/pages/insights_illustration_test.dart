import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

void main() {
  group('Insights hero illustration', () {
    testWidgets('insights page hero asset is registered and loadable', (
    WidgetTester tester,
    ) async {
      // The insights page should expose a hero illustration backed by
      // today_insights_workspace.png. We verify the registry and the
      // wrapper rendering here.
      final AssetVectorEntry entry = AssetVectors.todayInsightsWorkspace;

      expect(entry.path, 'assets/vector/today_insights_workspace.png');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OpenLifeRiveView.illustration(
              illustrationPath: entry.path,
              fallbackIcon: Icons.insights_outlined,
              size: 220,
            ),
          ),
        ),
      );

      await tester.pump();
      // The Image widget is rendered.
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
