import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The whole point of Sage & Clay is that one token set governs every screen.
///
/// Colours drifted in twice before this existed: a blue left over from the old
/// palette on the onboarding permission screen, and three hand-written copies
/// of the same card shadow. Both looked fine in isolation and wrong side by
/// side.
void main() {
  final List<File> sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'))
      .where((File file) => !file.path.contains('/l10n/'))
      .toList();

  test('no screen writes a raw hex colour', () {
    // Colour(0x...) belongs in app_colors.dart, where it can be seen next to
    // the values it has to live with.
    final RegExp rawColour = RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)');
    final List<String> offenders = <String>[];

    for (final File file in sources) {
      if (file.path.endsWith('app_colors.dart')) {
        continue;
      }
      final List<String> lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i += 1) {
        if (rawColour.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(offenders, isEmpty, reason: 'raw colours:\n${offenders.join('\n')}');
  });

  test('no screen reaches past the palette for a theme-dependent colour', () {
    // The pale fills and the brand inks are light-theme values. Read directly,
    // they survived into the dark theme as bright slabs carrying near-white
    // text — the Insights banner shipped pale grey copy on near-white, and a
    // due routine card was a cream block with an invisible title.
    //
    // context.palette resolves each to the right value for the active theme.
    final RegExp themed = RegExp(
      r'AppColors\.(primarySoft|accentSoft|dangerSoft)\b',
    );
    final Set<String> allowed = <String>{
      // Text on the primary-green fill, which is the same colour in both
      // themes: the pale tone is correct there and must not follow the page.
      'lib/features/today/presentation/pages/today_page.dart',
      'lib/features/routines/presentation/pages/routines_page.dart',
      'lib/shared/widgets/forms/week_date_selector.dart',
      // Pairs a tint with its ink for whichever theme is active.
      'lib/features/routines/presentation/utils/routine_category_ui.dart',
      'lib/features/routines/presentation/pages/templates_page.dart',
    };
    final List<String> offenders = <String>[];

    for (final File file in sources) {
      if (file.path.endsWith('app_colors.dart') ||
          file.path.endsWith('app_palette.dart') ||
          allowed.contains(file.path)) {
        continue;
      }
      final List<String> lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i += 1) {
        if (themed.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'read these through context.palette:\n${offenders.join('\n')}',
    );
  });

  test('no screen hand-rolls a card shadow', () {
    // AppShadows names one recipe per role; an inline BoxShadow is how a
    // screen ends up a shade heavier than the one beside it.
    final List<String> offenders = <String>[];

    for (final File file in sources) {
      if (file.path.endsWith('app_shadows.dart')) {
        continue;
      }
      final String source = file.readAsStringSync();
      if (source.contains('boxShadow: <BoxShadow>[')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'inline shadows in:\n${offenders.join('\n')}',
    );
  });
}
