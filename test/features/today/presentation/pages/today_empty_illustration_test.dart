import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

void main() {
  group('Today empty hero illustration', () {
    testWidgets('today empty page renders bell illustration', (
    WidgetTester tester,
    ) async {
      // The today empty page wraps an AppEmptyState. Verify the
      // bell asset is rendered instead of the icon-only fallback.
      final AssetVectorEntry entry = AssetVectors.todayNotificationBell;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: AppEmptyState(
                title: 'Nothing scheduled today',
                description: 'Add a routine.',
                buttonLabel: 'Create',
                icon: Icons.event_note_outlined,
                illustrationPath: entry.path,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();
      // The icon should not be present when illustration is loaded.
      expect(find.byIcon(Icons.event_note_outlined), findsNothing);
    });
  });

  testWidgets('AppEmptyState accepts illustrationPath', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            title: 'Empty',
            description: 'Nothing here',
            buttonLabel: 'Go',
            icon: Icons.star,
            illustrationPath: 'assets/vector/today_notification_bell.png',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();
    // The AppEmptyState uses the illustration instead of the icon.
    expect(find.byType(OpenLifeRiveView), findsOneWidget);
  });
}
