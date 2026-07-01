import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/usecases/create_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/delete_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/get_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/update_routine_use_case.dart';
import 'package:openlife_routine/features/routines/domain/usecases/watch_routines_use_case.dart';

part 'routine_event.dart';
part 'routine_state.dart';

class RoutineBloc extends Bloc<RoutineEvent, RoutineState> {
  RoutineBloc({
    required WatchRoutinesUseCase watchRoutinesUseCase,
    required CreateRoutineUseCase createRoutineUseCase,
    required UpdateRoutineUseCase updateRoutineUseCase,
    required DeleteRoutineUseCase deleteRoutineUseCase,
    required GetRoutineUseCase getRoutineUseCase,
    required AppNotificationService notificationService,
  }) : _watchRoutinesUseCase = watchRoutinesUseCase,
       _createRoutineUseCase = createRoutineUseCase,
       _updateRoutineUseCase = updateRoutineUseCase,
       _deleteRoutineUseCase = deleteRoutineUseCase,
       _getRoutineUseCase = getRoutineUseCase,
       _notificationService = notificationService,
       super(const RoutineState.initial()) {
    on<RoutineWatchRequested>(_onWatchRequested);
    on<_RoutineWatchUpdated>(_onWatchUpdated);
    on<RoutineDetailRequested>(_onDetailRequested);
    on<RoutineCreateRequested>(_onCreateRequested);
    on<RoutineUpdateRequested>(_onUpdateRequested);
    on<RoutineDeleteRequested>(_onDeleteRequested);
  }

  final WatchRoutinesUseCase _watchRoutinesUseCase;
  final CreateRoutineUseCase _createRoutineUseCase;
  final UpdateRoutineUseCase _updateRoutineUseCase;
  final DeleteRoutineUseCase _deleteRoutineUseCase;
  final GetRoutineUseCase _getRoutineUseCase;
  final AppNotificationService _notificationService;
  StreamSubscription<List<Routine>>? _watchSubscription;

  @override
  Future<void> close() async {
    await _watchSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCreateRequested(
    RoutineCreateRequested event,
    Emitter<RoutineState> emit,
  ) async {
    final String trimmedTitle = event.title.trim();
    if (trimmedTitle.isEmpty) {
      emit(
        state.copyWith(
          status: RoutineStatus.failure,
          errorMessage: 'Routine name required.',
          saved: false,
          deleted: false,
        ),
      );
      return;
    }

    final DateTime now = DateTime.now();
    final Routine routine = Routine(
      id: now.microsecondsSinceEpoch.toString(),
      title: trimmedTitle,
      category: event.category,
      reminderTime: event.reminderTime,
      repeatDays: event.repeatDays,
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );

    await _createRoutineUseCase(routine);
    await _notificationService.requestPermissions();
    await _notificationService.scheduleRoutine(routine);

    emit(
      state.copyWith(
        status: RoutineStatus.success,
        selectedRoutine: routine,
        saved: true,
        deleted: false,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onDeleteRequested(
    RoutineDeleteRequested event,
    Emitter<RoutineState> emit,
  ) async {
    await _deleteRoutineUseCase(event.id);
    await _notificationService.cancelRoutine(event.id);
    emit(
      state.copyWith(
        status: RoutineStatus.success,
        deleted: true,
        saved: false,
        clearSelectedRoutine: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onDetailRequested(
    RoutineDetailRequested event,
    Emitter<RoutineState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RoutineStatus.loading,
        saved: false,
        deleted: false,
        clearErrorMessage: true,
      ),
    );

    final Routine? routine = await _getRoutineUseCase(event.id);
    if (routine == null) {
      emit(
        state.copyWith(
          status: RoutineStatus.failure,
          errorMessage: 'Routine not found.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RoutineStatus.success,
        selectedRoutine: routine,
        saved: false,
        deleted: false,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onUpdateRequested(
    RoutineUpdateRequested event,
    Emitter<RoutineState> emit,
  ) async {
    final Routine? existingRoutine = await _getRoutineUseCase(event.id);
    if (existingRoutine == null) {
      emit(
        state.copyWith(
          status: RoutineStatus.failure,
          errorMessage: 'Routine not found.',
        ),
      );
      return;
    }

    final Routine updatedRoutine = existingRoutine.copyWith(
      title: event.title.trim(),
      category: event.category,
      reminderTime: event.reminderTime,
      repeatDays: event.repeatDays,
      isEnabled: event.isEnabled,
      updatedAt: DateTime.now(),
    );

    await _updateRoutineUseCase(updatedRoutine);
    await _notificationService.requestPermissions();
    await _notificationService.scheduleRoutine(updatedRoutine);

    emit(
      state.copyWith(
        status: RoutineStatus.success,
        selectedRoutine: updatedRoutine,
        saved: true,
        deleted: false,
        clearErrorMessage: true,
      ),
    );
  }

  void _onWatchRequested(
    RoutineWatchRequested event,
    Emitter<RoutineState> emit,
  ) {
    emit(
      state.copyWith(
        status: RoutineStatus.loading,
        saved: false,
        deleted: false,
        clearErrorMessage: true,
      ),
    );
    _watchSubscription?.cancel();
    _watchSubscription = _watchRoutinesUseCase().listen((
      List<Routine> routines,
    ) {
      add(_RoutineWatchUpdated(routines));
    });
  }

  void _onWatchUpdated(_RoutineWatchUpdated event, Emitter<RoutineState> emit) {
    emit(
      state.copyWith(
        status: RoutineStatus.success,
        routines: event.routines,
        clearErrorMessage: true,
      ),
    );
  }
}
