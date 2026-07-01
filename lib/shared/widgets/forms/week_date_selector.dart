import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(items.length, (int index) {
        final WeekDateItem item = items[index];
        final bool isSelected = index == selectedIndex;

        return GestureDetector(
          onTap: onSelected == null ? null : () => onSelected!(index),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: isSelected ? 52 : 40,
            height: isSelected ? 60 : 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius:
                  isSelected
                      ? BorderRadius.circular(AppRadius.extraLarge)
                      : BorderRadius.circular(AppRadius.pill),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  child: Text(item.weekday),
                ),
                const SizedBox(height: AppSpacing.xxs),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
        );
      }),
    );
  }
}
