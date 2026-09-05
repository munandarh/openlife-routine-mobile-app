import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/domain/repositories/meditation_repository.dart';

class FakeMeditationRepository implements MeditationRepository {
  FakeMeditationRepository({
    List<MeditationSession>? initialSessions,
    int initialExhaleSeconds = 7,
  }) : _sessions = List<MeditationSession>.from(initialSessions ?? <MeditationSession>[]),
       _lastUsedExhale = initialExhaleSeconds;

  final List<MeditationSession> _sessions;
  int _lastUsedExhale;

  @override
  Future<void> saveSession(MeditationSession session) async {
    final int index = _sessions.indexWhere((MeditationSession s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
  }

  @override
  Future<List<MeditationSession>> getSessions() async {
    return List<MeditationSession>.unmodifiable(_sessions);
  }

  @override
  Future<int> getDailyAnxietyBreathCompletedCount(DateTime date) async {
    return _sessions.where((MeditationSession s) {
      return s.status == 'completed' &&
          s.type == 'anxiety_breath' &&
          s.startedAt.year == date.year &&
          s.startedAt.month == date.month &&
          s.startedAt.day == date.day;
    }).length;
  }

  @override
  Future<int> getLastUsedExhaleSeconds() async {
    return _lastUsedExhale;
  }

  @override
  Future<void> setLastUsedExhaleSeconds(int seconds) async {
    _lastUsedExhale = seconds;
  }
}
