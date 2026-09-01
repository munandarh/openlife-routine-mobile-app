import 'package:flutter/widgets.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// Convenience access to the generated localizations.
///
/// Usage: `context.l10n.todayTab`.
///
/// The bang is safe in app code because [AppLocalizations.delegate] is always
/// registered by `OpenLifeApp`. Widget tests must pump their subject inside a
/// `MaterialApp` that carries `AppLocalizations.localizationsDelegates`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
