import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/app_locales.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// Wraps [child] in a `MaterialApp` that carries the generated
/// `AppLocalizations` delegates.
///
/// Widget tests must use this (instead of a bare `MaterialApp`) for any page or
/// widget that reads `context.l10n`, otherwise `AppLocalizations.of` returns
/// null and the widget throws.
MaterialApp localizedApp(
  Widget child, {
  Locale locale = const Locale('en'),
  NavigatorObserver? navigatorObserver,
  double textScale = 1.0,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocales.supportedLocales,
    navigatorObservers: <NavigatorObserver>[?navigatorObserver],
    builder: (BuildContext context, Widget? widget) {
      if (textScale == 1.0) {
        return widget!;
      }
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: widget!,
      );
    },
    home: child,
  );
}

/// Resolves the generated strings for [locale] outside of a widget tree, so
/// tests can assert against the same source of truth the UI renders from.
Future<AppLocalizations> l10nFor([
  Locale locale = const Locale('en'),
]) {
  return AppLocalizations.delegate.load(locale);
}
