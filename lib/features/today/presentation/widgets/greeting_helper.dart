import 'package:flutter/widgets.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// Time-of-day greeting helpers used by the Today screen hero.
///
/// Slot selection is pure (no Flutter binding needed) so the boundaries can be
/// unit tested; turning a slot into words is the only part that needs
/// localizations.

enum GreetingSlot { morning, afternoon, evening, night }

/// English greeting boundaries: afternoon runs until 18:00, evening until
/// midnight.
GreetingSlot greetingSlotForHour(int hour) {
  if (hour >= 5 && hour < 12) {
    return GreetingSlot.morning;
  }
  if (hour >= 12 && hour < 18) {
    return GreetingSlot.afternoon;
  }
  if (hour >= 18 && hour < 24) {
    return GreetingSlot.evening;
  }
  return GreetingSlot.night;
}

/// Indonesian greeting boundaries. Indonesian splits the afternoon in two:
/// "siang" until 15:00 and "sore" until sunset, so the slots shift earlier
/// than the English ones.
GreetingSlot greetingSlotIdForHour(int hour) {
  if (hour >= 5 && hour < 12) {
    return GreetingSlot.morning;
  }
  if (hour >= 12 && hour < 15) {
    return GreetingSlot.afternoon;
  }
  if (hour >= 15 && hour < 19) {
    return GreetingSlot.evening;
  }
  return GreetingSlot.night;
}

/// Picks the slot boundaries that match [languageCode].
GreetingSlot greetingSlotFor(int hour, String languageCode) {
  return languageCode == 'id'
      ? greetingSlotIdForHour(hour)
      : greetingSlotForHour(hour);
}

String greetingLabel(AppLocalizations l10n, GreetingSlot slot) {
  return switch (slot) {
    GreetingSlot.morning => l10n.greetingMorning,
    GreetingSlot.afternoon => l10n.greetingAfternoon,
    GreetingSlot.evening => l10n.greetingEvening,
    GreetingSlot.night => l10n.greetingNight,
  };
}

/// Resolves the greeting for [hour] in the locale currently active on
/// [context].
String greetingForContext(BuildContext context, int hour) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final String languageCode = Localizations.localeOf(context).languageCode;
  return greetingLabel(l10n, greetingSlotFor(hour, languageCode));
}
