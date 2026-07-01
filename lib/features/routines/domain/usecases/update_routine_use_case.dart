import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';

class UpdateRoutineUseCase {
  const UpdateRoutineUseCase(this._repository);

  final RoutineRepository _repository;

  Future<void> call(Routine routine) {
    return _repository.updateRoutine(routine);
  }
}
