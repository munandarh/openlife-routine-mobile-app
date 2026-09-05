import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_practice.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/anxiety_breath_setup_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/breathing_player_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/meditation_library_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/session_complete_page.dart';
import '../../support/screen_harness.dart';

void main() {
  for (final locale in [const Locale('en'), const Locale('id')]) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      final screens = <String, Widget>{
        'breathing setup': const AnxietyBreathSetupPage(),
        'breathing player': const BreathingPlayerPage(exhaleSeconds: 21),
        'meditation setup': MeditationSetupPage(
          practice: MeditationPractice.byId('sleep'),
        ),
        'meditation player': BreathingPlayerPage(
          exhaleSeconds: 7,
          practice: MeditationPractice.byId('focus'),
        ),
        'completion': const SessionCompletePage(completedCount: 6),
      };
      for (final entry in screens.entries) {
        testWidgets(
          '${entry.key}: 320dp, 200% text, ${locale.languageCode}, $brightness, reduced motion',
          (tester) async {
            final harness = ScreenHarness();
            addTearDown(harness.dispose);
            useScreenWidth(tester, 320);
            await tester.pumpWidget(
              harness.wrap(
                MediaQuery(
                  data: const MediaQueryData(
                    size: Size(320, 800),
                    textScaler: TextScaler.linear(2),
                    disableAnimations: true,
                  ),
                  child: entry.value,
                ),
                locale: locale,
                brightness: brightness,
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 700));
            expect(tester.takeException(), isNull);
            for (var i = 0; i < 5; i++) {
              final scroll = find.byType(Scrollable);
              if (scroll.evaluate().isNotEmpty) {
                await tester.drag(scroll.first, const Offset(0, -300));
              }
              await tester.pump();
              expect(tester.takeException(), isNull);
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
          },
        );
      }
    }
  }
}
