import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/localization/l10n_formatters.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_event.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_state.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/navigation/screen_header.dart';

/// 7-day completion history (PRD §8.6 / §9 navigation tree).
class InsightsHistoryPage extends StatelessWidget {
  const InsightsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsightsBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createInsightsBloc()
            ..add(const InsightsStarted()),
      child: const _InsightsHistoryView(),
    );
  }
}

class _InsightsHistoryView extends StatelessWidget {
  const _InsightsHistoryView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: BlocBuilder<InsightsBloc, InsightsState>(
        builder: (BuildContext context, InsightsState state) {
          if (state.status == InsightsStatus.loading ||
              state.status == InsightsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<InsightsDaySummary> days = state.history
              .where((InsightsDaySummary day) => day.scheduled > 0)
              .toList()
              .reversed
              .toList();

          if (days.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.pageMargin),
                child: Text(
                  l10n.historyEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.md + 2,
                AppSpacing.pageMargin,
                AppSpacing.xxxl,
              ),
              itemCount: days.length + 1,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: index == 0 ? AppSpacing.lg : AppSpacing.md),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ScreenHeader(
                    title: l10n.sevenDayHistory,
                    onBack: () => Navigator.of(context).pop(),
                  );
                }
                return _HistoryRow(day: days[index - 1]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.day});

  final InsightsDaySummary day;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  _dayLabel(context, l10n),
                  style: textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Flexible, not a bare Text: "0 dari 3 selesai" is wider than its
              // English counterpart and overflowed a 320dp row.
              Flexible(
                child: Text(
                  l10n.historyDoneCount(day.done, day.scheduled),
                  textAlign: TextAlign.end,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: day.completionRate,
              minHeight: 8,
              backgroundColor: context.palette.surfaceSoft,
              valueColor: AlwaysStoppedAnimation<Color>(
                day.completionRate >= 1.0
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
          ),
          if (day.skipped > 0 || day.missed > 0) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                if (day.skipped > 0)
                  _CountChip(
                    label: '${l10n.statusSkipped} ${day.skipped}',
                    color: context.palette.textSecondary,
                  ),
                if (day.missed > 0)
                  _CountChip(
                    label: '${l10n.statusMissed} ${day.missed}',
                    color: AppColors.warning,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Relative names for the two most recent days read better than a date.
  String _dayLabel(BuildContext context, AppLocalizations l10n) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int diff = today.difference(day.date).inDays;

    if (diff == 0) {
      return l10n.historyToday;
    }
    if (diff == 1) {
      return l10n.historyYesterday;
    }

    final List<String> names = L10nFormatters.weekdayAbbreviations(l10n);
    return '${names[day.date.weekday - 1]}, '
        '${day.date.day.toString().padLeft(2, '0')}/'
        '${day.date.month.toString().padLeft(2, '0')}';
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.palette.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
