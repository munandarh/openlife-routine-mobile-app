import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/anxiety_breath_setup_page.dart';
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

  group('AnxietyBreathSetupPage', () {
    testWidgets(
      'renders inhale, exhale options, safety note, session duration',
      (WidgetTester tester) async {
        await tester.pumpWidget(harness.wrap(const AnxietyBreathSetupPage()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Inhale card
        expect(find.text('Inhale'), findsOneWidget);
        expect(find.text('3 sec'), findsOneWidget);
        expect(find.text('Fixed'), findsOneWidget);

        // Exhale options
        expect(find.text('7 sec'), findsOneWidget);
        expect(find.text('12 sec'), findsOneWidget);
        expect(find.text('21 sec'), findsOneWidget);

        // Safety note
        expect(
          find.textContaining('Choose only a pace that feels comfortable'),
          findsOneWidget,
        );

        // Session Duration card
        expect(find.text('Session'), findsOneWidget);
        expect(find.text('7 minutes'), findsOneWidget);

        // CTAs
        expect(find.text('Start breathing'), findsOneWidget);
        expect(
          find.text('You can end the session at any time.'),
          findsOneWidget,
        );

        // Tap 12s exhale option
        await tester.tap(find.text('12 sec'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Tap 21s exhale option
        await tester.tap(find.text('21 sec'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
      },
    );
  });
}
