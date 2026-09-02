import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
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
import 'package:openlife_routine/features/insights/presentation/pages/insights_empty_page.dart';
import 'package:openlife_routine/features/insights/presentation/widgets/weekly_bar_chart.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsightsBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createInsightsBloc()
            ..add(const InsightsStarted()),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;

    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (BuildContext context, InsightsState state) {
        if (state.status == InsightsStatus.loading ||
            state.status == InsightsStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.totalRoutines == 0) {
          return const InsightsEmptyPage();
        }

        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leadingWidth: 68,
              leading: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.pageMargin),
                child: Center(
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: context.palette.surfaceSoft,
                    child: const Icon(
                      Icons.insights_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              title: Text(
                l10n.insightsTitle,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              actions: <Widget>[
                IconCircleButton(
                  icon: Icons.notifications_none_rounded,
                  onPressed: () =>
                      context.push(OpenLifeRoute.notifications.path),
                ),
                const SizedBox(width: AppSpacing.pageMargin),
              ],
              pinned: true,
              backgroundColor: context.palette.background,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMargin,
                ),
                child: OpenLifeRiveView.illustration(
                  illustrationPath: AssetVectors.todayInsightsWorkspace.path,
                  fallbackIcon: Icons.insights_outlined,
                  size: 180,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.xl,
                AppSpacing.pageMargin,
                120,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MetricCard(
                          value:
                              '${(state.weeklyCompletionRate * 100).round()}%',
                          label: l10n.completedThisWeek,
                          icon: Icons.adjust_outlined,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.cardGap),
                      Expanded(
                        child: _MetricCard(
                          value: l10n.daysLabel(state.streak),
                          label: l10n.bestStreak,
                          icon: Icons.local_fire_department_outlined,
                          iconColor: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                      border: Border.all(color: context.palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.thisWeeksFlow, style: textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.lg),
                        WeeklyBarChart(
                          values: state.dailyCompletion,
                          labels: L10nFormatters.weekdayInitials(l10n),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: l10n.viewHistory,
                    isSecondary: true,
                    icon: Icons.history_outlined,
                    onPressed: () =>
                        context.push(OpenLifeRoute.insightsHistory.path),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.focusAreas, style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.mostCompletedRoutine != null) ...<Widget>[
                    _RoutineMetricTile(
                      icon: Icons.emoji_events_outlined,
                      label: l10n.mostCompleted,
                      metric: state.mostCompletedRoutine!,
                      countLabel: l10n.timesCount(
                        state.mostCompletedRoutine!.count,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                  ],
                  if (state.mostMissedRoutine != null) ...<Widget>[
                    _RoutineMetricTile(
                      icon: Icons.schedule_outlined,
                      label: l10n.mostMissed,
                      metric: state.mostMissedRoutine!,
                      countLabel: l10n.timesCount(
                        state.mostMissedRoutine!.count,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                  ],
                  _InsightBanner(
                    icon: _bannerIcon(state),
                    title: _bannerTitle(l10n, state),
                    message: _bannerMessage(l10n, state),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  static IconData _bannerIcon(InsightsState state) {
    if (state.totalRoutines == 0) {
      return Icons.event_note_outlined;
    }
    if (state.weeklyCompletionRate >= 0.7) {
      return Icons.celebration_outlined;
    }
    return state.mostMissedRoutine != null
        ? Icons.self_improvement_outlined
        : Icons.water_drop_outlined;
  }

  static String _bannerTitle(AppLocalizations l10n, InsightsState state) {
    if (state.totalRoutines == 0) {
      return l10n.insightNoRoutinesTitle;
    }
    if (state.weeklyCompletionRate >= 0.7) {
      return l10n.insightGreatTitle;
    }
    return state.mostMissedRoutine != null
        ? l10n.insightSmallProgressTitle
        : l10n.insightBuildRhythmTitle;
  }

  static String _bannerMessage(AppLocalizations l10n, InsightsState state) {
    if (state.totalRoutines == 0) {
      return l10n.insightNoRoutinesMessage;
    }
    if (state.weeklyCompletionRate >= 0.7) {
      return l10n.insightGreatMessage;
    }
    return state.mostMissedRoutine != null
        ? l10n.insightSmallProgressMessage
        : l10n.insightBuildRhythmMessage;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor),
          const SizedBox(height: AppSpacing.lg),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: context.palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RoutineMetricTile extends StatelessWidget {
  const _RoutineMetricTile({
    required this.icon,
    required this.label,
    required this.metric,
    required this.countLabel,
  });

  final IconData icon;
  final String label;
  final RoutineMetric metric;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(metric.title, style: textTheme.titleMedium),
              ],
            ),
          ),
          Text(
            countLabel,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.secondary,
            child: Icon(icon),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
