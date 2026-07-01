import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';

class DriftRoutineRepository implements RoutineRepository {
  DriftRoutineRepository(this._localDataSource);

  final RoutineLocalDataSource _localDataSource;

  @override
  Future<void> createRoutine(Routine routine) {
    return _localDataSource.createRoutine(routine);
  }

  @override
  Future<void> deleteRoutine(String id) {
    return _localDataSource.deleteRoutine(id);
  }

  @override
  Future<Routine?> getRoutineById(String id) {
    return _localDataSource.getRoutineById(id);
  }

  @override
  Future<void> updateRoutine(Routine routine) {
    return _localDataSource.updateRoutine(routine);
  }

  @override
  Stream<List<Routine>> watchRoutines() {
    return _localDataSource.watchRoutines();
  }
}
