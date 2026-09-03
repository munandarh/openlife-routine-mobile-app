final class AppRadius {
  const AppRadius._();

  /// One value per role, so a card cannot drift between screens.
  /// small: small icon containers (32-38px). medium: chips, fields, day pills.
  /// large: every card. extraLarge: the one oversized avatar on Routine detail.
  static const double small = 12;
  static const double medium = 16;
  static const double large = 24;
  static const double extraLarge = 20;
  static const double pill = 999;
}
