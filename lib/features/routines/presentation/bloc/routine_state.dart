part of 'routine_bloc.dart';

enum RoutineStatus { initial, loading, success, failure }

class RoutineState extends Equatable {
  const RoutineState({
    required this.status,
    required this.routines,
    required this.selectedRoutine,
    required this.errorMessage,
    required this.saved,
    required this.deleted,
  });

  const RoutineState.initial()
    : status = RoutineStatus.initial,
      routines = const <Routine>[],
      selectedRoutine = null,
      errorMessage = null,
      saved = false,
      deleted = false;

  final RoutineStatus status;
  final List<Routine> routines;
  final Routine? selectedRoutine;
  final String? errorMessage;
  final bool saved;
  final bool deleted;

  RoutineState copyWith({
    RoutineStatus? status,
    List<Routine>? routines,
    Routine? selectedRoutine,
    String? errorMessage,
    bool? saved,
    bool? deleted,
    bool clearSelectedRoutine = false,
    bool clearErrorMessage = false,
  }) {
    return RoutineState(
      status: status ?? this.status,
      routines: routines ?? this.routines,
      selectedRoutine: clearSelectedRoutine
          ? null
          : (selectedRoutine ?? this.selectedRoutine),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      saved: saved ?? this.saved,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    routines,
    selectedRoutine,
    errorMessage,
    saved,
    deleted,
  ];
}
