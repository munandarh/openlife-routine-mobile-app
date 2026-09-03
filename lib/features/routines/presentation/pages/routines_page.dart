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
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_empty_page.dart';
import 'package:openlife_routine/features/routines/presentation/utils/routine_category_ui.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoutineBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createRoutineBloc()
            ..add(const RoutineWatchRequested()),
      child: const _RoutinesView(),
    );
  }
}

class _RoutinesView extends StatelessWidget {
  const _RoutinesView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return BlocBuilder<RoutineBloc, RoutineState>(
      builder: (BuildContext context, RoutineState state) {
        if (state.status == RoutineStatus.loading && state.routines.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.routines.isEmpty) {
          return const RoutinesEmptyPage();
        }

        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: OpenLifeAppBar(
                onAddRoutine: () => context.push(OpenLifeRoute.newRoutine.path),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.lg,
                  AppSpacing.pageMargin,
                  0,
                ),
                child: Text(l10n.routinesTab, style: AppTextStyles.pageTitle),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.md + 2,
                AppSpacing.pageMargin,
                120,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  _DiscoverCard(
                    onBrowse: () => context.push(OpenLifeRoute.templates.path),
                  ),
                  const SizedBox(height: AppSpacing.lg + 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.yourRoutines,
                          style: AppTextStyles.sectionTitle,
                        ),
                      ),
                      Text(
                        l10n.activeCount(
                          state.routines
                              .where((Routine routine) => routine.isEnabled)
                              .length,
                        ),
                        style: AppTextStyles.label.copyWith(
                          color: context.palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.status == RoutineStatus.loading &&
                      state.routines.isEmpty) ...<Widget>[
                    const Center(child: CircularProgressIndicator()),
                  ] else if (state.routines.isEmpty) ...<Widget>[
                    AppEmptyState(
                      title: l10n.noRoutinesYet,
                      description: l10n.routinesListEmptyDesc,
                      buttonLabel: l10n.createRoutine,
                      icon: Icons.calendar_today_outlined,
                      onPressed: () =>
                          context.push(OpenLifeRoute.newRoutine.path),
                    ),
                  ] else ...<Widget>[
                    ...state.routines.map((Routine routine) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm + 2,
                        ),
                        child: _RoutineListRow(
                          routine: routine,
                          onToggle: (bool value) =>
                              context.read<RoutineBloc>().add(
                                RoutineEnabledToggled(
                                  routineId: routine.id,
                                  isEnabled: value,
                                ),
                              ),
                          onTap: () => context.push(
                            Uri(
                              path: OpenLifeRoute.routineDetail.path,
                              queryParameters: <String, String>{
                                'id': routine.id,
                              },
                            ).toString(),
                          ),
                        ),
                      );
                    }),
                  ],
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The template invitation, filled with the primary colour so it reads as the
/// screen's one suggestion rather than another card in the list.
class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.startFromTemplate,
            style: AppTextStyles.sectionTitle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.startFromTemplateDesc,
            style: AppTextStyles.body.copyWith(color: AppColors.primarySoft),
          ),
          const SizedBox(height: AppSpacing.md + 1),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onBrowse,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // The label has to be able to give way: "Jelajahi
                      // Templat" on a 320dp screen is wider than the card.
                      Flexible(
                        child: Text(
                          l10n.browseTemplates,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One routine in the list: category tint, title, its schedule in words, and
/// the reminders switch.
///
/// The switch is inline rather than buried in the editor because turning a
/// routine off for a while is a normal thing to do, and hiding it behind two
/// taps made people delete routines instead.
class _RoutineListRow extends StatelessWidget {
  const _RoutineListRow({
    required this.routine,
    required this.onToggle,
    required this.onTap,
  });

  final Routine routine;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.md + 1,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: RoutineCategoryUi.background(routine.category),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(
                  RoutineCategoryUi.icon(
                    routine.category,
                    iconKey: routine.iconKey,
                  ),
                  size: 19,
                  color: RoutineCategoryUi.foreground(routine.category),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      routine.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${L10nFormatters.timeOfDayLabel(context, routine.reminderTime)}'
                      ' · '
                      '${L10nFormatters.repeatDays(l10n, routine.repeatDays)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyEmphasis.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch.adaptive(
                value: routine.isEnabled,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
