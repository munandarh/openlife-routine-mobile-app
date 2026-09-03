import 'package:flutter/material.dart';

final class AppTextStyles {
  const AppTextStyles._();

  /// Bundled in pubspec. Naming a family that is not shipped makes Flutter
  /// fall back silently, which is how this app rendered Roboto for months.
  static const String fontFamily = 'Nunito';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.18,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 25,
    height: 1.18,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyEmphasis = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    height: 1.4,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    height: 1.33,
    fontWeight: FontWeight.w800,
  );
}
