import 'dart:convert';

import 'package:openlife_routine/core/storage/app_database.dart';

/// Closes out past days by turning routines that were scheduled but never
/// resolved into `missed` logs.
///
/// PRD §8.5 requires a routine that is not completed by the end of its day to
/// become `missed`. There is no background worker in the MVP, so the sweep runs
/// on every app start and catches up on *every* day since the last sweep — not
/// just yesterday — which is what makes it correct after the app has been
/// closed for a while.
class MissedStateService {
  MissedStateService({
    required AppDatabase appDatabase,
    DateTime Function()? nowProvider,
    int maxLookbackDays = 30,
  }) : _appDatabase = appDatabase,
       _nowProvider = nowProvider ?? DateTime.now,
       _maxLookbackDays = maxLookbackDays;

  final AppDatabase _appDatabase;
  final DateTime Function() _nowProvider;

  /// Upper bound on how far back a single sweep reaches, so a phone that has
  /// not opened the app in months does not write a year of rows on launch.
  final int _maxLookbackDays;

  /// Marks every scheduled-but-unresolved routine as missed for each day from
  /// [since] (exclusive) through yesterday.
  ///
  /// Pass the last sweep date to resume; pass null on first run to sweep the
  /// full lookback window. Returns the number of logs written.
  Future<int> sweepMissedDays({DateTime? since}) async {
    final DateTime today = _dateOnly(_nowProvider());
    final DateTime earliest = today.subtract(Duration(days: _maxLookbackDays));

    DateTime cursor = since == null
        ? earliest
        : _dateOnly(since).add(const Duration(days: 1));
    if (cursor.isBefore(earliest)) {
      cursor = earliest;
    }

    // Nothing to close out until at least one full day has passed.
    if (!cursor.isBefore(today)) {
      return 0;
    }

    final List<RoutineBundleRow> bundles = await _appDatabase
        .getRoutineBundles();
    if (bundles.isEmpty) {
      return 0;
    }

    final DateTime lastDay = today.subtract(const Duration(days: 1));

    // A day is only closed out for a routine that already has a final answer.
    // A leftover `pending` or `snoozed` row from a day that is over is exactly
    // what "missed" means, so those get overwritten rather than skipped.
    final Set<String> resolved = <String>{
      for (final RoutineLogRowData log
          in await _appDatabase.getRoutineLogsBetween(
            dateKey(cursor),
            dateKey(lastDay),
          ))
        if (_resolvedStatuses.contains(log.status))
          '${log.routineId}@${log.date}',
    };

    int written = 0;
    for (
      DateTime day = cursor;
      day.isBefore(today);
      day = day.add(const Duration(days: 1))
    ) {
      final String key = dateKey(day);

      for (final RoutineBundleRow bundle in bundles) {
        if (!bundle.routine.isEnabled) {
          continue;
        }
        if (!_repeatDays(bundle.schedule.repeatDays).contains(day.weekday)) {
          continue;
        }
        // A routine cannot have been missed before it existed. Without this a
        // brand-new routine back-fills the whole lookback window as missed on
        // the next launch.
        if (day.isBefore(_dateOnly(bundle.routine.createdAt))) {
          continue;
        }
        if (resolved.contains('${bundle.routine.id}@$key')) {
          continue;
        }

        await _appDatabase.upsertRoutineLog(
          routineId: bundle.routine.id,
          dateKey: key,
          status: 'missed',
        );
        written += 1;
      }
    }

    return written;
  }

  /// Statuses that count as a final answer for a day.
  static const Set<String> _resolvedStatuses = <String>{
    'done',
    'skipped',
    'missed',
  };

  /// `yyyy-MM-dd` key used by the logs table.
  static String dateKey(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static List<int> _repeatDays(String encodedRepeatDays) {
    try {
      return (jsonDecode(encodedRepeatDays) as List<dynamic>).cast<int>();
    } on FormatException {
      return const <int>[];
    }
  }
}
