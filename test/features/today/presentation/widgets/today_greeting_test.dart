import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/today/presentation/widgets/greeting_helper.dart';
import 'package:openlife_routine/features/today/presentation/widgets/today_greeting.dart';

void main() {
  group('TodayGreeting', () {
    testWidgets('renders the greeting text for the given hour', (
    WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9),
          ),
        ),
      );

      expect(find.text('Good morning'), findsOneWidget);
    });

    testWidgets('renders greeting for afternoon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 14),
          ),
        ),
      );

      expect(find.text('Good afternoon'), findsOneWidget);
    });

    testWidgets('renders localized greeting for Indonesian', (
    WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9, useIndonesian: true),
          ),
        ),
      );

      expect(find.text('Selamat pagi'), findsOneWidget);
    });

    testWidgets('uses greetingForHour default if no hour provided', (
    WidgetTester tester,
    ) async {
      // Without an hour, the widget derives hour from DateTime.now().
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayGreeting(),
          ),
        ),
      );

      // Should be one of the 4 English greetings.
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .toList();
      expect(
        texts.any(
          (t) =>
              t == 'Good morning' ||
              t == 'Good afternoon' ||
              t == 'Good evening' ||
              t == 'Good night',
        ),
        true,
      );
    });

    testWidgets('greetingForHour utility: hour 5 is morning, 4 is night', (
    WidgetTester tester,
    ) async {
      // Verify boundary semantics directly via the helper.
      expect(greetingForHour(5), 'Good morning');
      expect(greetingForHour(4), 'Good night');
    });

    testWidgets('uses a consistent style for greeting text', (
    WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9),
          ),
        ),
      );

      final Text greetingText = tester.widget<Text>(find.text('Good morning'));
      // The text must have a non-null style (it uses a theme-derived style).
      expect(greetingText.style, isNotNull);
    });

    testWidgets('renders an optional subtitle when provided', (
    WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
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
