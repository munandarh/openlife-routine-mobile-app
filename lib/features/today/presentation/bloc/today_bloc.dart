import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';

part 'today_event.dart';
part 'today_state.dart';

class TodayBloc extends Bloc<TodayEvent, TodayState> {
  TodayBloc({
    required AppDatabase appDatabase,
    DateTime Function()? nowProvider,
  }) : _appDatabase = appDatabase,
       _nowProvider = nowProvider ?? DateTime.now,
       super(
         TodayState.initial(
           _normalizeDate(nowProvider?.call() ?? DateTime.now()),
         ),
       ) {
    on<TodayStarted>(_onStarted);
    on<TodayDateSelected>(_onDateSelected);
    on<TodayRoutineCompletionToggled>(_onRoutineCompletionToggled);
    on<TodayRoutineSkipped>(_onRoutineSkipped);
  }

  final AppDatabase _appDatabase;
  final DateTime Function() _nowProvider;
  List<RoutineBundleRow> _routineBundles = <RoutineBundleRow>[];

  Future<void> _onStarted(TodayStarted event, Emitter<TodayState> emit) async {
    emit(state.copyWith(status: TodayStatus.loading, clearErrorMessage: true));
    _routineBundles = await _appDatabase.getRoutineBundles();
    await _emitSelectedDateState(emit, selectedDate: state.selectedDate);
  }

  Future<void> _onDateSelected(
    TodayDateSelected event,
    Emitter<TodayState> emit,
  ) async {
    await _emitSelectedDateState(
      emit,
      selectedDate: _normalizeDate(event.selectedDate),
    );
  }

  Future<void> _onRoutineCompletionToggled(
    TodayRoutineCompletionToggled event,
    Emitter<TodayState> emit,
  ) async {
    final TodayRoutineItem? item = state.findItem(event.routineId);
    if (item == null) {
      return;
    }

    final String dateKey = _dateKey(state.selectedDate);
    if (item.status == TodayRoutineItemStatus.done) {
      await _appDatabase.deleteRoutineLog(event.routineId, dateKey);
    } else {
      await _appDatabase.upsertRoutineLog(
        routineId: event.routineId,
        dateKey: dateKey,
        status: 'done',
      );
    }

    await _emitSelectedDateState(emit, selectedDate: state.selectedDate);
  }

  Future<void> _onRoutineSkipped(
    TodayRoutineSkipped event,
    Emitter<TodayState> emit,
  ) async {
    final TodayRoutineItem? item = state.findItem(event.routineId);
    if (item == null) {
      return;
    }

    final String dateKey = _dateKey(state.selectedDate);
    if (item.status == TodayRoutineItemStatus.skipped) {
      await _appDatabase.deleteRoutineLog(event.routineId, dateKey);
    } else {
      await _appDatabase.upsertRoutineLog(
        routineId: event.routineId,
        dateKey: dateKey,
        status: 'skipped',
      );
    }

    await _emitSelectedDateState(emit, selectedDate: state.selectedDate);
  }

  Future<void> _emitSelectedDateState(
    Emitter<TodayState> emit, {
    required DateTime selectedDate,
  }) async {
    final String dateKey = _dateKey(selectedDate);
    final Map<String, RoutineLogRowData> logsByRoutineId =
        <String, RoutineLogRowData>{
          for (final RoutineLogRowData log
              in await _appDatabase.getRoutineLogsByDate(dateKey))
            log.routineId: log,
        };
    final DateTime now = _normalizeDate(_nowProvider());
    final String currentTimeLabel = _timeKey(_nowProvider());

    final List<TodayRoutineItem> items =
        _routineBundles
            .where(
              (bundle) =>
                  bundle.routine.isEnabled &&
                  _repeatDays(
                    bundle.schedule.repeatDays,
                  ).contains(selectedDate.weekday),
            )
            .map((bundle) {
              final RoutineLogRowData? log = logsByRoutineId[bundle.routine.id];
              final TodayRoutineItemStatus status = switch (log?.status) {
                'done' => TodayRoutineItemStatus.done,
                'skipped' => TodayRoutineItemStatus.skipped,
                _ => TodayRoutineItemStatus.pending,
              };
              final String reminderTime = bundle.schedule.reminderTime;

              return TodayRoutineItem(
                routineId: bundle.routine.id,
                title: bundle.routine.title,
                category: RoutineCategory.values.byName(
                  bundle.routine.category,
                ),
                reminderTime: reminderTime,
                status: status,
                isDueNow:
                    selectedDate == now &&
                    status == TodayRoutineItemStatus.pending &&
                    reminderTime.compareTo(currentTimeLabel) <= 0,
              );
            })
            .toList()
          ..sort(
            (left, right) => left.reminderTime.compareTo(right.reminderTime),
          );

    final int completedCount = items
        .where((item) => item.status == TodayRoutineItemStatus.done)
        .length;

    emit(
      state.copyWith(
        status: TodayStatus.success,
        selectedDate: selectedDate,
        items: items,
        completedCount: completedCount,
        totalCount: items.length,
        clearErrorMessage: true,
      ),
    );
  }

  static DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String _dateKey(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String _timeKey(DateTime value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static List<int> _repeatDays(String encodedRepeatDays) {
    return (jsonDecode(encodedRepeatDays) as List<dynamic>).cast<int>();
  }
}
