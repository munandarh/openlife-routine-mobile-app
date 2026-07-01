import 'package:openlife_routine/features/routines/domain/entities/routine.dart';

abstract interface class RoutineRepository {
  Future<Routine?> getRoutineById(String id);

  Stream<List<Routine>> watchRoutines();

  Future<void> createRoutine(Routine routine);

  Future<void> updateRoutine(Routine routine);

  Future<void> deleteRoutine(String id);
}
