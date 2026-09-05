import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class TodaysPauseCard extends StatelessWidget {
  const TodaysPauseCard({required this.onStart, super.key});

  final VoidCallback onStart;

  (String title, String desc) _contentForCurrentTime(AppLocalizations l10n) {
    final int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return (l10n.morningReset, l10n.morningResetDesc);
    } else if (hour >= 12 && hour < 17) {
      return (l10n.middayPause, l10n.middayPauseDesc);
    } else if (hour >= 17 && hour < 21) {
      return (l10n.eveningUnwind, l10n.eveningUnwindDesc);
    } else {
      return (l10n.prepareForSleep, l10n.prepareForSleepDesc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final (String title, String desc) = _contentForCurrentTime(l10n);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.primary,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: const MeditationLandscape()),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.todaysPause,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.meditationMoon.withValues(alpha: 0.75),
                      fontSize: 11,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    title,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.meditationCardText,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    desc,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.meditationCardText.withValues(
                        alpha: 0.85,
                      ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.meditationCardText.withValues(
                          alpha: 0.85,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.fiveMinutes,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.meditationCardText.withValues(
                            alpha: 0.85,
                          ),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md + 4),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      onTap: onStart,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm + 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              l10n.getStarted,
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primaryDeep,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.primaryDeep,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
