import 'package:equatable/equatable.dart';

enum RoutineCategory {
  meal,
  water,
  vitamin,
  medicine,
  sleep,
  exercise,
  breakTime,
  custom,
}

class Routine extends Equatable {
  const Routine({
    required this.id,
    required this.title,
    required this.category,
    required this.reminderTime,
    required this.repeatDays,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.snoozeMinutes = 10,
  });

  final String id;
  final String title;
  final RoutineCategory category;
  final String reminderTime;
  final List<int> repeatDays;
  final bool isEnabled;
  final int snoozeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Routine copyWith({
    String? id,
    String? title,
    RoutineCategory? category,
    String? reminderTime,
    List<int>? repeatDays,
    bool? isEnabled,
    int? snoozeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    category,
    reminderTime,
    repeatDays,
    isEnabled,
    snoozeMinutes,
    createdAt,
    updatedAt,
  ];
}
