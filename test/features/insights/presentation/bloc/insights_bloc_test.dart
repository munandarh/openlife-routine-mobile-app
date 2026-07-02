import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_event.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_state.dart';

void main() {
  late AppDatabase appDatabase;

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Future<void> seedLogs({
    required String routineId,
    required List<String> dates,
    required String status,
  }) async {
    for (final String date in dates) {
      await appDatabase.upsertRoutineLog(
        routineId: routineId,
        dateKey: date,
        status: status,
      );
    }
  }

  group('InsightsBloc', () {
    blocTest<InsightsBloc, InsightsState>(
      'emits weekly completion when logs exist',
      setUp: () async {
        // Seed a routine.
        await appDatabase
            .into(appDatabase.routines)
            .insert(
              RoutinesCompanion(
                id: const Value('r1'),
                title: const Value('Breakfast'),
                category: const Value('meal'),
                isEnabled: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
        await appDatabase
            .into(appDatabase.routineSchedules)
            .insert(
              RoutineSchedulesCompanion(
                id: const Value('s1'),
                routineId: const Value('r1'),
                reminderTime: const Value('07:00'),
                repeatDays: Value(jsonEncode(<int>[1, 2, 3, 4, 5, 6, 7])),
                snoozeMinutes: const Value(10),
                updatedAt: Value(DateTime.now()),
              ),
            );

        // Seed logs for this week (3 days done out of 5).
        final DateTime now = DateTime.now();
        final int mondayOffset = -(now.weekday - 1);
        final DateTime monday = now.add(Duration(days: mondayOffset));

        await seedLogs(
          routineId: 'r1',
          dates: <String>[
            _dateKey(monday),
            _dateKey(monday.add(const Duration(days: 1))),
            _dateKey(monday.add(const Duration(days: 2))),
          ],
          status: 'done',
        );
      },
      build: () => InsightsBloc(appDatabase: appDatabase),
      act: (InsightsBloc bloc) => bloc.add(const InsightsStarted()),
      wait: const Duration(milliseconds: 100),
      verify: (InsightsBloc bloc) {
        final InsightsState state = bloc.state;
        expect(state.status, InsightsStatus.success);
        expect(state.weeklyCompletionRate, greaterThan(0));
        expect(state.totalCompleted, 3);
      },
    );

    blocTest<InsightsBloc, InsightsState>(
      'calculates most completed routine',
      setUp: () async {
        await appDatabase
            .into(appDatabase.routines)
            .insert(
              RoutinesCompanion(
                id: const Value('water'),
                title: const Value('Drink Water'),
                category: const Value('water'),
                isEnabled: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
        await appDatabase
            .into(appDatabase.routines)
            .insert(
              RoutinesCompanion(
                id: const Value('sleep'),
                title: const Value('Sleep'),
                category: const Value('sleep'),
                isEnabled: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );

        for (final String rid in <String>['water', 'sleep']) {
          await appDatabase
              .into(appDatabase.routineSchedules)
              .insert(
                RoutineSchedulesCompanion(
                  id: Value('s_$rid'),
                  routineId: Value(rid),
                  reminderTime: const Value('08:00'),
                  repeatDays: Value(jsonEncode(<int>[1, 2, 3, 4, 5, 6, 7])),
                  snoozeMinutes: const Value(10),
                  updatedAt: Value(DateTime.now()),
                ),
              );
        }

        // Water has 5 completions, Sleep has 2.
        final DateTime now = DateTime.now();
        final int mondayOffset = -(now.weekday - 1);
        final DateTime monday = now.add(Duration(days: mondayOffset));

        await seedLogs(
          routineId: 'water',
          dates: List<String>.generate(
            5,
            (i) => _dateKey(monday.add(Duration(days: i))),
          ),
          status: 'done',
        );
        await seedLogs(
          routineId: 'sleep',
          dates: List<String>.generate(
            2,
            (i) => _dateKey(monday.add(Duration(days: i))),
          ),
          status: 'done',
        );
      },
      build: () => InsightsBloc(appDatabase: appDatabase),
      act: (InsightsBloc bloc) => bloc.add(const InsightsStarted()),
      wait: const Duration(milliseconds: 100),
      verify: (InsightsBloc bloc) {
        expect(bloc.state.mostCompletedRoutine?.routineId, 'water');
      },
    );

    blocTest<InsightsBloc, InsightsState>(
      'streak is zero when no completed days',
      build: () => InsightsBloc(appDatabase: appDatabase),
      act: (InsightsBloc bloc) => bloc.add(const InsightsStarted()),
      wait: const Duration(milliseconds: 100),
      verify: (InsightsBloc bloc) {
        // After loading completes, streak should be 0.
        expect(bloc.state.streak, 0);
        expect(bloc.state.status, InsightsStatus.success);
      },
    );
  });
}

String _dateKey(DateTime date) {
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}
