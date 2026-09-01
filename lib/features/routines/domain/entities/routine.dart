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

class Routine extends Equatable {
  const Routine({
    required this.id,
    required this.title,
    required this.category,
    required this.reminderTime,
    required this.repeatDays,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.snoozeMinutes = 10,
    this.iconKey,
    this.notes,
  });

  final String id;
  final String title;
  final RoutineCategory category;
  final String reminderTime;
  final List<int> repeatDays;
  final bool isEnabled;
  final int snoozeMinutes;

  /// Optional icon override; null falls back to the category's default icon.
  final String? iconKey;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Routine copyWith({
    String? id,
    String? title,
    RoutineCategory? category,
    String? reminderTime,
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
      reminderTime: reminderTime ?? this.reminderTime,
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
    reminderTime,
    repeatDays,
    isEnabled,
    snoozeMinutes,
    iconKey,
    notes,
    createdAt,
    updatedAt,
  ];
}
