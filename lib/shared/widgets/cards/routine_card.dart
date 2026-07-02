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
    this.secondaryActionLabel,
    this.onTap,
    this.onCheckTap,
    this.onSecondaryAction,
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
  final String? secondaryActionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onCheckTap;
  final VoidCallback? onSecondaryAction;
  final bool isDone;
  final bool isDueNow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
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
                  _AnimatedStrikethroughText(
                    text: title,
                    isStruckThrough: isDone,
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
                      if (secondaryActionLabel != null) ...<Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          onTap: onSecondaryAction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(
                                AppRadius.small,
                              ),
                            ),
                            child: Text(
                              secondaryActionLabel!,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _CheckCircle(isDone: isDone, onTap: onCheckTap),
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.isDone, this.onTap});

  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isDone ? Icons.check_rounded : Icons.circle_outlined,
            key: ValueKey<bool>(isDone),
            color: isDone ? AppColors.success : AppColors.border,
          ),
        ),
      ),
    );
  }
}

class _AnimatedStrikethroughText extends StatelessWidget {
  const _AnimatedStrikethroughText({
    required this.text,
    required this.isStruckThrough,
  });

  final String text;
  final bool isStruckThrough;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: isStruckThrough ? 1.0 : 0.0,
        end: isStruckThrough ? 1.0 : 0.0,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Text(
          text,
          style: AppTextStyles.cardTitle.copyWith(
            decoration: value > 0.5 ? TextDecoration.lineThrough : null,
            color: Color.lerp(
              AppColors.textPrimary,
              AppColors.textSecondary,
              value,
            ),
          ),
        );
      },
    );
  }
}
