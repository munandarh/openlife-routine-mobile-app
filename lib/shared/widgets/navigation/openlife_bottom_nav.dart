import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class OpenLifeBottomNav extends StatelessWidget {
  const OpenLifeBottomNav({required this.currentRoute, super.key});

  final OpenLifeRoute currentRoute;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        border: Border.all(color: context.palette.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x148EAA5E),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: OpenLifeRoute.bottomNavRoutes.map((OpenLifeRoute route) {
            final bool isSelected =
                route == currentRoute ||
                (route == OpenLifeRoute.routines &&
                    currentRoute.isNestedUnderRoutines);

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                onTap: () => context.go(route.path),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Icon(
                          route.icon,
                          color: isSelected
                              ? AppColors.primary
                              : context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _label(context.l10n, route),
                        style: AppTextStyles.label.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : context.palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Bottom-nav labels come from the active locale, not the route enum's
/// English `label`, which stays for debugging and route naming.
String _label(AppLocalizations l10n, OpenLifeRoute route) {
  return switch (route) {
    OpenLifeRoute.today => l10n.todayTab,
    OpenLifeRoute.routines => l10n.routinesTab,
    OpenLifeRoute.insights => l10n.insightsTab,
    OpenLifeRoute.settings => l10n.settingsTab,
    _ => route.label,
  };
}
