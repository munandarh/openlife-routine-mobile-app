/// Time-of-day greeting helpers used by the Today screen hero.
///
/// All functions are pure (no side effects) so they can be tested
/// without a Flutter binding.

/// Returns a friendly English greeting for the given hour of the day
/// (0-23).
String greetingForHour(int hour) {
  if (hour >= 5 && hour < 12) {
    return 'Good morning';
  }
  if (hour >= 12 && hour < 18) {
    return 'Good afternoon';
  }
  if (hour >= 18 && hour < 24) {
    return 'Good evening';
  }
  return 'Good night';
}

/// Returns a friendly Indonesian greeting for the given hour of the day
/// (0-23). Indonesian has a fourth greeting ("selamat sore") used in the
/// late afternoon before sunset.
String greetingIdiForHour(int hour) {
  if (hour >= 5 && hour < 12) {
    return 'Selamat pagi';
  }
  if (hour >= 12 && hour < 15) {
    return 'Selamat siang';
  }
  if (hour >= 15 && hour < 19) {
    return 'Selamat sore';
  }
  return 'Selamat malam';
}
