import 'package:openlife_routine/core/storage/app_database.dart';

/// Service that marks pending routine logs from yesterday as "missed".
///
/// This is intended to be called once when the app starts (in
/// `bootstrap()`) so that the previous day's uncompleted routines
/// appear correctly as "missed" rather than remaining "pending"
/// indefinitely.
class MissedStateService {
  MissedStateService({required AppDatabase appDatabase})
    : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

  /// Marks all "pending" logs from yesterday as "missed".
  ///
  /// Returns the number of logs that were updated.
  Future<int> markYesterdayPendingAsMissed() async {
    final DateTime yesterday = DateTime.now().subtract(
      const Duration(days: 1),
    );
    final String yesterdayKey = _dateKey(yesterday);

    // Find the single log for each routine on yesterday that is pending.
    final List<RoutineLogRowData> pendingLogs = await _appDatabase
        .getRoutineLogsByDate(yesterdayKey);

    int count = 0;
    for (final RoutineLogRowData log in pendingLogs) {
      if (log.status == 'pending') {
        await _appDatabase.upsertRoutineLog(
          routineId: log.routineId,
          dateKey: yesterdayKey,
          status: 'missed',
        );
        count += 1;
      }
    }
    return count;
  }

  static String _dateKey(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}
