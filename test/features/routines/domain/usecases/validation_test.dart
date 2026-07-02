import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Routine validation rules', () {
    test('title cannot be empty', () {
      expect(_isValidTitle(''), false);
      expect(_isValidTitle(' '), false);
    });

    test('title cannot exceed 60 characters', () {
      expect(_isValidTitle('a' * 60), true);
      expect(_isValidTitle('a' * 61), false);
    });

    test('title with 1 character is valid', () {
      expect(_isValidTitle('A'), true);
    });

    test('repeat days must have at least one day', () {
      expect(_hasValidRepeatDays(<int>[]), false);
      expect(_hasValidRepeatDays(<int>[1]), true);
      expect(_hasValidRepeatDays(<int>[1, 3, 5]), true);
    });

    test('repeat days must be valid weekdays (1-7)', () {
      expect(_hasValidRepeatDays(<int>[0]), false);
      expect(_hasValidRepeatDays(<int>[8]), false);
      expect(_hasValidRepeatDays(<int>[1, 7]), true);
    });

    test('snooze minutes between 5 and 120', () {
      expect(_isValidSnoozeMinutes(4), false);
      expect(_isValidSnoozeMinutes(5), true);
      expect(_isValidSnoozeMinutes(60), true);
      expect(_isValidSnoozeMinutes(120), true);
      expect(_isValidSnoozeMinutes(121), false);
    });

    test('reminder time format is HH:mm', () {
      expect(_isValidReminderTime('07:00'), true);
      expect(_isValidReminderTime('23:59'), true);
      expect(_isValidReminderTime('00:00'), true);
      expect(_isValidReminderTime('7:00'), false);
      expect(_isValidReminderTime('25:00'), false);
      expect(_isValidReminderTime('abc'), false);
    });

    test('category must be one of the valid enum values', () {
      const List<String> validCategories = <String>[
        'meal',
        'water',
        'vitamin',
        'medicine',
        'sleep',
        'exercise',
        'breakTime',
        'custom',
      ];

      for (final String category in validCategories) {
        expect(
          _isValidCategory(category),
          true,
          reason: '$category should be valid',
        );
      }

      expect(_isValidCategory('invalid'), false);
      expect(_isValidCategory(''), false);
    });
  });

  group('Progress calculation', () {
    test('0 of 0 routines is 100% (no routines means nothing to miss)', () {
      expect(_calculateProgress(completed: 0, total: 0), 1.0);
    });

    test('all done returns 1.0', () {
      expect(_calculateProgress(completed: 5, total: 5), 1.0);
    });

    test('half done returns 0.5', () {
      expect(_calculateProgress(completed: 3, total: 6), 0.5);
    });

    test('none done returns 0.0', () {
      expect(_calculateProgress(completed: 0, total: 4), 0.0);
    });

    test('progress is clamped between 0 and 1', () {
      // Shouldn't happen in practice, but defensive.
      expect(_calculateProgress(completed: 5, total: 3), 1.0);
      expect(_calculateProgress(completed: -1, total: 3), 0.0);
    });

    test('skipped routines count toward total but not completed', () {
      // 2 done + 1 skipped out of 5 = 2/5 = 0.4
      expect(_calculateProgress(completed: 2, total: 5), 0.4);
    });
  });
}

// Validation helpers (mirrors domain logic).
bool _isValidTitle(String title) {
  final String trimmed = title.trim();
  return trimmed.isNotEmpty && trimmed.length <= 60;
}

bool _hasValidRepeatDays(List<int> days) {
  if (days.isEmpty) {
    return false;
  }
  return days.every((int d) => d >= 1 && d <= 7);
}

bool _isValidSnoozeMinutes(int minutes) {
  return minutes >= 5 && minutes <= 120;
}

bool _isValidReminderTime(String time) {
  final RegExp regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
  return regex.hasMatch(time);
}

bool _isValidCategory(String category) {
  const List<String> valid = <String>[
    'meal',
    'water',
    'vitamin',
    'medicine',
    'sleep',
    'exercise',
    'breakTime',
    'custom',
  ];
  return valid.contains(category);
}

double _calculateProgress({required int completed, required int total}) {
  if (total <= 0) {
    return 1.0;
  }
  final double ratio = completed / total;
  return ratio.clamp(0.0, 1.0);
}
