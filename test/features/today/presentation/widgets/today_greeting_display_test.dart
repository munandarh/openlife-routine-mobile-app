import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/today/presentation/widgets/today_greeting.dart';

import '../../../../support/localized_app.dart';

void main() {
  group('TodayGreeting display tests', () {
    testWidgets('renders the greeting text', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 9))),
      );

      expect(find.text('Good morning'), findsOneWidget);
    });

    testWidgets('subtitle is hidden when null', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 9))),
      );

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('subtitle is hidden when empty string', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: TodayGreeting(hour: 9, subtitle: '')),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('subtitle is rendered when non-empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: TodayGreeting(hour: 9, subtitle: 'Keep it up!')),
        ),
      );

      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('Keep it up!'), findsOneWidget);
    });

    testWidgets('hour = 18 renders evening', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 18))),
      );

      expect(find.text('Good evening'), findsOneWidget);
    });

    testWidgets('hour = 23 renders evening', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 23))),
      );

      expect(find.text('Good evening'), findsOneWidget);
    });

    testWidgets('hour = 0 renders night', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 0))),
      );

      expect(find.text('Good night'), findsOneWidget);
    });

    testWidgets('Indonesian locale + hour=20 renders Selamat malam', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: TodayGreeting(hour: 20)),
          locale: const Locale('id'),
        ),
      );

      expect(find.text('Selamat malam'), findsOneWidget);
    });

    testWidgets('greeting text style is non-null', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(const Scaffold(body: TodayGreeting(hour: 9))),
      );

      final Text textWidget = tester.widget<Text>(find.text('Good morning'));
      expect(textWidget.style, isNotNull);
    });

    test('AppTextStyles.fontFamily is Nunito', () {
      expect(AppTextStyles.fontFamily, 'Nunito');
    });
  });
}
