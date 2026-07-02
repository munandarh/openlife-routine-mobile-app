import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';

void main() {
  group('Routine entity with notes', () {
    test('notes field defaults to null', () {
      final Routine routine = Routine(
        id: 'r1',
        title: 'Breakfast',
        category: RoutineCategory.meal,
        reminderTime: '07:00',
        repeatDays: <int>[1, 2, 3, 4, 5],
        isEnabled: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(routine.notes, isNull);
    });

    test('notes field can be set', () {
      final Routine routine = Routine(
        id: 'r2',
        title: 'Vitamin D3',
        category: RoutineCategory.vitamin,
        reminderTime: '08:30',
        repeatDays: <int>[1, 3, 5],
        isEnabled: true,
        notes: 'Take with food for better absorption',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(routine.notes, 'Take with food for better absorption');
    });

    test('notes field is included in copyWith', () {
      final Routine original = Routine(
        id: 'r1',
        title: 'Drink Water',
        category: RoutineCategory.water,
        reminderTime: '10:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final Routine updated = original.copyWith(
        notes: 'Hydration is key',
      );

      expect(updated.notes, 'Hydration is key');
      expect(updated.title, 'Drink Water');
    });

    test('notes field is in equality check', () {
      final Routine a = Routine(
        id: 'r1',
        title: 'Meditate',
        category: RoutineCategory.custom,
        reminderTime: '06:00',
        repeatDays: <int>[1, 3, 5],
        isEnabled: true,
        notes: 'Focus on breathing',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final Routine b = Routine(
        id: 'r1',
        title: 'Meditate',
        category: RoutineCategory.custom,
        reminderTime: '06:00',
        repeatDays: <int>[1, 3, 5],
        isEnabled: true,
        notes: 'Focus on breathing',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final Routine c = Routine(
        id: 'r1',
        title: 'Meditate',
        category: RoutineCategory.custom,
        reminderTime: '06:00',
        repeatDays: <int>[1, 3, 5],
        isEnabled: true,
        notes: 'Different note',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
