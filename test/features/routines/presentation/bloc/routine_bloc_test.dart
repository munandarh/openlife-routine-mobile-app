import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/usecases/create_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/delete_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/get_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/update_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/watch_routines_use_case.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';

void main() {
  group('RoutineBloc', () {
    late _FakeRoutineRepository repository;

    setUp(() {
      repository = _FakeRoutineRepository();
    });

    blocTest<RoutineBloc, RoutineState>(
      'emits failure when creating a routine with blank title',
      build: () => _buildBloc(repository),
      act: (RoutineBloc bloc) {
        bloc.add(
          const RoutineCreateRequested(
            title: '   ',
            category: RoutineCategory.water,
            reminderTime: '08:00',
            repeatDays: <int>[1, 3, 5],
          ),
        );
      },
      expect: () => <Matcher>[
        isA<RoutineState>()
            .having(
              (RoutineState state) => state.status,
              'status',
              RoutineStatus.failure,
            )
            .having((RoutineState state) => state.saved, 'saved', false)
            .having(
              (RoutineState state) => state.errorMessage,
              'errorMessage',
              contains('required'),
            ),
      ],
    );

    blocTest<RoutineBloc, RoutineState>(
      'creates a routine and exposes it in the success state',
      build: () => _buildBloc(repository),
      act: (RoutineBloc bloc) {
        bloc.add(
          const RoutineCreateRequested(
            title: 'Morning Water',
            category: RoutineCategory.water,
            reminderTime: '08:00',
            repeatDays: <int>[1, 2, 3],
          ),
        );
      },
      expect: () => <Matcher>[
        isA<RoutineState>()
            .having(
              (RoutineState state) => state.status,
              'status',
              RoutineStatus.success,
            )
            .having((RoutineState state) => state.saved, 'saved', true)
            .having(
              (RoutineState state) => state.selectedRoutine?.title,
              'selectedRoutine.title',
              'Morning Water',
            )
            .having(
              (RoutineState state) => state.selectedRoutine?.repeatDays,
              'selectedRoutine.repeatDays',
              <int>[1, 2, 3],
            ),
      ],
      verify: (_) async {
        final List<Routine> routines = await repository.watchRoutines().first;
        expect(routines, hasLength(1));
        expect(routines.single.title, 'Morning Water');
      },
    );
  });
}

RoutineBloc _buildBloc(RoutineRepository repository) {
  return RoutineBloc(
    watchRoutinesUseCase: WatchRoutinesUseCase(repository),
    createRoutineUseCase: CreateRoutineUseCase(repository),
    updateRoutineUseCase: UpdateRoutineUseCase(repository),
    deleteRoutineUseCase: DeleteRoutineUseCase(repository),
    getRoutineUseCase: GetRoutineUseCase(repository),
    notificationService: AppNotificationService.noop(),
  );
}

class _FakeRoutineRepository implements RoutineRepository {
  final List<Routine> _routines = <Routine>[];
  final StreamController<List<Routine>> _controller =
      StreamController<List<Routine>>.broadcast();

  @override
  Future<void> createRoutine(Routine routine) async {
    _routines.add(routine);
    _emit();
  }

  @override
  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((Routine routine) => routine.id == id);
    _emit();
  }

  @override
  Future<Routine?> getRoutineById(String id) async {
    for (final Routine routine in _routines) {
      if (routine.id == id) {
        return routine;
      }
    }
    return null;
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    final int index = _routines.indexWhere(
      (Routine currentRoutine) => currentRoutine.id == routine.id,
    );
    if (index == -1) {
      return;
    }
    _routines[index] = routine;
    _emit();
  }

  @override
  Stream<List<Routine>> watchRoutines() async* {
    yield List<Routine>.unmodifiable(_routines);
    yield* _controller.stream;
  }

  void _emit() {
    _controller.add(List<Routine>.unmodifiable(_routines));
  }
}
