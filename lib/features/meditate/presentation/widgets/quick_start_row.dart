import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class QuickStartRow extends StatelessWidget {
  const QuickStartRow({this.onDurationSelected, super.key});

  final ValueChanged<int>? onDurationSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final List<(int minutes, String label)> durations = <(int, String)>[
      (3, l10n.threeMinutes),
      (5, l10n.fiveMinutes),
      (10, l10n.tenMinutes),
      (15, l10n.fifteenMinutes),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.quickStart,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(
          children: durations.map(((int, String) item) {
            final (int minutes, String label) = item;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    onTap: () => onDurationSelected?.call(minutes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: context.palette.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.palette.primarySoft.withValues(
                                alpha: 0.6,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: context.palette.primaryInk,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs + 2),
                          Text(
                            label,
                            style: AppTextStyles.bodyEmphasis.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
