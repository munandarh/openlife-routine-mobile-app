import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class AnxietyBreathCard extends StatelessWidget {
  const AnxietyBreathCard({
    required this.completedToday,
    required this.targetSessions,
    required this.onStartBreathing,
    super.key,
  });

  final int completedToday;
  final int targetSessions;
  final VoidCallback onStartBreathing;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double progress = (completedToday / targetSessions).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: isDark
            ? Color.alphaBlend(
                AppColors.anxietyInk.withValues(alpha: 0.25),
                context.palette.surface,
              )
            : AppColors.anxietyCardTint,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.anxietyCardDark
                      : AppColors.anxietyTint,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.air_rounded,
                  size: 24,
                  color: AppColors.anxietyTitle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.anxietyBreathTitle.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.anxietySubtitle,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.anxietyBreathTagline,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.anxietyBreathDuration,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.anxietyProgressBgDark
                            : AppColors.anxietyProgressBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.forestGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      completedToday >= targetSessions
                          ? l10n.allSessionsCompleteToday
                          : l10n.sessionsCompleteToday(
                              completedToday,
                              targetSessions,
                            ),
                      style: AppTextStyles.bodyEmphasis.copyWith(
                        fontSize: 12.5,
                        color: context.palette.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Material(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: onStartBreathing,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md + 2,
                      vertical: AppSpacing.sm + 2,
                    ),
                    child: Text(
                      l10n.feelBreathe,
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
