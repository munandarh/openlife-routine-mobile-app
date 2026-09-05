import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class FeelingsGrid extends StatelessWidget {
  const FeelingsGrid({
    required this.onBreatheSelected,
    this.onFeelingSelected,
    super.key,
  });

  final VoidCallback onBreatheSelected;
  final ValueChanged<String>? onFeelingSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final List<_FeelingItem> items = <_FeelingItem>[
      _FeelingItem(
        label: l10n.feelCalm,
        icon: Icons.eco_outlined,
        tint: AppColors.feelCalmTint,
        ink: AppColors.feelCalmInk,
      ),
      _FeelingItem(
        label: l10n.feelFocus,
        icon: Icons.adjust_rounded,
        tint: AppColors.feelFocusedTint,
        ink: AppColors.feelFocusedInk,
      ),
      _FeelingItem(
        label: l10n.feelReset,
        icon: Icons.wb_sunny_outlined,
        tint: AppColors.feelGroundedTint,
        ink: AppColors.feelGroundedInk,
      ),
      _FeelingItem(
        label: l10n.feelSleep,
        icon: Icons.bedtime_outlined,
        tint: AppColors.feelRestfulTint,
        ink: AppColors.feelRestfulInk,
      ),
      _FeelingItem(
        label: l10n.feelBreathe,
        icon: Icons.air_rounded,
        tint: AppColors.feelRelievedTint,
        ink: AppColors.feelRelievedInk,
        isBreathe: true,
      ),
      _FeelingItem(
        label: l10n.feelStressRelief,
        icon: Icons.favorite_outline_rounded,
        tint: AppColors.feelEnergizedTint,
        ink: AppColors.feelEnergizedInk,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.howDoYouWantToFeel,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisExtent: 48,
          ),
          itemBuilder: (BuildContext context, int index) {
            final _FeelingItem item = items[index];
            return Material(
              color: item.tint,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () {
                  if (item.isBreathe) {
                    onBreatheSelected();
                  } else {
                    onFeelingSelected?.call(
                      [
                        'calm',
                        'focus',
                        'reset',
                        'sleep',
                        'breathe',
                        'stress',
                      ][index],
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(item.icon, size: 18, color: item.ink),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Flexible(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.button.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: item.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FeelingItem {
  const _FeelingItem({
    required this.label,
    required this.icon,
    required this.tint,
    required this.ink,
    this.isBreathe = false,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final Color ink;
  final bool isBreathe;
}
