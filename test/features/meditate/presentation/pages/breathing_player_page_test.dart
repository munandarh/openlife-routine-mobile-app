import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/breathing_player_page.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/breathing_orb.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/end_session_dialog.dart';
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

  group('BreathingPlayerPage', () {
    testWidgets(
      'renders player, orb, pause/resume, and end session confirmation dialog',
      (WidgetTester tester) async {
        useScreenWidth(tester, 411);
        await tester.pumpWidget(
          harness.wrap(const BreathingPlayerPage(exhaleSeconds: 7)),
        );
        await tester.pump();

        // Title and breathing orb
        expect(find.text('Anxiety Breath'), findsOneWidget);
        expect(find.byType(BreathingOrb), findsOneWidget);

        // Pause button exists
        expect(find.text('Pause'), findsOneWidget);
        expect(find.text('End session'), findsOneWidget);

        // Tap Pause
        await tester.ensureVisible(find.text('Pause'));
        await tester.tap(find.text('Pause'));
        await tester.pump();

        // Button changes to Resume
        expect(find.text('Resume'), findsOneWidget);

        // Tap Resume
        await tester.tap(find.text('Resume'));
        await tester.pump();
        expect(find.text('Pause'), findsOneWidget);

        // Tap End session button
        await tester.ensureVisible(find.text('End session'));
        await tester.tap(find.text('End session'));
        await tester.pumpAndSettle();

        // Dialog appears
        expect(find.byType(EndSessionDialog), findsOneWidget);
        expect(find.text('Keep breathing'), findsOneWidget);

        // Tap Keep breathing dismisses dialog
        await tester.tap(find.text('Keep breathing'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(EndSessionDialog), findsNothing);
      },
    );
  });
}
