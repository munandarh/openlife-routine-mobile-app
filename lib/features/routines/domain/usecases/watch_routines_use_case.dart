import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';

class WatchRoutinesUseCase {
  const WatchRoutinesUseCase(this._repository);

  final RoutineRepository _repository;

  Stream<List<Routine>> call() {
    return _repository.watchRoutines();
  }
}
