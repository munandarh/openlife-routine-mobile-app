import 'dart:convert';

import 'package:openlife_routine/core/storage/app_database.dart';

/// How many consecutive days ended with every scheduled routine done.
///
/// Lives here rather than inside a BLoC because two screens ask for it —
/// Insights and Today's header — and the rules are subtle enough that a second
/// copy would drift: a day with nothing scheduled is skipped rather than
/// counted or broken, and a still-unfinished today does not break the streak,
/// because an incomplete day only counts against you once it is over.
class RoutineStreak {
  const RoutineStreak._();

  /// Days to walk back before giving up. A streak longer than this is capped,
  /// which is fine: the number is encouragement, not a record.
  static const int _maxLookback = 30;

  static int calculate({
    required List<RoutineBundleRow> bundles,
    required Map<String, List<RoutineLogRowData>> logsByDate,
    required DateTime today,
  }) {
    int streak = 0;

    for (int i = 0; i < _maxLookback; i += 1) {
      final DateTime day = today.subtract(Duration(days: i));
      final int scheduled = scheduledOn(bundles, day);
      if (scheduled == 0) {
        continue;
      }

      final int done = countStatus(logsByDate[dateKey(day)], 'done');
      if (done >= scheduled) {
        streak += 1;
        continue;
      }
      if (i == 0) {
        continue;
      }
      break;
    }

    return streak;
  }

  /// Routines actually due on [day], respecting repeat days and never counting
  /// a routine before the day it was created.
  static int scheduledOn(List<RoutineBundleRow> bundles, DateTime day) {
    int count = 0;
    for (final RoutineBundleRow bundle in bundles) {
      if (!repeatDays(bundle.schedule.repeatDays).contains(day.weekday)) {
        continue;
      }
      final DateTime createdAt = bundle.routine.createdAt;
      if (day.isBefore(
        DateTime(createdAt.year, createdAt.month, createdAt.day),
      )) {
        continue;
      }
      count += 1;
    }
    return count;
  }

  static int countStatus(List<RoutineLogRowData>? logs, String status) {
    if (logs == null) {
      return 0;
    }
    int count = 0;
    for (final RoutineLogRowData log in logs) {
      if (log.status == status) {
        count += 1;
      }
    }
    return count;
  }

  static List<int> repeatDays(String encodedRepeatDays) {
    try {
      return (jsonDecode(encodedRepeatDays) as List<dynamic>).cast<int>();
    } on FormatException {
      return const <int>[];
    }
  }

  static String dateKey(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}
