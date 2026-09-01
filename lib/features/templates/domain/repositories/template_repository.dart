import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';

class TemplateRepository {
  const TemplateRepository();

  Future<List<RoutineTemplate>> getTemplates() async {
    return _seedTemplates;
  }
}

const List<RoutineTemplate> _seedTemplates = <RoutineTemplate>[
  RoutineTemplate(
    id: 'morning',
    title: 'Morning Routine',
    description: 'Start your day with intention and a gentle pace.',
    iconKey: 'wb_sunny',
    categoryName: 'Morning',
    routineCount: 3,
    isPrimary: true,
    badge: 'POPULAR',
    routines: <TemplateRoutineItem>[
      TemplateRoutineItem(
        titleKey: 'wakeUp',
        title: 'Wake Up',
        category: 'custom',
        reminderTime: '06:30',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'drinkWater',
        title: 'Drink Water',
        category: 'water',
        reminderTime: '07:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'breakfast',
        title: 'Breakfast',
        category: 'meal',
        reminderTime: '07:30',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
    ],
  ),
  RoutineTemplate(
    id: 'hydration',
    title: 'Hydration Tracker',
    description: 'Keep your water intake consistent throughout the day.',
    iconKey: 'water_drop',
    categoryName: 'Wellness',
    routineCount: 4,
    routines: <TemplateRoutineItem>[
      TemplateRoutineItem(
        titleKey: 'morningWater',
        title: 'Morning Water',
        category: 'water',
        reminderTime: '08:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'middayWater',
        title: 'Midday Water',
        category: 'water',
        reminderTime: '12:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'afternoonWater',
        title: 'Afternoon Water',
        category: 'water',
        reminderTime: '15:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'eveningWater',
        title: 'Evening Water',
        category: 'water',
        reminderTime: '19:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
    ],
  ),
  RoutineTemplate(
    id: 'vitamin',
    title: 'Vitamin Routine',
    description: 'Never miss a supplement with timed daily reminders.',
    iconKey: 'medication',
    categoryName: 'Supplements',
    routineCount: 2,
    routines: <TemplateRoutineItem>[
      TemplateRoutineItem(
        titleKey: 'vitaminD3',
        title: 'Vitamin D3',
        category: 'vitamin',
        reminderTime: '08:30',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'bComplex',
        title: 'B Complex',
        category: 'vitamin',
        reminderTime: '13:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
    ],
  ),
  RoutineTemplate(
    id: 'sleep',
    title: 'Sleep Routine',
    description: 'Wind down your day with a calming evening rhythm.',
    iconKey: 'bedtime',
    categoryName: 'Rest',
    routineCount: 2,
    routines: <TemplateRoutineItem>[
      TemplateRoutineItem(
        titleKey: 'reduceScreenTime',
        title: 'Reduce Screen Time',
        category: 'sleep',
        reminderTime: '21:30',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'prepareBed',
        title: 'Prepare Bed',
        category: 'sleep',
        reminderTime: '22:00',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
    ],
  ),
  RoutineTemplate(
    id: 'programmer_break',
    title: 'Programmer Break',
    description: 'Eye rest and posture resets to combat screen fatigue.',
    iconKey: 'self_improvement',
    categoryName: 'Work Breaks',
    routineCount: 3,
    badge: 'NEW',
    routines: <TemplateRoutineItem>[
      TemplateRoutineItem(
        titleKey: 'eyeRest',
        title: 'Eye Rest',
        category: 'breakTime',
        reminderTime: '10:00',
        repeatDays: <int>[1, 2, 3, 4, 5],
      ),
      TemplateRoutineItem(
        titleKey: 'stretching',
        title: 'Stretching',
        category: 'breakTime',
        reminderTime: '12:00',
        repeatDays: <int>[1, 2, 3, 4, 5],
      ),
      TemplateRoutineItem(
        titleKey: 'postureCheck',
        title: 'Posture Check',
        category: 'breakTime',
        reminderTime: '15:00',
        repeatDays: <int>[1, 2, 3, 4, 5],
      ),
    ],
  ),
];
