import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/app/router/navigation_extensions.dart';
import 'package:openlife_routine/core/app_info.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_event.dart';
import 'package:openlife_routine/features/insights/presentation/bloc/insights_state.dart';
import 'package:openlife_routine/features/settings/presentation/widgets/settings_info_card.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// What the avatar in the app bar opens.
///
/// There is no account to show — the app has no sign-in — so rather than
/// inventing one, this says so plainly and shows what the device actually
/// knows: how many routines are active and how long the streak is.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // The numbers come from InsightsBloc rather than a second calculation
    // here: streak in particular has rules (an unfinished day only counts once
    // it is over) that must not exist in two places.
    return BlocProvider<InsightsBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createInsightsBloc()
            ..add(const InsightsStarted()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        leading: IconButton(
          onPressed: () => context.popOrGo(OpenLifeRoute.today.path),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.pageMargin,
          AppSpacing.pageMargin,
          AppSpacing.xxxl,
        ),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: context.palette.surfaceSoft,
                  foregroundColor: context.palette.textSecondary,
                  child: const Icon(Icons.person_outline, size: 40),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.appTitle, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppInfo.version,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.yourActivity, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<InsightsBloc, InsightsState>(
            builder: (BuildContext context, InsightsState state) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      icon: Icons.checklist_rounded,
                      value: '${state.totalCompleted}',
                      label: l10n.completedThisWeek,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_outlined,
                      value: '${state.streak}',
                      label: l10n.currentStreakStat,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SettingsInfoCard(
            icon: Icons.no_accounts_outlined,
            title: l10n.profileLocalOnly,
            body: l10n.profileLocalOnlyDesc,
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () => context.go(OpenLifeRoute.insights.path),
            icon: const Icon(Icons.insights_outlined),
            label: Text(l10n.insightsTab),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.go(OpenLifeRoute.settings.path),
            icon: const Icon(Icons.settings_outlined),
            label: Text(l10n.settingsTab),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: context.palette.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
