part of 'today_bloc.dart';

sealed class TodayEvent extends Equatable {
  const TodayEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class TodayStarted extends TodayEvent {
  const TodayStarted();
}

final class TodayDateSelected extends TodayEvent {
  const TodayDateSelected(this.selectedDate);

  final DateTime selectedDate;

  @override
  List<Object?> get props => <Object?>[selectedDate];
}

final class TodayRoutineCompletionToggled extends TodayEvent {
  const TodayRoutineCompletionToggled(this.routineId, this.reminderTime);

  final String routineId;

  /// Which of the routine's reminder times is being answered. A routine taken
  /// morning and night has an item for each, and they answer separately.
  final String reminderTime;

  @override
  List<Object?> get props => <Object?>[routineId, reminderTime];
}

final class TodayRoutineSkipped extends TodayEvent {
  const TodayRoutineSkipped(this.routineId, this.reminderTime);

  final String routineId;

  /// Which of the routine's reminder times is being answered. A routine taken
  /// morning and night has an item for each, and they answer separately.
  final String reminderTime;

  @override
  List<Object?> get props => <Object?>[routineId, reminderTime];
}

/// Pushes a routine's reminder back by its configured snooze duration.
final class TodayRoutineSnoozed extends TodayEvent {
  const TodayRoutineSnoozed(this.routineId, this.reminderTime);

  final String routineId;

  /// Which of the routine's reminder times is being answered. A routine taken
  /// morning and night has an item for each, and they answer separately.
  final String reminderTime;

  @override
  List<Object?> get props => <Object?>[routineId, reminderTime];
}

/// Re-reads the routines themselves, not just today's logs.
///
/// The bloc snapshots the routine list when it starts, so a routine created,
/// edited or deleted while Today stayed mounted — or a notification action
/// answered outside the app — was invisible until the screen was rebuilt.
final class TodayRefreshRequested extends TodayEvent {
  const TodayRefreshRequested();
}
