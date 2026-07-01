import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                item.weekday,
                style: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: isSelected ? 52 : 40,
                height: isSelected ? 60 : 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    isSelected ? AppRadius.extraLarge : AppRadius.pill,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.dayNumber,
                    style: AppTextStyles.bodyEmphasis.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (item.hasIndicator)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

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
