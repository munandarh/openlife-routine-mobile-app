import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/today/presentation/widgets/greeting_helper.dart';

void main() {
  group('GreetingHelper', () {
    test('morning greeting for 5am (boundary)', () {
      expect(
        greetingForHour(5),
        'Good morning',
      );
    });

    test('morning greeting for 6am', () {
      expect(
        greetingForHour(6),
        'Good morning',
      );
    });

    test('morning greeting for 11:59am', () {
      expect(
        greetingForHour(11),
        'Good morning',
      );
    });

    test('afternoon greeting for 12pm', () {
      expect(
        greetingForHour(12),
        'Good afternoon',
      );
    });

    test('afternoon greeting for 17:59pm', () {
      expect(
        greetingForHour(17),
        'Good afternoon',
      );
    });

    test('evening greeting for 18pm', () {
      expect(
        greetingForHour(18),
        'Good evening',
      );
    });

    test('evening greeting for 23:59pm', () {
      expect(
        greetingForHour(23),
        'Good evening',
      );
    });

    test('night greeting for 0am', () {
      expect(
        greetingForHour(0),
        'Good night',
      );
    });

    test('night greeting for 4:59am', () {
      expect(
        greetingForHour(4),
        'Good night',
      );
    });

    test('greetingIdiForHour returns the correct Indonesian phrase', () {
      expect(greetingIdiForHour(6), 'Selamat pagi');
      expect(greetingIdiForHour(12), 'Selamat siang');
      expect(greetingIdiForHour(18), 'Selamat sore');
      expect(greetingIdiForHour(20), 'Selamat malam');
      expect(greetingIdiForHour(0), 'Selamat malam');
    });

    test('greetingForHour accepts DateTime hour component', () {
      final DateTime morningTime = DateTime(2026, 7, 1, 9, 30);
      final DateTime nightTime = DateTime(2026, 7, 1, 2, 15);
      expect(greetingForHour(morningTime.hour), 'Good morning');
      expect(greetingForHour(nightTime.hour), 'Good night');
    });
  });
}
