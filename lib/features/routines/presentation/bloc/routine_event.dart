part of 'routine_bloc.dart';

sealed class RoutineEvent extends Equatable {
  const RoutineEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class RoutineWatchRequested extends RoutineEvent {
  const RoutineWatchRequested();
}

final class RoutineDetailRequested extends RoutineEvent {
  const RoutineDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Flips a routine's reminders on or off from the list, without opening the
/// editor — the switch is inline on Routines, so this is its own event rather
/// than a full update that would need every other field.
final class RoutineEnabledToggled extends RoutineEvent {
  const RoutineEnabledToggled({
    required this.routineId,
    required this.isEnabled,
  });

  final String routineId;
  final bool isEnabled;

  @override
  List<Object?> get props => <Object?>[routineId, isEnabled];
}

final class RoutineCreateRequested extends RoutineEvent {
  const RoutineCreateRequested({
    required this.title,
    required this.category,
    required this.reminderTimes,
    required this.repeatDays,
    this.isEnabled = true,
    this.snoozeMinutes = 10,
    this.iconKey,
    this.notes,
  });

  final String title;
  final RoutineCategory category;
  final List<String> reminderTimes;
  final List<int> repeatDays;
  final bool isEnabled;
  final int snoozeMinutes;
  final String? iconKey;
  final String? notes;

  @override
  List<Object?> get props => <Object?>[
    title,
    category,
    reminderTimes,
    repeatDays,
    isEnabled,
    snoozeMinutes,
    iconKey,
    notes,
  ];
}

final class RoutineUpdateRequested extends RoutineEvent {
  const RoutineUpdateRequested({
    required this.id,
    required this.title,
    required this.category,
    required this.reminderTimes,
    required this.repeatDays,
    required this.isEnabled,
    this.snoozeMinutes = 10,
    this.iconKey,
    this.notes,
  });

  final String id;
  final String title;
  final RoutineCategory category;
  final List<String> reminderTimes;
  final List<int> repeatDays;
  final bool isEnabled;
  final int snoozeMinutes;
  final String? iconKey;
  final String? notes;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    category,
    reminderTimes,
    repeatDays,
    isEnabled,
    snoozeMinutes,
    iconKey,
    notes,
  ];
}

final class RoutineDeleteRequested extends RoutineEvent {
  const RoutineDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

final class _RoutineWatchUpdated extends RoutineEvent {
  const _RoutineWatchUpdated(this.routines);

  final List<Routine> routines;

  @override
  List<Object?> get props => <Object?>[routines];
}
