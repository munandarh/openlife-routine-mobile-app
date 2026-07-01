import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';

class GetRoutineUseCase {
  const GetRoutineUseCase(this._repository);

  final RoutineRepository _repository;

  Future<Routine?> call(String id) {
    return _repository.getRoutineById(id);
  }
}
