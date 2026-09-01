import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// Resolves the English seed strings held by [RoutineTemplate] into the active
/// locale.
///
/// Template content lives in the domain layer as stable keys plus an English
/// fallback; the words themselves belong to presentation.
final class TemplateL10n {
  const TemplateL10n._();

  static String title(AppLocalizations l10n, RoutineTemplate template) {
    return switch (template.id) {
      'morning' => l10n.templateMorningTitle,
      'hydration' => l10n.templateHydrationTitle,
      'vitamin' => l10n.templateVitaminTitle,
      'sleep' => l10n.templateSleepTitle,
      'programmer_break' => l10n.templateProgrammerBreakTitle,
      _ => template.title,
    };
  }

  static String description(AppLocalizations l10n, RoutineTemplate template) {
    return switch (template.id) {
      'morning' => l10n.templateMorningDesc,
      'hydration' => l10n.templateHydrationDesc,
      'vitamin' => l10n.templateVitaminDesc,
      'sleep' => l10n.templateSleepDesc,
      'programmer_break' => l10n.templateProgrammerBreakDesc,
      _ => template.description,
    };
  }

  static String? badge(AppLocalizations l10n, RoutineTemplate template) {
    return switch (template.badge) {
      'POPULAR' => l10n.badgePopular,
      'NEW' => l10n.badgeNew,
      _ => template.badge,
    };
  }

  /// Localized name for one routine inside a template. These become real
  /// routine titles in the database, so they are resolved at creation time in
  /// the language the user picked.
  static String routineTitle(AppLocalizations l10n, TemplateRoutineItem item) {
    return switch (item.titleKey) {
      'wakeUp' => l10n.templateRoutineWakeUp,
      'drinkWater' => l10n.templateRoutineDrinkWater,
      'breakfast' => l10n.templateRoutineBreakfast,
      'morningWater' => l10n.templateRoutineMorningWater,
      'middayWater' => l10n.templateRoutineMiddayWater,
      'afternoonWater' => l10n.templateRoutineAfternoonWater,
      'eveningWater' => l10n.templateRoutineEveningWater,
      'vitaminD3' => l10n.templateRoutineVitaminD3,
      'bComplex' => l10n.templateRoutineBComplex,
      'reduceScreenTime' => l10n.templateRoutineReduceScreenTime,
      'prepareBed' => l10n.templateRoutinePrepareBed,
      'eyeRest' => l10n.templateRoutineEyeRest,
      'stretching' => l10n.templateRoutineStretching,
      'postureCheck' => l10n.templateRoutinePostureCheck,
      _ => item.title,
    };
  }
}
