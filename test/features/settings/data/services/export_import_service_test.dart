import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/settings/data/services/export_import_service.dart';

void main() {
  late AppDatabase appDatabase;
  late ExportImportService service;

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    service = ExportImportService(appDatabase: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  group('ExportImportService', () {
    test('export empty database returns valid JSON', () async {
      final String json = await service.exportToJson();
      final Map<String, dynamic> data =
          jsonDecode(json) as Map<String, dynamic>;

      expect(data.containsKey('routines'), true);
      expect(data.containsKey('routineSchedules'), true);
      expect(data.containsKey('routineLogs'), true);
      expect(data['routines'], isEmpty);
    });

    test('export includes seeded routines', () async {
      await appDatabase
          .into(appDatabase.routines)
          .insert(
            RoutinesCompanion(
              id: const Value('r1'),
              title: const Value('Breakfast'),
              category: const Value('meal'),
              isEnabled: const Value(true),
              createdAt: Value(DateTime(2026, 1, 1)),
              updatedAt: Value(DateTime(2026, 1, 1)),
            ),
          );

      final String json = await service.exportToJson();
      final Map<String, dynamic> data =
          jsonDecode(json) as Map<String, dynamic>;
      final List<dynamic> routines = data['routines'] as List<dynamic>;

      expect(routines.length, 1);
      expect((routines[0] as Map<String, dynamic>)['title'], 'Breakfast');
    });

    test('export includes logs', () async {
      await appDatabase.upsertRoutineLog(
        routineId: 'r1',
        dateKey: '2026-01-01',
        status: 'done',
      );

      final String json = await service.exportToJson();
      final Map<String, dynamic> data =
          jsonDecode(json) as Map<String, dynamic>;
      final List<dynamic> logs = data['routineLogs'] as List<dynamic>;

      expect(logs.length, 1);
    });

    test('import valid JSON restores routines', () async {
      const String importJson =
          '{'
          '"routines":[{"id":"imp1","title":"Imported","category":"custom","isEnabled":true,"createdAt":"2026-01-01T00:00:00.000","updatedAt":"2026-01-01T00:00:00.000"}],'
          '"routineSchedules":[],'
          '"routineLogs":[]'
          '}';

      final int count = await service.importFromJson(importJson);
      expect(count, greaterThan(0));

      final List<RoutineRowData> routines = await appDatabase
          .select(appDatabase.routines)
          .get();
      expect(routines.any((r) => r.title == 'Imported'), true);
    });

    test('import invalid JSON throws', () async {
      expect(
        () => service.importFromJson('not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('import returns count of imported items', () async {
      const String importJson =
          '{'
          '"routines":[{"id":"a","title":"A","category":"meal","isEnabled":true,"createdAt":"2026-01-01T00:00:00.000","updatedAt":"2026-01-01T00:00:00.000"},{"id":"b","title":"B","category":"water","isEnabled":true,"createdAt":"2026-01-01T00:00:00.000","updatedAt":"2026-01-01T00:00:00.000"}],'
          '"routineSchedules":[],'
          '"routineLogs":[]'
          '}';

      final int count = await service.importFromJson(importJson);
      expect(count, 2);
    });

    test('round-trip: export then import restores data', () async {
      // Seed data.
      await appDatabase
          .into(appDatabase.routines)
          .insert(
            RoutinesCompanion(
              id: const Value('rt1'),
              title: const Value('Round Trip'),
              category: const Value('exercise'),
              isEnabled: const Value(true),
              createdAt: Value(DateTime(2026, 6, 1)),
              updatedAt: Value(DateTime(2026, 6, 1)),
            ),
          );
      await appDatabase
          .into(appDatabase.routineSchedules)
          .insert(
            RoutineSchedulesCompanion(
              id: const Value('s1'),
              routineId: const Value('rt1'),
              reminderTime: const Value('08:00'),
              repeatDays: Value(jsonEncode(<int>[1, 3, 5])),
              snoozeMinutes: const Value(10),
              updatedAt: Value(DateTime(2026, 6, 1)),
            ),
          );

      // Export.
      final String exported = await service.exportToJson();

      // Clear DB.
      await appDatabase.delete(appDatabase.routines).go();
      await appDatabase.delete(appDatabase.routineSchedules).go();

      // Import.
      await service.importFromJson(exported);

      // Verify.
      final List<RoutineRowData> routines = await appDatabase
          .select(appDatabase.routines)
          .get();
      expect(routines.length, 1);
      expect(routines[0].title, 'Round Trip');
    });
  });
}
