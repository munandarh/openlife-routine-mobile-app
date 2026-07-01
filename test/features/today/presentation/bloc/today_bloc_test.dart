import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';

void main() {
  group('TodayBloc', () {
    late AppDatabase appDatabase;
    late DriftRoutineRepository routineRepository;

    setUp(() async {
      appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      routineRepository = DriftRoutineRepository(
        RoutineLocalDataSource(appDatabase),
      );

      await routineRepository.createRoutine(
        domain.Routine(
          id: 'routine-1',
          title: 'Morning Water',
          category: domain.RoutineCategory.water,
          reminderTime: '08:00',
          repeatDays: const <int>[3],
          isEnabled: true,
          createdAt: DateTime(2026, 7, 1, 8),
          updatedAt: DateTime(2026, 7, 1, 8),
        ),
      );
      await routineRepository.createRoutine(
        domain.Routine(
          id: 'routine-2',
          title: 'Sleep Early',
          category: domain.RoutineCategory.sleep,
          reminderTime: '21:00',
          repeatDays: const <int>[4],
          isEnabled: true,
          createdAt: DateTime(2026, 7, 1, 8),
          updatedAt: DateTime(2026, 7, 1, 8),
        ),
      );
    });

    tearDown(() async {
      await appDatabase.close();
    });

    blocTest<TodayBloc, TodayState>(
      'filters by selected day and updates completion state',
      build: () => TodayBloc(
        appDatabase: appDatabase,
        nowProvider: () => DateTime(2026, 7, 1, 9),
      ),
      act: (TodayBloc bloc) async {
        bloc.add(const TodayStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TodayRoutineCompletionToggled('routine-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(TodayDateSelected(DateTime(2026, 7, 2)));
      },
      expect: () => <Matcher>[
        isA<TodayState>().having(
          (TodayState state) => state.status,
          'status',
          TodayStatus.loading,
        ),
        isA<TodayState>()
            .having((TodayState state) => state.items.length, 'items.length', 1)
            .having(
              (TodayState state) => state.items.first.title,
              'first.title',
              'Morning Water',
            )
            .having(
              (TodayState state) => state.items.first.isDueNow,
              'first.isDueNow',
              true,
            ),
        isA<TodayState>()
            .having(
              (TodayState state) => state.completedCount,
              'completedCount',
              1,
            )
            .having(
              (TodayState state) => state.items.first.status,
              'first.status',
              TodayRoutineItemStatus.done,
            ),
        isA<TodayState>()
            .having(
              (TodayState state) => state.selectedDate,
              'selectedDate',
              DateTime(2026, 7, 2),
            )
            .having((TodayState state) => state.items.length, 'items.length', 1)
            .having(
              (TodayState state) => state.items.first.title,
              'first.title',
              'Sleep Early',
            ),
      ],
    );
  });
}
