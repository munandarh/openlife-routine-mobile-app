import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/storage/app_database.dart';
import 'package:openlife_routine/features/insights/domain/routine_streak.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';

part 'today_event.dart';
part 'today_state.dart';

class TodayBloc extends Bloc<TodayEvent, TodayState> {
  TodayBloc({
    required AppDatabase appDatabase,
    AppNotificationService? notificationService,
    DateTime Function()? nowProvider,
  }) : _appDatabase = appDatabase,
       _notificationService = notificationService,
       _nowProvider = nowProvider ?? DateTime.now,
       super(
         TodayState.initial(
           _normalizeDate(nowProvider?.call() ?? DateTime.now()),
         ),
       ) {
    on<TodayStarted>(_onStarted);
    on<TodayRefreshRequested>(_onRefreshRequested);
    on<TodayDateSelected>(_onDateSelected);
    on<TodayRoutineCompletionToggled>(_onRoutineCompletionToggled);
    on<TodayRoutineSkipped>(_onRoutineSkipped);
    on<TodayRoutineSnoozed>(_onRoutineSnoozed);
  }

  final AppDatabase _appDatabase;

  /// Optional so unit tests can drive the bloc without a notification stack;
  /// snoozing simply skips rescheduling when it is absent.
  final AppNotificationService? _notificationService;
  final DateTime Function() _nowProvider;
  List<RoutineBundleRow> _routineBundles = <RoutineBundleRow>[];

  Future<void> _onStarted(TodayStarted event, Emitter<TodayState> emit) async {
    emit(state.copyWith(status: TodayStatus.loading, clearErrorMessage: true));
    _routineBundles = await _appDatabase.getRoutineBundles();
    await _emitSelectedDateState(emit, selectedDate: state.selectedDate);
  }

  /// Reloads the routine list and re-emits for the day already in view.
  ///
  /// Deliberately does not show the loading spinner: this runs on resume and
  /// after returning from another screen, where a flash of blank Today would
  /// be worse than a frame of slightly stale data.
  Future<void> _onRefreshRequested(
    TodayRefreshRequested event,
    Emitter<TodayState> emit,
  ) async {
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
      // Answering here should also clear the reminder still sitting in the
      // notification shade.
      await _notificationService?.dismissShownRoutine(event.routineId);
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
      await _notificationService?.dismissShownRoutine(event.routineId);
    }

    await _emitSelectedDateState(emit, selectedDate: state.selectedDate);
  }

  /// Records a snooze and re-arms the local notification for the new time.
  ///
  /// Snoozing an already-snoozed routine pushes it back again from now, which
  /// matches how the notification action behaves.
  Future<void> _onRoutineSnoozed(
    TodayRoutineSnoozed event,
    Emitter<TodayState> emit,
  ) async {
    final TodayRoutineItem? item = state.findItem(event.routineId);
    if (item == null || !item.isOpen) {
      return;
    }

    final RoutineBundleRow? bundle = _bundleFor(event.routineId);
    if (bundle == null) {
      return;
    }

    final DateTime snoozedUntil = _nowProvider().add(
      Duration(minutes: bundle.schedule.snoozeMinutes),
    );

    await _appDatabase.upsertRoutineLog(
      routineId: event.routineId,
      dateKey: _dateKey(state.selectedDate),
      status: 'snoozed',
      snoozedUntil: snoozedUntil,
    );

    await _notificationService?.scheduleSnoozedRoutine(
      routineId: event.routineId,
      title: bundle.routine.title,
      scheduledFor: snoozedUntil,
    );

    await _emitSelectedDateState(emit, selectedDate: state.selectedDate);
  }

  RoutineBundleRow? _bundleFor(String routineId) {
    for (final RoutineBundleRow bundle in _routineBundles) {
      if (bundle.routine.id == routineId) {
        return bundle;
      }
    }
    return null;
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
    final DateTime today = _normalizeDate(_nowProvider());
    final String currentTimeLabel = _timeKey(_nowProvider());
    final bool isPastDay = selectedDate.isBefore(today);

    final List<TodayRoutineItem> items =
        _routineBundles
            .where(
              (RoutineBundleRow bundle) =>
                  bundle.routine.isEnabled &&
                  _repeatDays(
                    bundle.schedule.repeatDays,
                  ).contains(selectedDate.weekday),
            )
            .map((RoutineBundleRow bundle) {
              final RoutineLogRowData? log = logsByRoutineId[bundle.routine.id];
              final TodayRoutineItemStatus status = _statusFor(
                log,
                isPastDay: isPastDay,
              );
              final String reminderTime = bundle.schedule.reminderTime;

              return TodayRoutineItem(
                routineId: bundle.routine.id,
                title: bundle.routine.title,
                category: RoutineCategory.values.byName(
                  bundle.routine.category,
                ),
                reminderTime: reminderTime,
                status: status,
                iconKey: bundle.routine.iconKey,
                snoozedUntil: status == TodayRoutineItemStatus.snoozed
                    ? log?.snoozedUntil
                    : null,
                isDueNow:
                    selectedDate == today &&
                    status == TodayRoutineItemStatus.pending &&
                    reminderTime.compareTo(currentTimeLabel) <= 0,
              );
            })
            .toList()
          ..sort(
            (TodayRoutineItem left, TodayRoutineItem right) =>
                left.reminderTime.compareTo(right.reminderTime),
          );

    final int completedCount = items
        .where((TodayRoutineItem item) => item.status == TodayRoutineItemStatus.done)
        .length;

    // The header pill shows the same number Insights does, from the same
    // rule — a second implementation here would quietly drift from it.
    final Map<String, List<RoutineLogRowData>> logsByDate =
        <String, List<RoutineLogRowData>>{};
    for (final RoutineLogRowData log in await _appDatabase.getRoutineLogsBetween(
      RoutineStreak.dateKey(today.subtract(const Duration(days: 30))),
      RoutineStreak.dateKey(today),
    )) {
      logsByDate.putIfAbsent(log.date, () => <RoutineLogRowData>[]).add(log);
    }

    emit(
      state.copyWith(
        status: TodayStatus.success,
        selectedDate: selectedDate,
        items: items,
        completedCount: completedCount,
        totalCount: items.length,
        streak: RoutineStreak.calculate(
          bundles: _routineBundles,
          logsByDate: logsByDate,
          today: today,
        ),
        hasRoutines: _routineBundles.isNotEmpty,
        clearErrorMessage: true,
      ),
    );
  }

  /// Maps a stored log to a display status.
  ///
  /// A past day with no log at all reads as `missed` even before the startup
  /// sweep has written the row, so history never shows a stale "pending".
  static TodayRoutineItemStatus _statusFor(
    RoutineLogRowData? log, {
    required bool isPastDay,
  }) {
    return switch (log?.status) {
      'done' => TodayRoutineItemStatus.done,
      'skipped' => TodayRoutineItemStatus.skipped,
      'missed' => TodayRoutineItemStatus.missed,
      'snoozed' when isPastDay => TodayRoutineItemStatus.missed,
      'snoozed' => TodayRoutineItemStatus.snoozed,
      _ when isPastDay => TodayRoutineItemStatus.missed,
      _ => TodayRoutineItemStatus.pending,
    };
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
