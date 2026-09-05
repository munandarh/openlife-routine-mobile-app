import 'package:equatable/equatable.dart';

class MeditationSession extends Equatable {
  const MeditationSession({
    required this.id,
    required this.type,
    required this.source,
    required this.inhaleSec,
    required this.exhaleSec,
    required this.plannedDurationSec,
    required this.actualDurationSec,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.routineId,
    this.occurrenceId,
    this.mood,
  });

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'anxiety_breath',
      source: json['source'] as String? ?? 'manual',
      inhaleSec: json['inhaleSec'] as int? ?? 3,
      exhaleSec: json['exhaleSec'] as int? ?? 7,
      plannedDurationSec: json['plannedDurationSec'] as int? ?? 420,
      actualDurationSec: json['actualDurationSec'] as int? ?? 420,
      status: json['status'] as String? ?? 'completed',
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      routineId: json['routineId'] as String?,
      occurrenceId: json['occurrenceId'] as String?,
      mood: json['mood'] as String?,
    );
  }

  final String id;
  final String type;
  final String source;
  final int inhaleSec;
  final int exhaleSec;
  final int plannedDurationSec;
  final int actualDurationSec;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? routineId;
  final String? occurrenceId;
  final String? mood;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'source': source,
      'inhaleSec': inhaleSec,
      'exhaleSec': exhaleSec,
      'plannedDurationSec': plannedDurationSec,
      'actualDurationSec': actualDurationSec,
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'routineId': routineId,
      'occurrenceId': occurrenceId,
      'mood': mood,
    };
  }

  MeditationSession copyWith({
    String? id,
    String? type,
    String? source,
    int? inhaleSec,
    int? exhaleSec,
    int? plannedDurationSec,
    int? actualDurationSec,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? routineId,
    String? occurrenceId,
    String? mood,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      inhaleSec: inhaleSec ?? this.inhaleSec,
      exhaleSec: exhaleSec ?? this.exhaleSec,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      routineId: routineId ?? this.routineId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      mood: mood ?? this.mood,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    type,
    source,
    inhaleSec,
    exhaleSec,
    plannedDurationSec,
    actualDurationSec,
    status,
    startedAt,
    completedAt,
    routineId,
    occurrenceId,
    mood,
  ];
}
