import 'package:flutter/widgets.dart';

final class AppLocales {
  const AppLocales._();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  static Locale localeFromCode(String languageCode) {
    return supportedLocales.firstWhere(
      (Locale locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en'),
    );
  }
}
