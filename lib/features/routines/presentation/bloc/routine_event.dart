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

final class RoutineCreateRequested extends RoutineEvent {
  const RoutineCreateRequested({
    required this.title,
    required this.category,
    required this.reminderTime,
    required this.repeatDays,
  });

  final String title;
  final RoutineCategory category;
  final String reminderTime;
  final List<int> repeatDays;

  @override
  List<Object?> get props => <Object?>[
    title,
    category,
    reminderTime,
    repeatDays,
  ];
}

final class RoutineUpdateRequested extends RoutineEvent {
  const RoutineUpdateRequested({
    required this.id,
    required this.title,
    required this.category,
    required this.reminderTime,
    required this.repeatDays,
    required this.isEnabled,
  });

  final String id;
  final String title;
  final RoutineCategory category;
  final String reminderTime;
  final List<int> repeatDays;
  final bool isEnabled;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    category,
    reminderTime,
    repeatDays,
    isEnabled,
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
