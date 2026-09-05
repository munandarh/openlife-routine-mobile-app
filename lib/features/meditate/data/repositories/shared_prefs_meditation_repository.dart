import 'dart:convert';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/domain/repositories/meditation_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsMeditationRepository implements MeditationRepository {
  SharedPrefsMeditationRepository(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const String _sessionsKey = 'meditation.sessions';
  static const String _lastUsedExhaleKey = 'meditation.last_used_exhale';

  Future<void> _writes = Future<void>.value();

  @override
  Future<void> saveSession(MeditationSession session) {
    final write = _writes.then((_) => _saveSession(session));
    _writes = write.catchError((Object _) {});
    return write;
  }

  Future<void> _saveSession(MeditationSession session) async {
    final List<MeditationSession> currentSessions = await getSessions();
    final int existingIndex = currentSessions.indexWhere(
      (MeditationSession s) => s.id == session.id,
    );

    final List<MeditationSession> updated = List<MeditationSession>.from(
      currentSessions,
    );
    if (existingIndex >= 0) {
      updated[existingIndex] = session;
    } else {
      updated.insert(0, session);
    }

    final String encoded = jsonEncode(
      updated.map((MeditationSession s) => s.toJson()).toList(),
    );
    await _preferences.setString(_sessionsKey, encoded);
  }

  @override
  Future<List<MeditationSession>> getSessions() async {
    final String? raw = await _preferences.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) {
      return <MeditationSession>[];
    }

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (dynamic item) =>
                MeditationSession.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (error) {
      throw FormatException('Meditation history could not be read', error);
    }
  }

  @override
  Future<int> getDailyAnxietyBreathCompletedCount(DateTime date) async {
    final List<MeditationSession> sessions = await getSessions();
    return sessions.where((MeditationSession s) {
      final local = (s.completedAt ?? s.startedAt).toLocal();
      return s.status == 'completed' &&
          s.type == 'anxiety_breath' &&
          local.year == date.year &&
          local.month == date.month &&
          local.day == date.day;
    }).length;
  }

  @override
  Future<int> getLastUsedExhaleSeconds() async {
    final int? seconds = await _preferences.getInt(_lastUsedExhaleKey);
    return [7, 12, 21].contains(seconds) ? seconds! : 7;
  }

  @override
  Future<void> setLastUsedExhaleSeconds(int seconds) async {
    if (![7, 12, 21].contains(seconds)) throw ArgumentError.value(seconds);
    await _preferences.setInt(_lastUsedExhaleKey, seconds);
  }
}
