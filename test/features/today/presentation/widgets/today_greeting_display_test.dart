import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/today/presentation/widgets/today_greeting.dart';

void main() {
  group('TodayGreeting display tests', () {
    testWidgets('renders the greeting text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9),
          ),
        ),
      );

      expect(find.text('Good morning'), findsOneWidget);
    });

    testWidgets('subtitle is hidden when null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9),
          ),
        ),
      );

      // Only one Text widget: the greeting.
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('subtitle is hidden when empty string', (
    WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9, subtitle: ''),
          ),
        ),
      );

      // Empty subtitle is not rendered.
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('subtitle is rendered when non-empty', (
    WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9, subtitle: 'Keep it up!'),
          ),
        ),
      );

      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('Keep it up!'), findsOneWidget);
    });

    testWidgets('hour = 18 renders evening', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 18),
          ),
        ),
      );

      expect(find.text('Good evening'), findsOneWidget);
    });

    testWidgets('hour = 23 renders evening', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 23),
          ),
        ),
      );

      expect(find.text('Good evening'), findsOneWidget);
    });

    testWidgets('hour = 0 renders night', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 0),
          ),
        ),
      );

      expect(find.text('Good night'), findsOneWidget);
    });

    testWidgets('Indonesian + hour=20 renders Selamat malam', (
    WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 20, useIndonesian: true),
          ),
        ),
      );

      expect(find.text('Selamat malam'), findsOneWidget);
    });

    testWidgets('greeting text style is non-null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayGreeting(hour: 9),
          ),
        ),
      );

      final Text textWidget = tester.widget<Text>(find.text('Good morning'));
      expect(textWidget.style, isNotNull);
    });

    testWidgets('AppTextStyles.fontFamily is Plus Jakarta Sans', (
    WidgetTester tester,
    ) async {
      // Smoke test that the font family constant is correct.
      expect(AppTextStyles.fontFamily, 'Plus Jakarta Sans');
    });
  });
}
