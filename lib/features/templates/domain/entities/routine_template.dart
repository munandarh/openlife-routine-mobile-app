import 'package:equatable/equatable.dart';

class RoutineTemplate extends Equatable {
  const RoutineTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.categoryName,
    required this.routineCount,
    this.isPrimary = false,
    this.badge,
    this.routines = const <TemplateRoutineItem>[],
  });

  final String id;
  final String title;
  final String description;
  final String iconKey;
  final String categoryName;
  final int routineCount;
  final bool isPrimary;
  final String? badge;
  final List<TemplateRoutineItem> routines;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    description,
    iconKey,
    categoryName,
    routineCount,
    isPrimary,
    badge,
    routines,
  ];
}

class TemplateRoutineItem extends Equatable {
  const TemplateRoutineItem({
    required this.title,
    required this.category,
    required this.reminderTime,
    required this.repeatDays,
    this.snoozeMinutes = 10,
  });

  final String title;
  final String category;
  final String reminderTime;
  final List<int> repeatDays;
  final int snoozeMinutes;

  @override
  List<Object?> get props => <Object?>[
    title,
    category,
    reminderTime,
    repeatDays,
    snoozeMinutes,
  ];
}
