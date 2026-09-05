import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';

abstract class MeditationRepository {
  Future<void> saveSession(MeditationSession session);
  Future<List<MeditationSession>> getSessions();
  Future<int> getDailyAnxietyBreathCompletedCount(DateTime date);
  Future<int> getLastUsedExhaleSeconds();
  Future<void> setLastUsedExhaleSeconds(int seconds);
}
