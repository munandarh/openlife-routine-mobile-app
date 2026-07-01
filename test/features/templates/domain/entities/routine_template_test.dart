import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';

void main() {
  group('RoutineTemplate', () {
    test('creates with required fields', () {
      const RoutineTemplate template = RoutineTemplate(
        id: 'morning',
        title: 'Morning Routine',
        description: 'Start your day right.',
        iconKey: 'wb_sunny',
        categoryName: 'Morning',
        routineCount: 3,
        isPrimary: true,
      );

      expect(template.id, 'morning');
      expect(template.title, 'Morning Routine');
      expect(template.description, 'Start your day right.');
      expect(template.iconKey, 'wb_sunny');
      expect(template.categoryName, 'Morning');
      expect(template.routineCount, 3);
      expect(template.isPrimary, true);
    });

    test('Equatable supports value equality', () {
      const RoutineTemplate a = RoutineTemplate(
        id: 'a',
        title: 'A',
        description: 'desc',
        iconKey: 'icon',
        categoryName: 'cat',
        routineCount: 2,
        isPrimary: false,
      );
      const RoutineTemplate b = RoutineTemplate(
        id: 'a',
        title: 'A',
        description: 'desc',
        iconKey: 'icon',
        categoryName: 'cat',
        routineCount: 2,
        isPrimary: false,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('TemplateRoutineItem', () {
    test('creates with all fields', () {
      const TemplateRoutineItem item = TemplateRoutineItem(
        title: 'Drink Water',
        category: 'water',
        reminderTime: '08:00',
        repeatDays: <int>[1, 2, 3, 4, 5],
        snoozeMinutes: 10,
      );

      expect(item.title, 'Drink Water');
      expect(item.category, 'water');
      expect(item.reminderTime, '08:00');
      expect(item.repeatDays, <int>[1, 2, 3, 4, 5]);
      expect(item.snoozeMinutes, 10);
    });

    test('equality works for identical items', () {
      const TemplateRoutineItem a = TemplateRoutineItem(
        title: 'Meditate',
        category: 'custom',
        reminderTime: '06:30',
        repeatDays: <int>[1, 3, 5],
      );
      const TemplateRoutineItem b = TemplateRoutineItem(
        title: 'Meditate',
        category: 'custom',
        reminderTime: '06:30',
        repeatDays: <int>[1, 3, 5],
      );

      expect(a, b);
    });
  });
}
