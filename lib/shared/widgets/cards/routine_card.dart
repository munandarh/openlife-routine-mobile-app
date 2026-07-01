import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.statusLabel,
    this.onTap,
    this.isDone = false,
    this.isDueNow = false,
    super.key,
  });

  final String title;
  final String timeLabel;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String? statusLabel;
  final VoidCallback? onTap;
  final bool isDone;
  final bool isDueNow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isDueNow ? AppColors.warning : AppColors.border,
            width: isDueNow ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Text(
                          timeLabel,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (statusLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isDueNow
                                ? AppColors.accentSoft
                                : AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                          ),
                          child: Text(
                            statusLabel!,
                            style: AppTextStyles.label.copyWith(
                              color: isDueNow
                                  ? AppColors.warning
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFE0F5E4) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isDone ? Colors.transparent : AppColors.border,
                  width: 2,
                ),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.circle_outlined,
                color: isDone ? AppColors.success : AppColors.border,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
