import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_event.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  InsightsBloc({required AppDatabase appDatabase})
    : _appDatabase = appDatabase,
      super(const InsightsState()) {
    on<InsightsStarted>(_onStarted);
  }

  final AppDatabase _appDatabase;

  Future<void> _onStarted(
    InsightsStarted event,
    Emitter<InsightsState> emit,
  ) async {
    emit(
      state.copyWith(status: InsightsStatus.loading, clearErrorMessage: true),
    );

    try {
      final DateTime now = DateTime.now();
      final int mondayOffset = -(now.weekday - 1);
      final DateTime monday = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: mondayOffset));

      final List<String> weekDates = List<String>.generate(7, (int i) {
        final DateTime d = monday.add(Duration(days: i));
        final String m = d.month.toString().padLeft(2, '0');
        final String day = d.day.toString().padLeft(2, '0');
        return '${d.year}-$m-$day';
      });

      // Collect all logs for this week.
      final List<RoutineLogRowData> allLogs = <RoutineLogRowData>[];
      for (final String dateKey in weekDates) {
        allLogs.addAll(await _appDatabase.getRoutineLogsByDate(dateKey));
      }

      // Total routines scheduled per day (from active routines).
      final List<RoutineBundleRow> bundles = await _appDatabase
          .getRoutineBundles();
      final int activeRoutineCount = bundles
          .where((b) => b.routine.isEnabled)
          .length;

      // Weekly completion: percentage of completed logs vs total possible.
      final int totalPossible = activeRoutineCount * 7;
      final int completed = allLogs.where((log) => log.status == 'done').length;
      final double rate = totalPossible > 0 ? completed / totalPossible : 0.0;

      // Daily completion per day.
      final List<double> dailyCompletion = <double>[];
      for (final String dateKey in weekDates) {
        final List<RoutineLogRowData> dayLogs = allLogs
            .where((log) => log.date == dateKey)
            .toList();
        final int dayCompleted = dayLogs
            .where((log) => log.status == 'done')
            .length;
        dailyCompletion.add(
          activeRoutineCount > 0 ? dayCompleted / activeRoutineCount : 0.0,
        );
      }

      // Most completed / missed routines.
      final Map<String, int> completedByRoutine = <String, int>{};
      final Map<String, int> missedByRoutine = <String, int>{};
      for (final RoutineLogRowData log in allLogs) {
        if (log.status == 'done') {
          completedByRoutine[log.routineId] =
              (completedByRoutine[log.routineId] ?? 0) + 1;
        } else {
          missedByRoutine[log.routineId] =
              (missedByRoutine[log.routineId] ?? 0) + 1;
        }
      }

      RoutineMetric? mostCompleted;
      if (completedByRoutine.isNotEmpty) {
        final MapEntry<String, int> top = completedByRoutine.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );
        mostCompleted = RoutineMetric(routineId: top.key, count: top.value);
      }

      RoutineMetric? mostMissed;
      if (missedByRoutine.isNotEmpty) {
        final MapEntry<String, int> top = missedByRoutine.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );
        mostMissed = RoutineMetric(routineId: top.key, count: top.value);
      }

      // Streak: consecutive days working backwards from today with 100%.
      int streak = 0;
      final DateTime today = DateTime(now.year, now.month, now.day);
      for (int i = 0; i < 7; i += 1) {
        final DateTime checkDate = today.subtract(Duration(days: i));
        final String dateKey = _dateKey(checkDate);
        final List<RoutineLogRowData> dayLogs = await _appDatabase
            .getRoutineLogsByDate(dateKey);
        final int dayDone = dayLogs.where((log) => log.status == 'done').length;

        // Count enabled routines for this day.
        final int scheduledThatDay = bundles.where((b) {
          return b.routine.isEnabled;
        }).length;

        if (scheduledThatDay > 0 && dayDone == scheduledThatDay) {
          streak += 1;
        } else {
          break;
        }
      }

      emit(
        state.copyWith(
          status: InsightsStatus.success,
          weeklyCompletionRate: rate,
          totalCompleted: completed,
          totalRoutines: totalPossible,
          streak: streak,
          mostCompletedRoutine: mostCompleted,
          mostMissedRoutine: mostMissed,
          dailyCompletion: dailyCompletion,
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

  static String _dateKey(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}
