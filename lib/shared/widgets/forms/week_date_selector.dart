import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

class WeekDateItem {
  const WeekDateItem({
    required this.weekday,
    required this.dayNumber,
    this.hasIndicator = false,
  });

  final String weekday;
  final String dayNumber;
  final bool hasIndicator;
}

class WeekDateSelector extends StatelessWidget {
  const WeekDateSelector({
    required this.selectedIndex,
    required this.items,
    this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final List<WeekDateItem> items;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    // Each day takes an equal share of the row. Fixed widths (40, or 52 for the
    // selected day) add up to 292 and overflowed a 320dp screen by 20px, which
    // clipped Sunday off the edge where it could not be tapped.
    return Row(
      children: List<Widget>.generate(items.length, (int index) {
        final WeekDateItem item = items[index];
        final bool isSelected = index == selectedIndex;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: GestureDetector(
              onTap: onSelected == null ? null : () => onSelected!(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                // A floor rather than a fixed height, so the column still fits
                // when the OS text scale grows the labels.
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                // Every day is a chip, not just today: a bare column of text
                // beside one filled pill reads as a broken row.
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : context.palette.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  boxShadow: isSelected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? AppColors.primarySoft
                            : context.palette.textMuted,
                      ),
                      child: Text(item.weekday),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? Colors.white
                            : context.palette.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                      child: Text(item.dayNumber),
                    ),
                    if (item.hasIndicator) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxs),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
