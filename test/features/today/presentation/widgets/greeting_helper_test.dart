import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/today/presentation/widgets/greeting_helper.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

import '../../../../support/localized_app.dart';

void main() {
  group('greetingSlotForHour (English boundaries)', () {
    test('5am starts the morning slot', () {
      expect(greetingSlotForHour(5), GreetingSlot.morning);
    });

    test('11am is still morning', () {
      expect(greetingSlotForHour(11), GreetingSlot.morning);
    });

    test('12pm switches to afternoon', () {
      expect(greetingSlotForHour(12), GreetingSlot.afternoon);
    });

    test('17:00 is still afternoon', () {
      expect(greetingSlotForHour(17), GreetingSlot.afternoon);
    });

    test('18:00 switches to evening', () {
      expect(greetingSlotForHour(18), GreetingSlot.evening);
    });

    test('23:00 is still evening', () {
      expect(greetingSlotForHour(23), GreetingSlot.evening);
    });

    test('midnight through 4am is night', () {
      expect(greetingSlotForHour(0), GreetingSlot.night);
      expect(greetingSlotForHour(4), GreetingSlot.night);
    });
  });

  group('greetingSlotIdForHour (Indonesian boundaries)', () {
    test('splits the afternoon into siang and sore', () {
      expect(greetingSlotIdForHour(12), GreetingSlot.afternoon);
      expect(greetingSlotIdForHour(14), GreetingSlot.afternoon);
      expect(greetingSlotIdForHour(15), GreetingSlot.evening);
      expect(greetingSlotIdForHour(18), GreetingSlot.evening);
      expect(greetingSlotIdForHour(19), GreetingSlot.night);
    });

    test('shares the morning boundary with English', () {
      expect(greetingSlotIdForHour(6), GreetingSlot.morning);
      expect(greetingSlotIdForHour(0), GreetingSlot.night);
    });
  });

  group('greetingSlotFor', () {
    test('picks Indonesian boundaries only for the id locale', () {
      // 16:00 is "sore" in Indonesian but still "afternoon" in English.
      expect(greetingSlotFor(16, 'id'), GreetingSlot.evening);
      expect(greetingSlotFor(16, 'en'), GreetingSlot.afternoon);
    });

    test('falls back to English boundaries for unknown languages', () {
      expect(greetingSlotFor(16, 'fr'), GreetingSlot.afternoon);
    });
  });

  group('greetingLabel', () {
    test('resolves every slot in English', () async {
      final AppLocalizations l10n = await l10nFor();

      expect(greetingLabel(l10n, GreetingSlot.morning), 'Good morning');
      expect(greetingLabel(l10n, GreetingSlot.afternoon), 'Good afternoon');
      expect(greetingLabel(l10n, GreetingSlot.evening), 'Good evening');
      expect(greetingLabel(l10n, GreetingSlot.night), 'Good night');
    });

    test('resolves every slot in Indonesian', () async {
      final AppLocalizations l10n = await l10nFor(const Locale('id'));

      expect(greetingLabel(l10n, GreetingSlot.morning), 'Selamat pagi');
      expect(greetingLabel(l10n, GreetingSlot.afternoon), 'Selamat siang');
      expect(greetingLabel(l10n, GreetingSlot.evening), 'Selamat sore');
      expect(greetingLabel(l10n, GreetingSlot.night), 'Selamat malam');
    });
  });

  group('greetingForContext', () {
    testWidgets('reads the greeting from the active locale', (
      WidgetTester tester,
    ) async {
      late String english;
      late String indonesian;

      await tester.pumpWidget(
        localizedApp(
          Builder(
            builder: (BuildContext context) {
              english = greetingForContext(context, 9);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpWidget(
        localizedApp(
          Builder(
            builder: (BuildContext context) {
              indonesian = greetingForContext(context, 9);
              return const SizedBox.shrink();
            },
          ),
          locale: const Locale('id'),
        ),
      );

      expect(english, 'Good morning');
      expect(indonesian, 'Selamat pagi');
    });
  });
}
