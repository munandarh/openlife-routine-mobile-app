import 'package:equatable/equatable.dart';

enum RoutineLogStatus { done, skipped, missed }

class RoutineLog extends Equatable {
  const RoutineLog({
    required this.id,
    required this.routineId,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String routineId;
  final DateTime date;
  final RoutineLogStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineLog copyWith({
    String? id,
    String? routineId,
    DateTime? date,
    RoutineLogStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineLog(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        routineId,
        date,
        status,
        createdAt,
        updatedAt,
      ];
}
