import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_practice.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/breathing_player_page.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/meditation_library_page.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/breathing_orb.dart';
import '../../support/screen_harness.dart';

void main() {
  for (final p in MeditationPractice.all) {
    testWidgets('${p.id} starts its own guided player, not Anxiety Breath', (
      tester,
    ) async {
      final harness = ScreenHarness();
      addTearDown(harness.dispose);
      useScreenWidth(tester, 411);
      await tester.pumpWidget(harness.wrap(MeditationSetupPage(practice: p)));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.scrollUntilVisible(
        find.text('Begin practice'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Begin practice'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(BreathingPlayerPage), findsOneWidget);
      expect(find.byType(BreathingOrb), findsNothing);
      expect(find.text(p.titleEn), findsOneWidget);
      expect(find.text(p.promptsEn.first), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
  for (final minutes in [3, 5, 10, 15]) {
    testWidgets('quick timer retains $minutes minute selection', (
      tester,
    ) async {
      final harness = ScreenHarness();
      addTearDown(harness.dispose);
      useScreenWidth(tester, 411);
      await tester.pumpWidget(
        harness.wrap(
          MeditationSetupPage(
            practice: MeditationPractice.byId('timer'),
            minutes: minutes,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      final selected = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '$minutes min'),
      );
      expect(selected.selected, true);
      await tester.scrollUntilVisible(
        find.text('Begin practice'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Begin practice'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(
        tester
            .widget<BreathingPlayerPage>(find.byType(BreathingPlayerPage))
            .durationMinutes,
        minutes,
      );
      expect(
        find.text('${minutes.toString().padLeft(2, '0')}:00'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
}
