import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';

void main() {
  late AppDatabase appDatabase;
  late DriftRoutineRepository routineRepository;

  // 2026-07-01 is a Wednesday (weekday 3).
  final DateTime now = DateTime(2026, 7, 1, 10);

  TodayBloc buildBloc() =>
      TodayBloc(appDatabase: appDatabase, nowProvider: () => now);

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );

    // Seed 4 routines with different times.
    await routineRepository.createRoutine(
      domain.Routine(
        id: 'r-afternoon',
        title: 'Lunch',
        category: domain.RoutineCategory.meal,
        reminderTimes: <String>['12:30'],
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await routineRepository.createRoutine(
      domain.Routine(
        id: 'r-morning',
        title: 'Morning Water',
        category: domain.RoutineCategory.water,
        reminderTimes: <String>['07:00'],
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await routineRepository.createRoutine(
      domain.Routine(
        id: 'r-evening',
        title: 'Evening Walk',
        category: domain.RoutineCategory.exercise,
        reminderTimes: <String>['19:00'],
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await routineRepository.createRoutine(
      domain.Routine(
        id: 'r-midday',
        title: 'Vitamin D',
        category: domain.RoutineCategory.vitamin,
        reminderTimes: <String>['09:00'],
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test(
    'sorts routines by reminder time ascending when none are completed',
    () async {
      final TodayBloc bloc = buildBloc();
      bloc.add(const TodayStarted());
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.status == TodayStatus.success,
      );

      expect(
        state.items.map((TodayRoutineItem i) => i.reminderTime).toList(),
        <String>['07:00', '09:00', '12:30', '19:00'],
      );
      expect(
        state.items.map((TodayRoutineItem i) => i.title).toList(),
        <String>['Morning Water', 'Vitamin D', 'Lunch', 'Evening Walk'],
      );
      await bloc.close();
    },
  );

  test('moves completed routine to the bottom', () async {
    final TodayBloc bloc = buildBloc();
    bloc.add(const TodayStarted());
    await bloc.stream.firstWhere(
      (TodayState s) => s.status == TodayStatus.success,
    );

    // Complete the 07:00 routine (Morning Water).
    bloc.add(const TodayRoutineCompletionToggled('r-morning', '07:00'));
    final TodayState state = await bloc.stream.firstWhere(
      (TodayState s) => s.completedCount == 1,
    );

    // Morning Water (07:00) should now be at the bottom!
    expect(state.items.map((TodayRoutineItem i) => i.title).toList(), <String>[
      'Vitamin D',
      'Lunch',
      'Evening Walk',
      'Morning Water',
    ]);
    expect(state.items.last.status, TodayRoutineItemStatus.done);
    await bloc.close();
  });

  test(
    'sorts completed routines among themselves at the bottom by time',
    () async {
      final TodayBloc bloc = buildBloc();
      bloc.add(const TodayStarted());
      await bloc.stream.firstWhere(
        (TodayState s) => s.status == TodayStatus.success,
      );

      // Complete Evening Walk (19:00) first, then Morning Water (07:00).
      bloc.add(const TodayRoutineCompletionToggled('r-evening', '19:00'));
      await bloc.stream.firstWhere((TodayState s) => s.completedCount == 1);

      bloc.add(const TodayRoutineCompletionToggled('r-morning', '07:00'));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.completedCount == 2,
      );

      // Incomplete items at top: 09:00, 12:30
      // Completed items at bottom: 07:00, 19:00 (sorted by time)
      expect(
        state.items.map((TodayRoutineItem i) => i.title).toList(),
        <String>['Vitamin D', 'Lunch', 'Morning Water', 'Evening Walk'],
      );
      expect(state.items[2].reminderTime, '07:00');
      expect(state.items[2].status, TodayRoutineItemStatus.done);
      expect(state.items[3].reminderTime, '19:00');
      expect(state.items[3].status, TodayRoutineItemStatus.done);
      await bloc.close();
    },
  );

  test(
    'uncompleting a routine returns it to its time-sorted position among incomplete items',
    () async {
      final TodayBloc bloc = buildBloc();
      bloc.add(const TodayStarted());
      await bloc.stream.firstWhere(
        (TodayState s) => s.status == TodayStatus.success,
      );

      // Complete Morning Water (07:00) and Lunch (12:30).
      bloc.add(const TodayRoutineCompletionToggled('r-morning', '07:00'));
      await bloc.stream.firstWhere((TodayState s) => s.completedCount == 1);
      bloc.add(const TodayRoutineCompletionToggled('r-afternoon', '12:30'));
      await bloc.stream.firstWhere((TodayState s) => s.completedCount == 2);

      // Uncomplete Morning Water (07:00).
      bloc.add(const TodayRoutineCompletionToggled('r-morning', '07:00'));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.completedCount == 1,
      );

      // Morning Water (07:00) is now incomplete again, so it goes back to the top!
      // Lunch (12:30) remains completed at the bottom.
      expect(
        state.items.map((TodayRoutineItem i) => i.title).toList(),
        <String>['Morning Water', 'Vitamin D', 'Evening Walk', 'Lunch'],
      );
      await bloc.close();
    },
  );
}
