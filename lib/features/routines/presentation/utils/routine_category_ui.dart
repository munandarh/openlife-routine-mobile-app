import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/utils/routine_icons.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// Presentation lookups for [RoutineCategory].
///
/// Today, Routines, Routine Detail and New Routine all render the same icon,
/// tint and label per category, so the mapping lives here once instead of being
/// copy-pasted into each page.
final class RoutineCategoryUi {
  const RoutineCategoryUi._();

  /// Icon for a routine: the user's override when set and known, otherwise the
  /// category default.
  static IconData icon(RoutineCategory category, {String? iconKey}) {
    return RoutineIcons.resolve(iconKey) ?? defaultIcon(category);
  }

  static IconData defaultIcon(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => Icons.restaurant_outlined,
      RoutineCategory.water => Icons.water_drop_outlined,
      RoutineCategory.vitamin => Icons.medication_outlined,
      RoutineCategory.medicine => Icons.vaccines_outlined,
      RoutineCategory.sleep => Icons.bedtime_outlined,
      RoutineCategory.exercise => Icons.fitness_center_outlined,
      RoutineCategory.breakTime => Icons.self_improvement_outlined,
      RoutineCategory.custom => Icons.star_outline_rounded,
    };
  }

  static Color background(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => AppColors.mealTint,
      RoutineCategory.water => AppColors.waterTint,
      RoutineCategory.vitamin => AppColors.mealTint,
      RoutineCategory.medicine => AppColors.medsTint,
      RoutineCategory.sleep => AppColors.sleepTint,
      RoutineCategory.exercise => AppColors.moveTint,
      RoutineCategory.breakTime => AppColors.calmTint,
      RoutineCategory.custom => AppColors.primarySoft,
    };
  }

  static Color foreground(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => AppColors.mealInk,
      RoutineCategory.water => AppColors.waterInk,
      RoutineCategory.vitamin => AppColors.mealInk,
      RoutineCategory.medicine => AppColors.medsInk,
      RoutineCategory.sleep => AppColors.sleepInk,
      RoutineCategory.exercise => AppColors.moveInk,
      RoutineCategory.breakTime => AppColors.calmInk,
      RoutineCategory.custom => AppColors.primary,
    };
  }

  /// Short category name, e.g. "Vitamin" — used by the category picker.
  static String label(AppLocalizations l10n, RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => l10n.categoryMeal,
      RoutineCategory.water => l10n.categoryWater,
      RoutineCategory.vitamin => l10n.categoryVitamin,
      RoutineCategory.medicine => l10n.categoryMedicine,
      RoutineCategory.sleep => l10n.categorySleep,
      RoutineCategory.exercise => l10n.categoryExercise,
      RoutineCategory.breakTime => l10n.categoryBreak,
      RoutineCategory.custom => l10n.categoryCustom,
    };
  }

  /// Descriptive name, e.g. "Vitamin routine" — used by Routine Detail.
  static String routineLabel(AppLocalizations l10n, RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => l10n.mealRoutine,
      RoutineCategory.water => l10n.waterRoutine,
      RoutineCategory.vitamin => l10n.vitaminRoutine,
      RoutineCategory.medicine => l10n.medicineRoutine,
      RoutineCategory.sleep => l10n.sleepRoutine,
      RoutineCategory.exercise => l10n.exerciseRoutine,
      RoutineCategory.breakTime => l10n.breakRoutine,
      RoutineCategory.custom => l10n.customRoutine,
    };
  }
}
