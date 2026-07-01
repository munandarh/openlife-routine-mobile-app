import 'package:equatable/equatable.dart';

class RoutineSchedule extends Equatable {
  const RoutineSchedule({
    required this.id,
    required this.routineId,
    required this.reminderTime,
    required this.repeatDays,
    required this.snoozeMinutes,
    required this.updatedAt,
  });

  final String id;
  final String routineId;
  final String reminderTime;
  final List<int> repeatDays;
  final int snoozeMinutes;
  final DateTime updatedAt;

  RoutineSchedule copyWith({
    String? id,
    String? routineId,
    String? reminderTime,
    List<int>? repeatDays,
    int? snoozeMinutes,
    DateTime? updatedAt,
  }) {
    return RoutineSchedule(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatDays: repeatDays ?? this.repeatDays,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    routineId,
    reminderTime,
    repeatDays,
    snoozeMinutes,
    updatedAt,
  ];
}
