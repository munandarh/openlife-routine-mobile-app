import 'package:flutter/widgets.dart';

final class AppLocales {
  const AppLocales._();

  static const Locale defaultLocale = Locale('en');

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];
}
