part of 'today_bloc.dart';

enum TodayStatus { initial, loading, success, failure }

enum TodayRoutineItemStatus { pending, done, skipped, missed, snoozed }

class TodayRoutineItem extends Equatable {
  const TodayRoutineItem({
    required this.routineId,
    required this.title,
    required this.category,
    required this.reminderTime,
    required this.status,
    required this.isDueNow,
    this.iconKey,
    this.snoozedUntil,
  });

  final String routineId;
  final String title;
  final RoutineCategory category;
  final String reminderTime;
  final TodayRoutineItemStatus status;
  final bool isDueNow;

  /// Icon override stored on the routine, if any.
  final String? iconKey;

  /// When [status] is [TodayRoutineItemStatus.snoozed], the moment the
  /// reminder comes back.
  final DateTime? snoozedUntil;

  /// True while the routine still needs an answer today.
  bool get isOpen =>
      status == TodayRoutineItemStatus.pending ||
      status == TodayRoutineItemStatus.snoozed;

  @override
  List<Object?> get props => <Object?>[
    routineId,
    title,
    category,
    reminderTime,
    status,
    isDueNow,
    iconKey,
    snoozedUntil,
  ];
}

class TodayState extends Equatable {
  const TodayState({
    required this.status,
    required this.selectedDate,
    required this.items,
    required this.completedCount,
    required this.totalCount,
    required this.hasRoutines,
    this.streak = 0,
    this.errorMessage,
  });

  const TodayState.initial(this.selectedDate)
    : status = TodayStatus.initial,
      items = const <TodayRoutineItem>[],
      completedCount = 0,
      totalCount = 0,
      streak = 0,
      // Assume routines exist until the first load says otherwise, so the
      // screen shows a spinner rather than flashing the empty state.
      hasRoutines = true,
      errorMessage = null;

  final TodayStatus status;
  final DateTime selectedDate;
  final List<TodayRoutineItem> items;
  final int completedCount;
  final int totalCount;

  /// Consecutive fully-completed days, from the shared [RoutineStreak] rule.
  final int streak;
  final bool hasRoutines;
  final String? errorMessage;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  /// The next routine still awaiting an answer, ordered by reminder time.
  ///
  /// Drives the "Next" card required by PRD §8.2.
  TodayRoutineItem? get nextRoutine {
    for (final TodayRoutineItem item in items) {
      if (item.isOpen) {
        return item;
      }
    }
    return null;
  }

  int get skippedCount => _countOf(TodayRoutineItemStatus.skipped);

  int get missedCount => _countOf(TodayRoutineItemStatus.missed);

  int get snoozedCount => _countOf(TodayRoutineItemStatus.snoozed);

  int get pendingCount => _countOf(TodayRoutineItemStatus.pending);

  int _countOf(TodayRoutineItemStatus status) {
    int count = 0;
    for (final TodayRoutineItem item in items) {
      if (item.status == status) {
        count += 1;
      }
    }
    return count;
  }

  TodayRoutineItem? findItem(String routineId, String reminderTime) {
    for (final TodayRoutineItem item in items) {
      if (item.routineId == routineId && item.reminderTime == reminderTime) {
        return item;
      }
    }
    return null;
  }

  TodayState copyWith({
    TodayStatus? status,
    DateTime? selectedDate,
    List<TodayRoutineItem>? items,
    int? completedCount,
    int? totalCount,
    int? streak,
    bool? hasRoutines,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TodayState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      items: items ?? this.items,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      streak: streak ?? this.streak,
      hasRoutines: hasRoutines ?? this.hasRoutines,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    selectedDate,
    items,
    completedCount,
    totalCount,
    hasRoutines,
    errorMessage,
  ];
}
