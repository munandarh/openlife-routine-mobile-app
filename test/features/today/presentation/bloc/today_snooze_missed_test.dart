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
  final DateTime now = DateTime(2026, 7, 1, 9);
  final DateTime today = DateTime(2026, 7, 1);
  final DateTime yesterday = DateTime(2026, 6, 30);

  TodayBloc buildBloc() =>
      TodayBloc(appDatabase: appDatabase, nowProvider: () => now);

  String keyFor(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  setUp(() async {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = DriftRoutineRepository(
      RoutineLocalDataSource(appDatabase),
    );

    await routineRepository.createRoutine(
      domain.Routine(
        id: 'r-early',
        title: 'Morning Water',
        category: domain.RoutineCategory.water,
        reminderTime: '07:00',
        repeatDays: const <int>[1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        snoozeMinutes: 15,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await routineRepository.createRoutine(
      domain.Routine(
        id: 'r-late',
        title: 'Evening Stretch',
        category: domain.RoutineCategory.breakTime,
        reminderTime: '20:00',
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

  Future<TodayState> loadedState(TodayBloc bloc) async {
    bloc.add(const TodayStarted());
    await bloc.stream.firstWhere(
      (TodayState s) => s.status == TodayStatus.success,
    );
    return bloc.state;
  }

  group('nextRoutine', () {
    test('is the earliest routine still awaiting an answer', () async {
      final TodayBloc bloc = buildBloc();
      final TodayState state = await loadedState(bloc);

      expect(state.nextRoutine?.routineId, 'r-early');
      await bloc.close();
    });

    test('moves on once the earlier routine is done', () async {
      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);

      bloc.add(const TodayRoutineCompletionToggled('r-early'));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.completedCount == 1,
      );

      expect(state.nextRoutine?.routineId, 'r-late');
      await bloc.close();
    });

    test('is null when nothing is left open', () async {
      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);

      bloc.add(const TodayRoutineCompletionToggled('r-early'));
      await bloc.stream.firstWhere((TodayState s) => s.completedCount == 1);
      bloc.add(const TodayRoutineSkipped('r-late'));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.skippedCount == 1,
      );

      expect(state.nextRoutine, isNull);
      await bloc.close();
    });
  });

  group('snooze', () {
    test('records a snoozed log with a wake-up time', () async {
      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);

      bloc.add(const TodayRoutineSnoozed('r-early'));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.snoozedCount == 1,
      );

      final TodayRoutineItem item = state.findItem('r-early')!;
      expect(item.status, TodayRoutineItemStatus.snoozed);
      // The routine's own 15-minute snooze wins over the 10-minute default.
      expect(item.snoozedUntil, now.add(const Duration(minutes: 15)));
      await bloc.close();
    });

    test('a snoozed routine still counts as open, not completed', () async {
      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);

      bloc.add(const TodayRoutineSnoozed('r-early'));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.snoozedCount == 1,
      );

      expect(state.completedCount, 0);
      expect(state.findItem('r-early')!.isOpen, isTrue);
      expect(state.nextRoutine?.routineId, 'r-early');
      await bloc.close();
    });

    test('is ignored for a routine that is already done', () async {
      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);

      bloc.add(const TodayRoutineCompletionToggled('r-early'));
      await bloc.stream.firstWhere((TodayState s) => s.completedCount == 1);

      bloc.add(const TodayRoutineSnoozed('r-early'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        bloc.state.findItem('r-early')!.status,
        TodayRoutineItemStatus.done,
      );
      await bloc.close();
    });
  });

  group('missed', () {
    test('a past day with no log reads as missed', () async {
      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);

      bloc.add(TodayDateSelected(yesterday));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.selectedDate == yesterday,
      );

      expect(state.missedCount, 2);
      expect(state.pendingCount, 0);
      await bloc.close();
    });

    test('a stored missed log is surfaced as missed', () async {
      await appDatabase.upsertRoutineLog(
        routineId: 'r-early',
        dateKey: keyFor(yesterday),
        status: 'missed',
      );

      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);
      bloc.add(TodayDateSelected(yesterday));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.selectedDate == yesterday,
      );

      expect(state.findItem('r-early')!.status, TodayRoutineItemStatus.missed);
      await bloc.close();
    });

    test('a completed past day is not rewritten as missed', () async {
      await appDatabase.upsertRoutineLog(
        routineId: 'r-early',
        dateKey: keyFor(yesterday),
        status: 'done',
      );

      final TodayBloc bloc = buildBloc();
      await loadedState(bloc);
      bloc.add(TodayDateSelected(yesterday));
      final TodayState state = await bloc.stream.firstWhere(
        (TodayState s) => s.selectedDate == yesterday,
      );

      expect(state.findItem('r-early')!.status, TodayRoutineItemStatus.done);
      expect(state.missedCount, 1);
      await bloc.close();
    });

    test('today stays pending, never missed', () async {
      final TodayBloc bloc = buildBloc();
      final TodayState state = await loadedState(bloc);

      expect(state.selectedDate, today);
      expect(state.missedCount, 0);
      expect(state.pendingCount, 2);
      await bloc.close();
    });
  });

  group('isDueNow', () {
    test('marks a routine whose time has passed today', () async {
      final TodayBloc bloc = buildBloc();
      final TodayState state = await loadedState(bloc);

      // 09:00 now: the 07:00 routine is due, the 20:00 one is not.
      expect(state.findItem('r-early')!.isDueNow, isTrue);
      expect(state.findItem('r-late')!.isDueNow, isFalse);
      await bloc.close();
    });
  });
}
