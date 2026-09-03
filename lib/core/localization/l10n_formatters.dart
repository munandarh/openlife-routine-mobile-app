import 'package:flutter/material.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// Locale-aware formatting shared across screens.
final class L10nFormatters {
  const L10nFormatters._();

  /// Single-letter weekday initials, Monday first, in the active locale.
  static List<String> weekdayInitials(AppLocalizations l10n) {
    return <String>[
      l10n.weekdayShortMon,
      l10n.weekdayShortTue,
      l10n.weekdayShortWed,
      l10n.weekdayShortThu,
      l10n.weekdayShortFri,
      l10n.weekdayShortSat,
      l10n.weekdayShortSun,
    ];
  }

  /// Three-letter weekday abbreviations, Monday first, in the active locale.
  static List<String> weekdayAbbreviations(AppLocalizations l10n) {
    return <String>[
      l10n.weekdayAbbrMon,
      l10n.weekdayAbbrTue,
      l10n.weekdayAbbrWed,
      l10n.weekdayAbbrThu,
      l10n.weekdayAbbrFri,
      l10n.weekdayAbbrSat,
      l10n.weekdayAbbrSun,
    ];
  }

  /// Renders `repeatDays` (ISO weekday numbers, 1 = Monday) as a readable list.
  static String repeatDays(AppLocalizations l10n, List<int> repeatDays) {
    if (repeatDays.isEmpty) {
      return l10n.noRepeatDays;
    }
    if (repeatDays.length == 7) {
      return l10n.everyDay;
    }

    final List<String> labels = weekdayAbbreviations(l10n);
    final List<int> sorted = List<int>.of(repeatDays)..sort();
    return sorted
        .where((int day) => day >= 1 && day <= 7)
        .map((int day) => labels[day - 1])
        .join(', ');
  }

  /// Formats an `HH:mm` string using the device's 12/24-hour preference.
  static String timeOfDayLabel(BuildContext context, String reminderTime) {
    return timeLabel(context, parseTime(reminderTime));
  }

  /// Every one of a routine's times, in the device's 12/24-hour preference.
  ///
  /// Joined rather than summarised as "3x daily" because the hours are the
  /// part a person checks: knowing a dose is at 13:00 is what stops them
  /// taking it twice.
  static String reminderTimes(BuildContext context, List<String> times) {
    return times
        .map((String time) => timeOfDayLabel(context, time))
        .join(' · ');
  }

  /// Formats a [TimeOfDay] using the device's 12/24-hour preference.
  static String timeLabel(BuildContext context, TimeOfDay time) {
    return time.format(context);
  }

  /// Parses an `HH:mm` string, falling back to 08:00 when malformed.
  static TimeOfDay parseTime(String reminderTime) {
    final List<String> parts = reminderTime.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
    return TimeOfDay(
      hour: int.tryParse(parts[0])?.clamp(0, 23) ?? 8,
      minute: int.tryParse(parts[1])?.clamp(0, 59) ?? 0,
    );
  }

  /// Serialises a [TimeOfDay] back to the `HH:mm` storage format.
  static String serializeTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
