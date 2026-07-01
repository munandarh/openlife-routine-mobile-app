import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';

class DeleteRoutineUseCase {
  const DeleteRoutineUseCase(this._repository);

  final RoutineRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteRoutine(id);
  }
}
