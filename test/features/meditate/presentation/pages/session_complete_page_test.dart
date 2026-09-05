import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/session_complete_page.dart';
import '../../../../support/screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScreenHarness harness;

  setUp(() {
    harness = ScreenHarness();
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('SessionCompletePage', () {
    testWidgets(
      'renders completion header, progress, mood selection, and done button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          harness.wrap(const SessionCompletePage(completedCount: 3)),
        );
        await tester.pumpAndSettle();

        // Header
        expect(find.text('Session complete'), findsOneWidget);
        expect(
          find.text('You gave yourself 7 minutes to slow down.'),
          findsOneWidget,
        );

        // Progress
        expect(find.text('3 of 5 sessions complete today'), findsOneWidget);

        // Mood selector
        expect(find.text('How do you feel?'), findsOneWidget);
        expect(find.text('Calmer'), findsOneWidget);
        expect(find.text('Same'), findsOneWidget);
        expect(find.text('Uncomfortable'), findsOneWidget);

        // Tap Calmer
        await tester.tap(find.text('Calmer'));
        await tester.pumpAndSettle();

        // Done CTA
        expect(find.text('Done'), findsOneWidget);
      },
    );

    testWidgets('renders all sessions completed today when count is 5', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness.wrap(const SessionCompletePage(completedCount: 5)),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's 5 sessions are complete"), findsOneWidget);
    });
  });
}
