import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/domain/repositories/meditation_repository.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_event.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_state.dart';

class MeditateBloc extends Bloc<MeditateEvent, MeditateState> {
  MeditateBloc({required this.repository}) : super(const MeditateState()) {
    on<MeditateStarted>(_onStarted);
    on<MeditateRefreshRequested>(_onRefreshRequested);
  }

  final MeditationRepository repository;

  Future<void> _onStarted(
    MeditateStarted event,
    Emitter<MeditateState> emit,
  ) async {
    emit(state.copyWith(status: MeditateStatus.loading));
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    MeditateRefreshRequested event,
    Emitter<MeditateState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<MeditateState> emit) async {
    try {
      final DateTime now = DateTime.now();
      final int completedToday = await repository
          .getDailyAnxietyBreathCompletedCount(now);
      final int lastExhale = await repository.getLastUsedExhaleSeconds();
      final List<MeditationSession> sessions = List.of(
        await repository.getSessions(),
      )..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      emit(
        state.copyWith(
          status: MeditateStatus.loaded,
          anxietyBreathCompletedToday: completedToday,
          lastUsedExhale: lastExhale,
          recentSessions: sessions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeditateStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
