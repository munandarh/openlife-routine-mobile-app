import 'package:equatable/equatable.dart';

enum RoutineCategory {
  meal,
  water,
  vitamin,
  medicine,
  sleep,
  exercise,
  breakTime,
  custom,
}

extension RoutineCategoryX on RoutineCategory {
  /// Whether the editor offers more than one reminder a day.
  ///
  /// A dose is the one thing people genuinely take several times a day, and
  /// getting the second one wrong is the failure this app exists to prevent.
  /// Custom is included because it is the escape hatch for everything the
  /// fixed categories do not describe.
  bool get supportsMultipleTimes =>
      this == RoutineCategory.vitamin ||
      this == RoutineCategory.medicine ||
      this == RoutineCategory.custom;
}

class Routine extends Equatable {
  Routine({
    required this.id,
    required this.title,
    required this.category,
    required List<String> reminderTimes,
    required this.repeatDays,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.snoozeMinutes = 10,
    this.iconKey,
    this.notes,
  }) : assert(reminderTimes.isNotEmpty, 'a routine needs at least one time'),
       reminderTimes = normaliseTimes(reminderTimes);

  /// Sorted and de-duplicated, because both orderings are load-bearing: the
  /// notification slot a reminder occupies is its index in this list, and
  /// Today renders the day in the order it will actually happen.
  static List<String> normaliseTimes(List<String> times) {
    final List<String> unique = times.toSet().toList()..sort();
    return List<String>.unmodifiable(unique);
  }

  final String id;
  final String title;
  final RoutineCategory category;

  /// Every time of day this routine reminds at, sorted. Never empty.
  final List<String> reminderTimes;

  final List<int> repeatDays;
  final bool isEnabled;
  final int snoozeMinutes;

  /// Optional icon override; null falls back to the category's default icon.
  final String? iconKey;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The day's first reminder — for sorting a list of routines, and for the
  /// one-line summaries that have no room for all of them.
  String get firstReminderTime => reminderTimes.first;

  bool get hasMultipleTimes => reminderTimes.length > 1;

  Routine copyWith({
    String? id,
    String? title,
    RoutineCategory? category,
    List<String>? reminderTimes,
    List<int>? repeatDays,
    bool? isEnabled,
    int? snoozeMinutes,
    String? iconKey,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearIconKey = false,
    bool clearNotes = false,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      iconKey: clearIconKey ? null : iconKey ?? this.iconKey,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    category,
    reminderTimes,
    repeatDays,
    isEnabled,
    snoozeMinutes,
    iconKey,
    notes,
    createdAt,
    updatedAt,
  ];
}
