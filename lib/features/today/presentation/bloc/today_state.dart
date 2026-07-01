part of 'today_bloc.dart';

enum TodayStatus { initial, loading, success, failure }

enum TodayRoutineItemStatus { pending, done, skipped }

class TodayRoutineItem extends Equatable {
  const TodayRoutineItem({
    required this.routineId,
    required this.title,
    required this.category,
    required this.reminderTime,
    required this.status,
    required this.isDueNow,
  });

  final String routineId;
  final String title;
  final RoutineCategory category;
  final String reminderTime;
  final TodayRoutineItemStatus status;
  final bool isDueNow;

  @override
  List<Object?> get props => <Object?>[
    routineId,
    title,
    category,
    reminderTime,
    status,
    isDueNow,
  ];
}

class TodayState extends Equatable {
  const TodayState({
    required this.status,
    required this.selectedDate,
    required this.items,
    required this.completedCount,
    required this.totalCount,
    required this.errorMessage,
  });

  factory TodayState.initial(DateTime selectedDate) {
    return TodayState(
      status: TodayStatus.initial,
      selectedDate: selectedDate,
      items: const <TodayRoutineItem>[],
      completedCount: 0,
      totalCount: 0,
      errorMessage: null,
    );
  }

  final TodayStatus status;
  final DateTime selectedDate;
  final List<TodayRoutineItem> items;
  final int completedCount;
  final int totalCount;
  final String? errorMessage;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  TodayRoutineItem? findItem(String routineId) {
    for (final TodayRoutineItem item in items) {
      if (item.routineId == routineId) {
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
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TodayState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      items: items ?? this.items,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    selectedDate,
    items,
    completedCount,
    totalCount,
    errorMessage,
  ];
}
