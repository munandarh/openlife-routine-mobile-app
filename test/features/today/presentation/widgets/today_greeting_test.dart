import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/today/presentation/widgets/today_greeting.dart';

import '../../../../support/localized_app.dart';

void main() {
  group('TodayGreeting', () {
    testWidgets('renders the greeting text for the given hour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 9))),
      );

      expect(find.text('Good morning'), findsOneWidget);
    });

    testWidgets('renders greeting for afternoon', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 14))),
      );

      expect(find.text('Good afternoon'), findsOneWidget);
    });

    testWidgets('follows the app locale without an explicit flag', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: TodayGreeting(hour: 9)),
          locale: const Locale('id'),
        ),
      );

      expect(find.text('Selamat pagi'), findsOneWidget);
    });

    testWidgets('derives the hour from the clock when none is given', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting())),
      );

      final List<String?> texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();

      expect(
        texts.any(
          (String? t) => <String>[
            'Good morning',
            'Good afternoon',
            'Good evening',
            'Good night',
          ].contains(t),
        ),
        isTrue,
      );
    });

    testWidgets('uses a consistent style for greeting text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 9))),
      );

      final Text greetingText = tester.widget<Text>(find.text('Good morning'));
      expect(greetingText.style, isNotNull);
    });

    testWidgets('renders an optional subtitle when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(
            body: TodayGreeting(
              hour: 9,
              subtitle: 'You are doing well today',
            ),
          ),
        ),
      );

      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('You are doing well today'), findsOneWidget);
    });
  });

  group('AppTextStyles', () {
    test('font family is Plus Jakarta Sans', () {
      expect(AppTextStyles.fontFamily, 'Plus Jakarta Sans');
    });
  });
}
