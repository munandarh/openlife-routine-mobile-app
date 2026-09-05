import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/meditate/data/repositories/shared_prefs_meditation_repository.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_preferences.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_session_writer.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryPreferences extends Mock implements SharedPreferencesAsync {}

void main() {
  late MemoryPreferences prefs;
  late SharedPrefsMeditationRepository repo;
  late AppDatabase db;
  late Map<String, Object> storage;
  final end = DateTime(2026, 9, 6, 0, 3);
  MeditationSession session(
    String id, {
    String status = 'completed',
    String type = 'anxiety_breath',
    bool linked = false,
  }) => MeditationSession(
    id: id,
    type: type,
    source: linked ? 'routine' : 'manual',
    inhaleSec: 3,
    exhaleSec: 7,
    plannedDurationSec: 420,
    actualDurationSec: status == 'completed' ? 420 : 30,
    status: status,
    startedAt: end.subtract(const Duration(minutes: 7)),
    completedAt: status == 'completed' ? end : null,
    routineId: linked ? 'r1' : null,
    occurrenceId: linked ? 'r1|2026-09-05|23:56' : null,
  );
  setUp(() async {
    storage = {};
    prefs = MemoryPreferences();
    when(
      () => prefs.getString(any()),
    ).thenAnswer((i) async => storage[i.positionalArguments[0]] as String?);
    when(() => prefs.setString(any(), any())).thenAnswer((i) async {
      storage[i.positionalArguments[0] as String] =
          i.positionalArguments[1] as String;
    });
    when(
      () => prefs.getInt(any()),
    ).thenAnswer((i) async => storage[i.positionalArguments[0]] as int?);
    when(() => prefs.setInt(any(), any())).thenAnswer((i) async {
      storage[i.positionalArguments[0] as String] =
          i.positionalArguments[1] as int;
    });
    when(() => prefs.getStringList(any())).thenAnswer(
      (i) async => storage[i.positionalArguments[0]] as List<String>?,
    );
    when(() => prefs.setStringList(any(), any())).thenAnswer((i) async {
      storage[i.positionalArguments[0] as String] =
          i.positionalArguments[1] as List<String>;
    });
    repo = SharedPrefsMeditationRepository(prefs);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.routines)
        .insert(
          RoutinesCompanion.insert(
            id: 'r1',
            title: 'Breathing',
            category: 'anxietyBreath',
            createdAt: end,
            updatedAt: end,
          ),
        );
    await db
        .into(db.routineSchedules)
        .insert(
          RoutineSchedulesCompanion.insert(
            id: 'r1_schedule',
            routineId: 'r1',
            reminderTime: '08:00,11:00,14:00,17:00,23:56',
            repeatDays: '[1,2,3,4,5,6,7]',
            updatedAt: end,
          ),
        );
  });
  tearDown(() async => db.close());
  test(
    'concurrent saves survive reopen and mood edits do not duplicate sessions',
    () async {
      await Future.wait([
        repo.saveSession(session('a')),
        repo.saveSession(session('b')),
      ]);
      await repo.saveSession(session('a').copyWith(mood: 'calmer'));
      final reopened = SharedPrefsMeditationRepository(prefs);
      expect((await reopened.getSessions()).length, 2);
      expect(
        (await reopened.getSessions()).firstWhere((s) => s.id == 'a').mood,
        'calmer',
      );
    },
  );
  test(
    'completion date owns daily count, general and abandoned sessions do not count',
    () async {
      for (var i = 0; i < 6; i++) {
        await repo.saveSession(session('$i'));
      }
      await repo.saveSession(session('early', status: 'abandoned'));
      await repo.saveSession(session('general', type: 'focus'));
      expect(await repo.getDailyAnxietyBreathCompletedCount(end), 6);
      expect(
        await repo.getDailyAnxietyBreathCompletedCount(DateTime(2026, 9, 5)),
        0,
      );
    },
  );
  test(
    'completion links only the original dated occurrence, retry is idempotent',
    () async {
      final writer = MeditationSessionWriter(repo, db);
      await writer.save(
        session('linked', linked: true),
        occurrenceDate: '2026-09-05',
        reminderTime: '23:56',
      );
      await writer.save(
        session('linked', linked: true),
        occurrenceDate: '2026-09-05',
        reminderTime: '23:56',
      );
      expect(
        (await db.getRoutineLogsByDate('2026-09-05')).single.reminderTime,
        '23:56',
      );
      expect(await db.getRoutineLogsByDate('2026-09-06'), isEmpty);
      expect((await repo.getSessions()).length, 1);
    },
  );
  test(
    'manual, abandoned and premature sessions cannot complete a reminder',
    () async {
      final writer = MeditationSessionWriter(repo, db);
      await writer.save(
        session('manual'),
        occurrenceDate: '2026-09-05',
        reminderTime: '23:56',
      );
      await writer.save(
        session('early', linked: true, status: 'abandoned'),
        occurrenceDate: '2026-09-05',
        reminderTime: '23:56',
      );
      await expectLater(
        writer.save(
          session('invalid', linked: true).copyWith(actualDurationSec: 419),
          occurrenceDate: '2026-09-05',
          reminderTime: '23:56',
        ),
        throwsArgumentError,
      );
      expect(await db.getRoutineLogsByDate('2026-09-05'), isEmpty);
    },
  );
  test(
    'corrupt history surfaces error without overwriting user data',
    () async {
      storage['meditation.sessions'] = 'broken';
      await expectLater(repo.saveSession(session('a')), throwsFormatException);
      expect(storage['meditation.sessions'], 'broken');
    },
  );
  test(
    'favorites survive a new preferences service and last exhale is validated',
    () async {
      await MeditationPreferences(prefs).saveFavorites({'focus', 'sleep'});
      expect(await MeditationPreferences(prefs).favorites(), {
        'focus',
        'sleep',
      });
      await repo.setLastUsedExhaleSeconds(21);
      expect(
        await SharedPrefsMeditationRepository(prefs).getLastUsedExhaleSeconds(),
        21,
      );
      await expectLater(repo.setLastUsedExhaleSeconds(9), throwsArgumentError);
      storage['meditation.last_used_exhale'] = 99;
      expect(await repo.getLastUsedExhaleSeconds(), 7);
    },
  );
}
