import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/app/router/navigation_extensions.dart';
import 'package:openlife_routine/core/app_info.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.md + 2,
            AppSpacing.pageMargin,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                _CircleBack(
                  onPressed: () => context.popOrGo(OpenLifeRoute.today.path),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.profileTitle,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 19),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: context.palette.surface,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.08),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.appTitle,
                    style: AppTextStyles.pageTitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppInfo.version,
                    style: AppTextStyles.bodyEmphasis.copyWith(
                      fontSize: 13,
                      color: context.palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.yourActivity, style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.md),
            BlocBuilder<InsightsBloc, InsightsState>(
              builder: (BuildContext context, InsightsState state) {
                // stretch alone is unbounded inside a ListView; IntrinsicHeight
                // is what gives the two cards a shared height to stretch to.
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: _StatCard(
                          icon: Icons.checklist_rounded,
                          value: '${state.totalCompleted}',
                          label: l10n.completedThisWeek,
                          iconColor: AppColors.primary,
                          iconBackground: AppColors.primarySoft,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department_outlined,
                          value: '${state.streak}',
                          label: l10n.currentStreakStat,
                          iconColor: AppColors.accent,
                          iconBackground: AppColors.accentSoft,
                        ),
                      ),
                    ],
                  ),
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
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: context.palette.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 3),
      decoration: BoxDecoration(
        color: context.palette.surface,
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.md - 1),
          Text(value, style: AppTextStyles.pageTitle.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodyEmphasis.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
