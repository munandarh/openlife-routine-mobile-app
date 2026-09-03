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
        reminderTimes: <String>['06:30'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'drinkWater',
        title: 'Drink Water',
        category: 'water',
        reminderTimes: <String>['07:00'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'breakfast',
        title: 'Breakfast',
        category: 'meal',
        reminderTimes: <String>['07:30'],
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
        reminderTimes: <String>['08:00'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'middayWater',
        title: 'Midday Water',
        category: 'water',
        reminderTimes: <String>['12:00'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'afternoonWater',
        title: 'Afternoon Water',
        category: 'water',
        reminderTimes: <String>['15:00'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'eveningWater',
        title: 'Evening Water',
        category: 'water',
        reminderTimes: <String>['19:00'],
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
        reminderTimes: <String>['08:30'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'bComplex',
        title: 'B Complex',
        category: 'vitamin',
        reminderTimes: <String>['13:00', '20:00'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
    ],
  ),
  RoutineTemplate(
    id: 'medicine',
    title: 'Medication Schedule',
    description: 'Doses at the hours a prescription actually calls for.',
    iconKey: 'medication',
    categoryName: 'Medicine',
    routineCount: 2,
    routines: <TemplateRoutineItem>[
      // Three times a day is the shape most prescriptions take, and it is the
      // reason a routine can hold more than one time at all.
      TemplateRoutineItem(
        titleKey: 'medicineWithMeals',
        title: 'With meals',
        category: 'medicine',
        reminderTimes: <String>['08:00', '13:00', '19:00'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'medicineBeforeBed',
        title: 'Before bed',
        category: 'medicine',
        reminderTimes: <String>['21:30'],
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
        reminderTimes: <String>['21:30'],
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
      ),
      TemplateRoutineItem(
        titleKey: 'prepareBed',
        title: 'Prepare Bed',
        category: 'sleep',
        reminderTimes: <String>['22:00'],
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
        reminderTimes: <String>['10:00'],
        repeatDays: <int>[1, 2, 3, 4, 5],
      ),
      TemplateRoutineItem(
        titleKey: 'stretching',
        title: 'Stretching',
        category: 'breakTime',
        reminderTimes: <String>['12:00'],
        repeatDays: <int>[1, 2, 3, 4, 5],
      ),
      TemplateRoutineItem(
        titleKey: 'postureCheck',
        title: 'Posture Check',
        category: 'breakTime',
        reminderTimes: <String>['15:00'],
        repeatDays: <int>[1, 2, 3, 4, 5],
      ),
    ],
  ),
];
