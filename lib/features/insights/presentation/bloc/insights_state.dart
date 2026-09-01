import 'package:equatable/equatable.dart';

enum InsightsStatus { initial, loading, success, failure }

/// One day in the 7-day history (PRD §8.6).
class InsightsDaySummary extends Equatable {
  const InsightsDaySummary({
    required this.date,
    required this.scheduled,
    required this.done,
    required this.skipped,
    required this.missed,
  });

  final DateTime date;

  /// How many routines were actually scheduled that weekday.
  final int scheduled;
  final int done;
  final int skipped;
  final int missed;

  /// Completion of the routines that were scheduled, 0..1.
  double get completionRate => scheduled == 0 ? 0 : done / scheduled;

  @override
  List<Object?> get props => <Object?>[date, scheduled, done, skipped, missed];
}

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
    this.history = const <InsightsDaySummary>[],
    this.errorMessage,
  });

  final InsightsStatus status;
  final double weeklyCompletionRate;
  final int totalCompleted;

  /// Total routine occurrences scheduled across the week — the denominator
  /// behind [weeklyCompletionRate].
  final int totalRoutines;
  final int streak;
  final RoutineMetric? mostCompletedRoutine;
  final RoutineMetric? mostMissedRoutine;

  /// Monday-first completion ratio for the current week, used by the bar chart.
  final List<double> dailyCompletion;

  /// Last 7 days ending today, oldest first.
  final List<InsightsDaySummary> history;
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
    List<InsightsDaySummary>? history,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool overwriteMetrics = false,
  }) {
    return InsightsState(
      status: status ?? this.status,
      weeklyCompletionRate: weeklyCompletionRate ?? this.weeklyCompletionRate,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalRoutines: totalRoutines ?? this.totalRoutines,
      streak: streak ?? this.streak,
      mostCompletedRoutine: overwriteMetrics
          ? mostCompletedRoutine
          : mostCompletedRoutine ?? this.mostCompletedRoutine,
      mostMissedRoutine: overwriteMetrics
          ? mostMissedRoutine
          : mostMissedRoutine ?? this.mostMissedRoutine,
      dailyCompletion: dailyCompletion ?? this.dailyCompletion,
      history: history ?? this.history,
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
    history,
    errorMessage,
  ];
}

class RoutineMetric extends Equatable {
  const RoutineMetric({
    required this.routineId,
    required this.title,
    required this.count,
  });

  final String routineId;
  final String title;
  final int count;

  @override
  List<Object?> get props => <Object?>[routineId, title, count];
}
