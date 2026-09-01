import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart'
    show AppDatabase, RoutineLogQueries;
import 'package:openlife_routine/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_event.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_state.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';

void main() {
  late AppDatabase appDatabase;
  late RoutineRepository repository;

  // Wednesday 2026-07-01; the week runs Mon 2026-06-29 .. Sun 2026-07-05.
  final DateTime now = DateTime(2026, 7, 1, 12);
  final DateTime monday = DateTime(2026, 6, 29);

  InsightsBloc buildBloc() =>
      InsightsBloc(appDatabase: appDatabase, nowProvider: () => now);

  String keyFor(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  Future<InsightsState> load() async {
    final InsightsBloc bloc = buildBloc()..add(const InsightsStarted());
    final InsightsState state = await bloc.stream.firstWhere(
      (InsightsState s) => s.status == InsightsStatus.success,
    );
    await bloc.close();
    return state;
  }

  Future<void> seed({
    required String id,
    required List<int> repeatDays,
    bool isEnabled = true,
    DateTime? createdAt,
  }) {
    // Default well before the reporting window so existing expectations are
    // about repeat days, not about creation date.
    final DateTime created = createdAt ?? now.subtract(const Duration(days: 60));
    return repository.createRoutine(
      Routine(
        id: id,
        title: 'Routine $id',
        category: RoutineCategory.water,
        reminderTime: '08:00',
        repeatDays: repeatDays,
        isEnabled: isEnabled,
        createdAt: created,
        updatedAt: created,
      ),
    );
  }

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRoutineRepository(RoutineLocalDataSource(appDatabase));
  });

  tearDown(() async {
    await appDatabase.close();
  });

  group('weekly denominator', () {
    test('counts only the weekdays a routine actually repeats on', () async {
      // Weekdays only: 5 occurrences in the week, not 7.
      await seed(id: 'weekday', repeatDays: <int>[1, 2, 3, 4, 5]);

      final InsightsState state = await load();

      expect(state.totalRoutines, 5);
    });

    test('excludes disabled routines entirely', () async {
      await seed(id: 'on', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      await seed(id: 'off', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7], isEnabled: false);

      final InsightsState state = await load();

      expect(state.totalRoutines, 7);
    });

    test('a routine only counts from the day it was created', () async {
      // Created on Wednesday: Mon and Tue of this week must not count.
      await seed(
        id: 'new',
        repeatDays: <int>[1, 2, 3, 4, 5, 6, 7],
        createdAt: now,
      );

      final InsightsState state = await load();

      // Wed..Sun = 5 days of the current week.
      expect(state.totalRoutines, 5);
    });

    test('completion rate divides by scheduled occurrences', () async {
      await seed(id: 'weekday', repeatDays: <int>[1, 2, 3, 4, 5]);
      // Done on Monday and Tuesday out of 5 scheduled weekdays.
      await appDatabase.upsertRoutineLog(
        routineId: 'weekday',
        dateKey: keyFor(monday),
        status: 'done',
      );
      await appDatabase.upsertRoutineLog(
        routineId: 'weekday',
        dateKey: keyFor(monday.add(const Duration(days: 1))),
        status: 'done',
      );

      final InsightsState state = await load();

      expect(state.totalCompleted, 2);
      expect(state.weeklyCompletionRate, closeTo(2 / 5, 0.0001));
    });
  });

  group('most missed', () {
    test('a skipped routine is not reported as missed', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(monday),
        status: 'skipped',
      );

      final InsightsState state = await load();

      expect(state.mostMissedRoutine, isNull);
    });

    test('a missed routine is reported with its title and count', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(monday),
        status: 'missed',
      );
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(monday.add(const Duration(days: 1))),
        status: 'missed',
      );

      final InsightsState state = await load();

      expect(state.mostMissedRoutine?.title, 'Routine r1');
      expect(state.mostMissedRoutine?.count, 2);
    });

    test('most completed carries the routine title', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(monday),
        status: 'done',
      );

      final InsightsState state = await load();

      expect(state.mostCompletedRoutine?.title, 'Routine r1');
    });
  });

  group('streak', () {
    test('an unfinished today does not break the streak', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      // Yesterday and the day before are complete; today is untouched.
      for (int i = 1; i <= 2; i += 1) {
        await appDatabase.upsertRoutineLog(
          routineId: 'r1',
          dateKey: keyFor(now.subtract(Duration(days: i))),
          status: 'done',
        );
      }

      final InsightsState state = await load();

      expect(state.streak, 2);
    });

    test('a missed day ends the streak', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(now.subtract(const Duration(days: 1))),
        status: 'done',
      );
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(now.subtract(const Duration(days: 2))),
        status: 'missed',
      );

      final InsightsState state = await load();

      expect(state.streak, 1);
    });

    test('is zero with no completions at all', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);

      final InsightsState state = await load();

      expect(state.streak, 0);
    });
  });

  group('7-day history', () {
    test('returns seven days, oldest first, ending today', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);

      final InsightsState state = await load();

      expect(state.history, hasLength(7));
      expect(state.history.first.date, DateTime(2026, 6, 25));
      expect(state.history.last.date, DateTime(2026, 7, 1));
    });

    test('breaks each day down into done, skipped and missed', () async {
      await seed(id: 'r1', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      await seed(id: 'r2', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);
      await seed(id: 'r3', repeatDays: <int>[1, 2, 3, 4, 5, 6, 7]);

      final DateTime yesterday = now.subtract(const Duration(days: 1));
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: keyFor(yesterday),
        status: 'done',
      );
      await appDatabase.upsertRoutineLog(
        routineId: 'r2',
        dateKey: keyFor(yesterday),
        status: 'skipped',
      );
      await appDatabase.upsertRoutineLog(
        routineId: 'r3',
        dateKey: keyFor(yesterday),
        status: 'missed',
      );

      final InsightsState state = await load();
      final InsightsDaySummary day = state.history.firstWhere(
        (InsightsDaySummary d) => d.date == DateTime(2026, 6, 30),
      );

      expect(day.scheduled, 3);
      expect(day.done, 1);
      expect(day.skipped, 1);
      expect(day.missed, 1);
      expect(day.completionRate, closeTo(1 / 3, 0.0001));
    });

    test('a day the routine does not repeat on has nothing scheduled', () async {
      // Sundays only.
      await seed(id: 'r1', repeatDays: <int>[DateTime.sunday]);

      final InsightsState state = await load();
      final List<InsightsDaySummary> scheduledDays = state.history
          .where((InsightsDaySummary d) => d.scheduled > 0)
          .toList();

      expect(scheduledDays, hasLength(1));
      expect(scheduledDays.single.date.weekday, DateTime.sunday);
    });
  });
}
