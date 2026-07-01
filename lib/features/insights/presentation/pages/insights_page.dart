import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_event.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_state.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';

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

    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (BuildContext context, InsightsState state) {
        if (state.status == InsightsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final String completionPercent =
            '${(state.weeklyCompletionRate * 100).round()}%';
        final String streakLabel = '${state.streak} days';

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.pageMargin,
            AppSpacing.pageMargin,
            120,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceSoft,
                  child: Icon(
                    Icons.insights_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Insights',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const IconCircleButton(
                  icon: Icons.notifications_none_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricCard(
                    value: completionPercent,
                    label: 'Completed this week',
                    icon: Icons.adjust_outlined,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: _MetricCard(
                    value: streakLabel,
                    label: 'Best streak',
                    icon: Icons.local_fire_department_outlined,
                    iconColor: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              height: 240,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("This Week's Flow", style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List<Widget>.generate(
                        state.dailyCompletion.length,
                        (int i) {
                          final double value =
                              state.dailyCompletion.length > i
                              ? state.dailyCompletion[i]
                              : 0.0;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width: 24,
                                height: 120 * value.clamp(0.0, 1.0),
                                decoration: BoxDecoration(
                                  color: value >= 1.0
                                      ? AppColors.success
                                      : AppColors.primary.withValues(
                                        alpha: 0.3 + (value * 0.7),
                                      ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('M'),
                      Text('T'),
                      Text('W'),
                      Text('T'),
                      Text('F'),
                      Text('S'),
                      Text('S'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Focus Areas', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            if (state.totalRoutines > 0) ...<Widget>[
              if (state.weeklyCompletionRate >= 0.7)
                _InsightBanner(
                  icon: Icons.celebration_outlined,
                  title: "You're doing great this week!",
                  message:
                      'Keep up the momentum — consistency builds better days.',
                )
              else if (state.mostMissedRoutine != null)
                _InsightBanner(
                  icon: Icons.self_improvement_outlined,
                  title: 'Small progress still counts.',
                  message:
                      'Some routines were missed this week. Try again tomorrow — every step matters.',
                )
              else
                _InsightBanner(
                  icon: Icons.water_drop_outlined,
                  title: 'Build your routine rhythm.',
                  message:
                      'Add routines and start tracking to see your weekly insights here.',
                ),
            ] else
              _InsightBanner(
                icon: Icons.event_note_outlined,
                title: 'No routines tracked yet.',
                message:
                    'Create your first routine and start building insights over time.',
              ),
          ],
        );
      },
    );
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
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor),
          const SizedBox(height: AppSpacing.lg),
          Text(value, style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
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
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.secondary,
            child: Icon(Icons.water_drop_outlined),
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
                    color: AppColors.textSecondary,
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
