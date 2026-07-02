import 'package:equatable/equatable.dart';

enum InsightsStatus { initial, loading, success, failure }

class InsightsState extends Equatable {
  const InsightsState({
    this.status = InsightsStatus.initial,
    this.weeklyCompletionRate = 0.0,
    this.totalCompleted = 0,
    this.totalRoutines = 0,
    this.streak = 0,
    this.mostCompletedRoutine,
    this.mostMissedRoutine,
    this.dailyCompletion = const <double>[],
    this.errorMessage,
  });

  final InsightsStatus status;
  final double weeklyCompletionRate;
  final int totalCompleted;
  final int totalRoutines;
  final int streak;
  final RoutineMetric? mostCompletedRoutine;
  final RoutineMetric? mostMissedRoutine;
  final List<double> dailyCompletion;
  final String? errorMessage;

  InsightsState copyWith({
    InsightsStatus? status,
    double? weeklyCompletionRate,
    int? totalCompleted,
    int? totalRoutines,
    int? streak,
    RoutineMetric? mostCompletedRoutine,
    RoutineMetric? mostMissedRoutine,
    List<double>? dailyCompletion,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return InsightsState(
      status: status ?? this.status,
      weeklyCompletionRate: weeklyCompletionRate ?? this.weeklyCompletionRate,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalRoutines: totalRoutines ?? this.totalRoutines,
      streak: streak ?? this.streak,
      mostCompletedRoutine: mostCompletedRoutine ?? this.mostCompletedRoutine,
      mostMissedRoutine: mostMissedRoutine ?? this.mostMissedRoutine,
      dailyCompletion: dailyCompletion ?? this.dailyCompletion,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    weeklyCompletionRate,
    totalCompleted,
    totalRoutines,
    streak,
    mostCompletedRoutine,
    mostMissedRoutine,
    dailyCompletion,
    errorMessage,
  ];
}

class RoutineMetric extends Equatable {
  const RoutineMetric({required this.routineId, required this.count});

  final String routineId;
  final int count;

  @override
  List<Object?> get props => <Object?>[routineId, count];
}
