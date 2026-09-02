import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';

/// Today snapshots the routine list when it starts. Without an explicit
/// reload, a routine created while Today stayed mounted — or a reminder
/// answered from the notification shade — never showed up.
void main() {
  late AppDatabase appDatabase;
  late DriftRoutineRepository repository;

  // A Wednesday.
  final DateTime now = DateTime(2026, 9, 2, 9);

  TodayBloc buildBloc() =>
      TodayBloc(appDatabase: appDatabase, nowProvider: () => now);

  Future<void> addRoutine(String id, String title) {
    return repository.createRoutine(
      domain.Routine(
        id: id,
        title: title,
        category: domain.RoutineCategory.water,
        reminderTime: '09:00',
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<TodayState> loaded(TodayBloc bloc) async {
    bloc.add(const TodayStarted());
    return bloc.stream.firstWhere(
      (TodayState s) => s.status == TodayStatus.success,
    );
  }

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRoutineRepository(RoutineLocalDataSource(appDatabase));
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('a routine added after start appears once refreshed', () async {
    await addRoutine('r1', 'Morning water');
    final TodayBloc bloc = buildBloc();
    final TodayState first = await loaded(bloc);
    expect(first.totalCount, 1);

    await addRoutine('r2', 'Second routine');

    // Still stale: the bloc only re-reads logs on its own.
    expect(bloc.state.totalCount, 1);

    bloc.add(const TodayRefreshRequested());
    final TodayState refreshed = await bloc.stream.firstWhere(
      (TodayState s) => s.totalCount == 2,
    );

    expect(
      refreshed.items.map((TodayRoutineItem i) => i.title),
      containsAll(<String>['Morning water', 'Second routine']),
    );
    await bloc.close();
  });

  test('a routine deleted after start disappears once refreshed', () async {
    await addRoutine('r1', 'Morning water');
    await addRoutine('r2', 'Second routine');
    final TodayBloc bloc = buildBloc();
    expect((await loaded(bloc)).totalCount, 2);

    await repository.deleteRoutine('r2');
    bloc.add(const TodayRefreshRequested());

    final TodayState refreshed = await bloc.stream.firstWhere(
      (TodayState s) => s.totalCount == 1,
    );
    expect(refreshed.items.single.title, 'Morning water');
    await bloc.close();
  });

  test('a log written elsewhere shows up on refresh', () async {
    await addRoutine('r1', 'Morning water');
    final TodayBloc bloc = buildBloc();
    expect((await loaded(bloc)).completedCount, 0);

    // Stands in for the notification "Done" action, which writes straight to
    // the database from its own isolate.
    await appDatabase.upsertRoutineLog(
      routineId: 'r1',
      dateKey: '2026-09-02',
      status: 'done',
    );

    bloc.add(const TodayRefreshRequested());
    final TodayState refreshed = await bloc.stream.firstWhere(
      (TodayState s) => s.completedCount == 1,
    );

    expect(
      refreshed.items.single.status,
      TodayRoutineItemStatus.done,
    );
    await bloc.close();
  });

  test('refresh keeps the day the user is looking at', () async {
    await addRoutine('r1', 'Morning water');
    final TodayBloc bloc = buildBloc();
    await loaded(bloc);

    final DateTime yesterday = DateTime(2026, 9, 1);
    bloc.add(TodayDateSelected(yesterday));
    await bloc.stream.firstWhere((TodayState s) => s.selectedDate == yesterday);

    bloc.add(const TodayRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state.selectedDate, yesterday);
    await bloc.close();
  });

  test('refresh does not flash the loading state', () async {
    await addRoutine('r1', 'Morning water');
    final TodayBloc bloc = buildBloc();
    await loaded(bloc);

    final List<TodayStatus> seen = <TodayStatus>[];
    final sub = bloc.stream.listen((TodayState s) => seen.add(s.status));

    bloc.add(const TodayRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(seen, isNot(contains(TodayStatus.loading)));
    await sub.cancel();
    await bloc.close();
  });
}
