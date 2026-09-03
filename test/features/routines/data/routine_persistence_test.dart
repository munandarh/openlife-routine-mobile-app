import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart'
    show AppDatabase;
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';

/// Round-trip coverage for the fields that used to be dropped on the way to or
/// from the database: notes, the icon override and the snooze duration.
void main() {
  late AppDatabase appDatabase;
  late RoutineRepository repository;

  final DateTime now = DateTime(2026, 7, 1, 8);

  Routine buildRoutine({
    String? notes,
    String? iconKey,
    int snoozeMinutes = 10,
  }) {
    return Routine(
      id: 'r1',
      title: 'Vitamin D3',
      category: RoutineCategory.vitamin,
      reminderTimes: <String>['08:30'],
      repeatDays: const <int>[1, 3, 5],
      isEnabled: true,
      snoozeMinutes: snoozeMinutes,
      iconKey: iconKey,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRoutineRepository(RoutineLocalDataSource(appDatabase));
  });

  tearDown(() async {
    await appDatabase.close();
  });

  group('create', () {
    test('persists notes, icon override and snooze duration', () async {
      await repository.createRoutine(
        buildRoutine(
          notes: 'Take with food',
          iconKey: 'medication',
          snoozeMinutes: 25,
        ),
      );

      final Routine? loaded = await repository.getRoutineById('r1');
      expect(loaded, isNotNull);
      expect(loaded!.notes, 'Take with food');
      expect(loaded.iconKey, 'medication');
      expect(loaded.snoozeMinutes, 25);
    });

    test('leaves optional fields null when not provided', () async {
      await repository.createRoutine(buildRoutine());

      final Routine loaded = (await repository.getRoutineById('r1'))!;
      expect(loaded.notes, isNull);
      expect(loaded.iconKey, isNull);
      expect(loaded.snoozeMinutes, 10);
    });
  });

  group('update', () {
    test('keeps an edited note instead of dropping it', () async {
      await repository.createRoutine(buildRoutine(notes: 'Original'));

      await repository.updateRoutine(
        buildRoutine(notes: 'Edited note').copyWith(updatedAt: now),
      );

      final Routine loaded = (await repository.getRoutineById('r1'))!;
      expect(loaded.notes, 'Edited note');
    });

    test('can clear a note', () async {
      await repository.createRoutine(buildRoutine(notes: 'Original'));

      await repository.updateRoutine(buildRoutine());

      final Routine loaded = (await repository.getRoutineById('r1'))!;
      expect(loaded.notes, isNull);
    });

    test('persists a changed snooze duration', () async {
      await repository.createRoutine(buildRoutine(snoozeMinutes: 10));

      await repository.updateRoutine(buildRoutine(snoozeMinutes: 45));

      final Routine loaded = (await repository.getRoutineById('r1'))!;
      expect(loaded.snoozeMinutes, 45);
    });

    test('persists a changed icon override', () async {
      await repository.createRoutine(buildRoutine(iconKey: 'star'));

      await repository.updateRoutine(buildRoutine(iconKey: 'local_cafe'));

      final Routine loaded = (await repository.getRoutineById('r1'))!;
      expect(loaded.iconKey, 'local_cafe');
    });
  });

  group('watchRoutines', () {
    test('emits the optional fields too', () async {
      await repository.createRoutine(
        buildRoutine(notes: 'With food', iconKey: 'medication'),
      );

      final List<Routine> routines = await repository.watchRoutines().first;
      expect(routines.single.notes, 'With food');
      expect(routines.single.iconKey, 'medication');
    });
  });
}
