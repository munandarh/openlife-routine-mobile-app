import 'package:equatable/equatable.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';

enum MeditateStatus { initial, loading, loaded, failure }

class MeditateState extends Equatable {
  const MeditateState({
    this.status = MeditateStatus.initial,
    this.anxietyBreathCompletedToday = 0,
    this.anxietyBreathTarget = 5,
    this.lastUsedExhale = 7,
    this.recentSessions = const <MeditationSession>[],
    this.errorMessage,
  });

  final MeditateStatus status;
  final int anxietyBreathCompletedToday;
  final int anxietyBreathTarget;
  final int lastUsedExhale;
  final List<MeditationSession> recentSessions;
  final String? errorMessage;

  bool get isTargetReached =>
      anxietyBreathCompletedToday >= anxietyBreathTarget;

  MeditateState copyWith({
    MeditateStatus? status,
    int? anxietyBreathCompletedToday,
    int? anxietyBreathTarget,
    int? lastUsedExhale,
    List<MeditationSession>? recentSessions,
    String? errorMessage,
  }) {
    return MeditateState(
      status: status ?? this.status,
      anxietyBreathCompletedToday:
          anxietyBreathCompletedToday ?? this.anxietyBreathCompletedToday,
      anxietyBreathTarget: anxietyBreathTarget ?? this.anxietyBreathTarget,
      lastUsedExhale: lastUsedExhale ?? this.lastUsedExhale,
      recentSessions: recentSessions ?? this.recentSessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    anxietyBreathCompletedToday,
    anxietyBreathTarget,
    lastUsedExhale,
    recentSessions,
    errorMessage,
  ];
}
