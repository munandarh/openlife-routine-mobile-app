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
  const TodayRoutineCompletionToggled(this.routineId);

  final String routineId;

  @override
  List<Object?> get props => <Object?>[routineId];
}

final class TodayRoutineSkipped extends TodayEvent {
  const TodayRoutineSkipped(this.routineId);

  final String routineId;

  @override
  List<Object?> get props => <Object?>[routineId];
}
