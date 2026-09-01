import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/app_info.dart';
import 'package:openlife_routine/core/localization/app_locales.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// Guards the two ways localization silently rots: a key added to English but
/// not Indonesian, and a translation left as a copy of the English string.
void main() {
  Map<String, dynamic> readArb(String path) {
    return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  }

  Set<String> messageKeys(Map<String, dynamic> arb) {
    return arb.keys.where((String k) => !k.startsWith('@')).toSet();
  }

  final Map<String, dynamic> en = readArb('lib/l10n/app_en.arb');
  final Map<String, dynamic> id = readArb('lib/l10n/app_id.arb');

  group('ARB parity', () {
    test('every English key has an Indonesian translation', () {
      expect(messageKeys(en).difference(messageKeys(id)), isEmpty);
    });

    test('Indonesian has no keys English does not', () {
      expect(messageKeys(id).difference(messageKeys(en)), isEmpty);
    });

    test('translations are not left as English copies', () {
      // Proper nouns, loanwords, format-only strings and shared
      // abbreviations are legitimately identical across both languages.
      const Set<String> allowedIdentical = <String>{
        'appTitle',
        // Loanwords Indonesian uses unchanged in product UI.
        'categoryVitamin',
        'dataSection',
        'resetButton',
        'englishLang',
        'bahasaLang',
        'bahasaSubtitle',
        'bahasaShort',
        'exportJson',
        'onboardingStepCounter',
        'minutesShort',
        'aboutOpenSource',
        'templateRoutineVitaminD3',
        'weekdayShortMon',
        'weekdayShortTue',
        'weekdayShortSat',
      };

      final List<String> identical = <String>[
        for (final String key in messageKeys(en))
          if (!allowedIdentical.contains(key) && en[key] == id[key]) key,
      ];

      expect(identical, isEmpty, reason: 'Untranslated keys: $identical');
    });
  });

  group('generated delegate', () {
    test('supports every locale the app advertises', () {
      for (final Locale locale in AppLocales.supportedLocales) {
        expect(
          AppLocalizations.delegate.isSupported(locale),
          isTrue,
          reason: '${locale.languageCode} is not supported by the delegate',
        );
      }
    });

    test('loads both locales with distinct copy', () async {
      final AppLocalizations english = await AppLocalizations.delegate.load(
        const Locale('en'),
      );
      final AppLocalizations indonesian = await AppLocalizations.delegate.load(
        const Locale('id'),
      );

      expect(english.todayTab, 'Today');
      expect(indonesian.todayTab, 'Hari Ini');
    });

    test('resolves plural forms', () async {
      final AppLocalizations english = await AppLocalizations.delegate.load(
        const Locale('en'),
      );

      expect(english.stepsCount(1), '1 step');
      expect(english.stepsCount(3), '3 steps');
    });
  });

  group('AppLocales', () {
    test('falls back to English for an unknown code', () {
      expect(AppLocales.localeFromCode('fr').languageCode, 'en');
    });

    test('resolves the codes it does know', () {
      expect(AppLocales.localeFromCode('id').languageCode, 'id');
      expect(AppLocales.localeFromCode('en').languageCode, 'en');
    });
  });

  group('AppInfo', () {
    test('version matches pubspec.yaml', () {
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      final RegExpMatch? match = RegExp(
        r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(match, isNotNull, reason: 'pubspec.yaml has no version line');
      expect(AppInfo.version, match!.group(1));
    });
  });
}
