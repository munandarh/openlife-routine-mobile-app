import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/insights/domain/routine_streak.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_event.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  InsightsBloc({
    required AppDatabase appDatabase,
    DateTime Function()? nowProvider,
  }) : _appDatabase = appDatabase,
       _nowProvider = nowProvider ?? DateTime.now,
       super(const InsightsState()) {
    on<InsightsStarted>(_onStarted);
  }

  final AppDatabase _appDatabase;
  final DateTime Function() _nowProvider;

  Future<void> _onStarted(
    InsightsStarted event,
    Emitter<InsightsState> emit,
  ) async {
    emit(
      state.copyWith(status: InsightsStatus.loading, clearErrorMessage: true),
    );

    try {
      final DateTime now = _nowProvider();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime monday = today.subtract(Duration(days: now.weekday - 1));
      final DateTime historyStart = today.subtract(const Duration(days: 6));

      final List<RoutineBundleRow> bundles =
          (await _appDatabase.getRoutineBundles())
              .where((RoutineBundleRow b) => b.routine.isEnabled)
              .toList();

      // One range query covering both the current week and the 7-day history.
      final DateTime rangeStart = monday.isBefore(historyStart)
          ? monday
          : historyStart;
      final DateTime rangeEnd = monday.add(const Duration(days: 6));
      final List<RoutineLogRowData> logs = await _appDatabase
          .getRoutineLogsBetween(
            RoutineStreak.dateKey(rangeStart),
            RoutineStreak.dateKey(rangeEnd),
          );

      final Map<String, List<RoutineLogRowData>> logsByDate =
          <String, List<RoutineLogRowData>>{};
      for (final RoutineLogRowData log in logs) {
        logsByDate.putIfAbsent(log.date, () => <RoutineLogRowData>[]).add(log);
      }

      // --- current week -------------------------------------------------
      int weekScheduled = 0;
      int weekCompleted = 0;
      final List<double> dailyCompletion = <double>[];

      for (int i = 0; i < 7; i += 1) {
        final DateTime day = monday.add(Duration(days: i));
        final int scheduled = RoutineStreak.scheduledOn(bundles, day);
        final int done = RoutineStreak.countStatus(
          logsByDate[RoutineStreak.dateKey(day)],
          'done',
        );

        weekScheduled += scheduled;
        weekCompleted += done;
        dailyCompletion.add(scheduled == 0 ? 0 : done / scheduled);
      }

      // --- 7-day history -------------------------------------------------
      final List<InsightsDaySummary> history = <InsightsDaySummary>[];
      for (int i = 0; i < 7; i += 1) {
        final DateTime day = historyStart.add(Duration(days: i));
        final List<RoutineLogRowData>? dayLogs =
            logsByDate[RoutineStreak.dateKey(day)];
        history.add(
          InsightsDaySummary(
            date: day,
            scheduled: RoutineStreak.scheduledOn(bundles, day),
            done: RoutineStreak.countStatus(dayLogs, 'done'),
            skipped: RoutineStreak.countStatus(dayLogs, 'skipped'),
            missed: RoutineStreak.countStatus(dayLogs, 'missed'),
          ),
        );
      }

      // --- per-routine metrics -------------------------------------------
      final Map<String, String> titles = <String, String>{
        for (final RoutineBundleRow b in bundles) b.routine.id: b.routine.title,
      };
      final Map<String, int> completedByRoutine = <String, int>{};
      final Map<String, int> missedByRoutine = <String, int>{};

      for (final RoutineLogRowData log in logs) {
        switch (log.status) {
          case 'done':
            completedByRoutine[log.routineId] =
                (completedByRoutine[log.routineId] ?? 0) + 1;
          case 'missed':
            // Only genuine misses count here — a deliberate skip is a choice,
            // not a failure, and must not be surfaced as one.
            missedByRoutine[log.routineId] =
                (missedByRoutine[log.routineId] ?? 0) + 1;
        }
      }

      final int streak = RoutineStreak.calculate(
        bundles: bundles,
        logsByDate: logsByDate,
        today: today,
      );

      emit(
        state.copyWith(
          status: InsightsStatus.success,
          weeklyCompletionRate: weekScheduled == 0
              ? 0
              : weekCompleted / weekScheduled,
          totalCompleted: weekCompleted,
          totalRoutines: weekScheduled,
          streak: streak,
          mostCompletedRoutine: _topMetric(completedByRoutine, titles),
          mostMissedRoutine: _topMetric(missedByRoutine, titles),
          dailyCompletion: dailyCompletion,
          history: history,
          overwriteMetrics: true,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: InsightsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// How many enabled routines actually repeat on [day]'s weekday.
  ///
  /// A routine only counts from the day it was created; otherwise a routine
  /// added today drags last week's completion rate to zero.

  static RoutineMetric? _topMetric(
    Map<String, int> counts,
    Map<String, String> titles,
  ) {
    if (counts.isEmpty) {
      return null;
    }
    final MapEntry<String, int> top = counts.entries.reduce(
      (MapEntry<String, int> a, MapEntry<String, int> b) =>
          a.value >= b.value ? a : b,
    );
    return RoutineMetric(
      routineId: top.key,
      title: titles[top.key] ?? top.key,
      count: top.value,
    );
  }
}
