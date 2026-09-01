import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';

/// Monday-first completion bars for one week.
///
/// [values] are 0..1 ratios; [labels] are the weekday initials for the active
/// locale. The bars carry a semantic percentage so the chart is not
/// colour-only.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    required this.values,
    required this.labels,
    this.maxBarHeight = 120,
    super.key,
  });

  final List<double> values;
  final List<String> labels;
  final double maxBarHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: maxBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(labels.length, (int i) {
              final double value = i < values.length
                  ? values[i].clamp(0.0, 1.0)
                  : 0.0;

              return Semantics(
                label: '${labels[i]} ${(value * 100).round()}%',
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder:
                      (BuildContext context, double animated, Widget? child) {
                        return Container(
                          width: 24,
                          // A hairline keeps an empty day visible instead of
                          // collapsing the column to nothing.
                          height: (maxBarHeight * animated).clamp(
                            2.0,
                            maxBarHeight,
                          ),
                          decoration: BoxDecoration(
                            color: animated >= 1.0
                                ? AppColors.success
                                : AppColors.primary.withValues(
                                    alpha: 0.3 + (animated * 0.7),
                                  ),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                          ),
                        );
                      },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (final String label in labels)
              SizedBox(
                width: 24,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
