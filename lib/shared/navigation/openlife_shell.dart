import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

class OpenLifeShell extends StatelessWidget {
  const OpenLifeShell({
    required this.currentRoute,
    required this.child,
    super.key,
  });

  final OpenLifeRoute currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          0,
          AppSpacing.pageMargin,
          AppSpacing.pageMargin,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: OpenLifeRoute.values
                  .where(
                    (OpenLifeRoute route) => route != OpenLifeRoute.onboarding,
                  )
                  .map((OpenLifeRoute route) {
                    final bool isSelected = route == currentRoute;

                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppRadius.extraLarge,
                        ),
                        onTap: () => context.go(route.path),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
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
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Icon(
                                  _iconFor(route),
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                route.name[0].toUpperCase() +
                                    route.name.substring(1),
                                style: AppTextStyles.label.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(OpenLifeRoute route) {
    return switch (route) {
      OpenLifeRoute.today => Icons.today_outlined,
      OpenLifeRoute.routines => Icons.calendar_today_outlined,
      OpenLifeRoute.insights => Icons.insights_outlined,
      OpenLifeRoute.settings => Icons.settings_outlined,
      OpenLifeRoute.onboarding => Icons.spa_outlined,
    };
  }
}
