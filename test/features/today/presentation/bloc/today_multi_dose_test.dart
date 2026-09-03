import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';

/// Today lists one card per routine, which was wrong the moment a routine
/// could be taken three times a day: the 08:00 dose and the 20:00 dose are two
/// separate things to answer, and answering one must not answer the other.
void main() {
  late AppDatabase appDatabase;
  late DriftRoutineRepository routineRepository;

  // 2026-07-01 is a Wednesday, and 15:00 is after the second of three doses.
  final DateTime now = DateTime(2026, 7, 1, 15);

  TodayBloc buildBloc() =>
      TodayBloc(appDatabase: appDatabase, nowProvider: () => now);

  Future<TodayState> load() async {
    final TodayBloc bloc = buildBloc();
    bloc.add(const TodayStarted());
    final TodayState state = await bloc.stream.firstWhere(
      (TodayState s) => s.status == TodayStatus.success,
    );
    await bloc.close();
    return state;
  }

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );

    await routineRepository.createRoutine(
      domain.Routine(
        id: 'r-med',
        title: 'Antibiotic',
        category: domain.RoutineCategory.medicine,
        reminderTimes: const <String>['08:00', '14:00', '20:00'],
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      ),
    );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('a three-times-a-day routine is three items, in order', () async {
    final TodayState state = await load();

    expect(state.items.length, 3);
    expect(
      state.items.map((TodayRoutineItem item) => item.reminderTime).toList(),
      <String>['08:00', '14:00', '20:00'],
    );
    expect(
      state.items.every((TodayRoutineItem item) => item.title == 'Antibiotic'),
      isTrue,
    );
  });

  test('only the doses whose time has passed are due', () async {
    final TodayState state = await load();

    // At 15:00 the 08:00 and 14:00 doses are due; the 20:00 one is not.
    expect(
      state.items
          .where((TodayRoutineItem item) => item.isDueNow)
          .map((TodayRoutineItem item) => item.reminderTime)
          .toList(),
      <String>['08:00', '14:00'],
    );
  });

  test('completing one dose leaves the others pending', () async {
    final TodayBloc bloc = buildBloc();
    bloc.add(const TodayStarted());
    await bloc.stream.firstWhere(
      (TodayState s) => s.status == TodayStatus.success,
    );

    bloc.add(const TodayRoutineCompletionToggled('r-med', '08:00'));
    final TodayState state = await bloc.stream.firstWhere(
      (TodayState s) =>
          s.findItem('r-med', '08:00')?.status == TodayRoutineItemStatus.done,
    );

    // The whole point: one log a day used to mean this marked all three.
    expect(
      state.findItem('r-med', '14:00')?.status,
      TodayRoutineItemStatus.pending,
    );
    expect(
      state.findItem('r-med', '20:00')?.status,
      TodayRoutineItemStatus.pending,
    );
    expect(state.completedCount, 1);
    expect(state.totalCount, 3);

    await bloc.close();
  });

  test('skipping one dose does not skip the rest', () async {
    final TodayBloc bloc = buildBloc();
    bloc.add(const TodayStarted());
    await bloc.stream.firstWhere(
      (TodayState s) => s.status == TodayStatus.success,
    );

    bloc.add(const TodayRoutineSkipped('r-med', '14:00'));
    final TodayState state = await bloc.stream.firstWhere(
      (TodayState s) =>
          s.findItem('r-med', '14:00')?.status ==
          TodayRoutineItemStatus.skipped,
    );

    expect(
      state.findItem('r-med', '08:00')?.status,
      TodayRoutineItemStatus.pending,
    );
    expect(
      state.findItem('r-med', '20:00')?.status,
      TodayRoutineItemStatus.pending,
    );

    await bloc.close();
  });

  test('snoozing one dose leaves the others alone', () async {
    final TodayBloc bloc = buildBloc();
    bloc.add(const TodayStarted());
    await bloc.stream.firstWhere(
      (TodayState s) => s.status == TodayStatus.success,
    );

    bloc.add(const TodayRoutineSnoozed('r-med', '08:00'));
    final TodayState state = await bloc.stream.firstWhere(
      (TodayState s) =>
          s.findItem('r-med', '08:00')?.status ==
          TodayRoutineItemStatus.snoozed,
    );

    expect(
      state.findItem('r-med', '14:00')?.status,
      TodayRoutineItemStatus.pending,
    );
    expect(state.findItem('r-med', '08:00')?.snoozedUntil, isNotNull);
    expect(state.findItem('r-med', '14:00')?.snoozedUntil, isNull);

    await bloc.close();
  });
}
