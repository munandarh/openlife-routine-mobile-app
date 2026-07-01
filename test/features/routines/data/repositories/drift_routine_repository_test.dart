import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart'
    as domain;

void main() {
  group('DriftRoutineRepository', () {
    late Directory tempDirectory;
    late File databaseFile;
    late AppDatabase appDatabase;
    late DriftRoutineRepository repository;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'openlife-routine-repository-test',
      );
      databaseFile = File('${tempDirectory.path}/openlife_test.sqlite');
      appDatabase = AppDatabase.forTesting(NativeDatabase(databaseFile));
      repository = DriftRoutineRepository(RoutineLocalDataSource(appDatabase));
    });

    tearDown(() async {
      await appDatabase.close();
      if (tempDirectory.existsSync()) {
        tempDirectory.deleteSync(recursive: true);
      }
    });

    test('creates and updates a routine', () async {
      final domain.Routine routine = _buildRoutine();

      await repository.createRoutine(routine);

      final domain.Routine? storedRoutine = await repository.getRoutineById(
        routine.id,
      );
      expect(storedRoutine, isNotNull);
      expect(storedRoutine?.title, 'Morning Water');
      expect(storedRoutine?.repeatDays, <int>[1, 2, 3]);

      final domain.Routine updatedRoutine = routine.copyWith(
        title: 'Morning Hydration',
        reminderTime: '09:15',
        repeatDays: <int>[2, 4, 6],
        updatedAt: DateTime(2026, 7, 1, 9, 15),
      );

      await repository.updateRoutine(updatedRoutine);

      final domain.Routine? reloadedRoutine = await repository.getRoutineById(
        routine.id,
      );
      expect(reloadedRoutine, isNotNull);
      expect(reloadedRoutine?.title, 'Morning Hydration');
      expect(reloadedRoutine?.reminderTime, '09:15');
      expect(reloadedRoutine?.repeatDays, <int>[2, 4, 6]);
    });

    test('deletes a routine', () async {
      final domain.Routine routine = _buildRoutine();

      await repository.createRoutine(routine);
      await repository.deleteRoutine(routine.id);

      final domain.Routine? storedRoutine = await repository.getRoutineById(
        routine.id,
      );
      expect(storedRoutine, isNull);
    });

    test('keeps routine data after database reopen', () async {
      final domain.Routine routine = _buildRoutine();

      await repository.createRoutine(routine);
      await appDatabase.close();

      appDatabase = AppDatabase.forTesting(NativeDatabase(databaseFile));
      repository = DriftRoutineRepository(RoutineLocalDataSource(appDatabase));

      final domain.Routine? storedRoutine = await repository.getRoutineById(
        routine.id,
      );
      expect(storedRoutine, isNotNull);
      expect(storedRoutine?.title, 'Morning Water');
      expect(storedRoutine?.reminderTime, '08:00');
      expect(storedRoutine?.repeatDays, <int>[1, 2, 3]);
    });
  });
}

domain.Routine _buildRoutine() {
  return domain.Routine(
    id: 'routine-1',
    title: 'Morning Water',
    category: domain.RoutineCategory.water,
    reminderTime: '08:00',
    repeatDays: const <int>[1, 2, 3],
    isEnabled: true,
    createdAt: DateTime(2026, 7, 1, 8),
    updatedAt: DateTime(2026, 7, 1, 8),
  );
}
