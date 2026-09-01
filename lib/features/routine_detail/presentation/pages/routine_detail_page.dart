import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/app/router/navigation_extensions.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/localization/l10n_formatters.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
import 'package:openlife_routine/features/routines/presentation/utils/routine_category_ui.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class RoutineDetailPage extends StatelessWidget {
  const RoutineDetailPage({required this.routineId, super.key});

  final String routineId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoutineBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createRoutineBloc()
            ..add(RoutineDetailRequested(routineId)),
      child: _RoutineDetailView(routineId: routineId),
    );
  }
}

class _RoutineDetailView extends StatelessWidget {
  const _RoutineDetailView({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutineBloc, RoutineState>(
      listener: (BuildContext context, RoutineState state) {
        if (state.deleted) {
          context.popOrGo(OpenLifeRoute.today.path);
        }
      },
      builder: (BuildContext context, RoutineState state) {
        final TextTheme textTheme = Theme.of(context).textTheme;
        final AppLocalizations l10n = context.l10n;
        final Routine? routine = state.selectedRoutine;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.pageMargin,
                AppSpacing.pageMargin,
                AppSpacing.xxxl,
              ),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => context.popOrGo(OpenLifeRoute.today.path),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    Expanded(
                      child: Text(
                        l10n.routineDetailTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const IconCircleButton(icon: Icons.more_horiz_rounded),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (routine == null &&
                    state.status == RoutineStatus.loading) ...<Widget>[
                  const Center(child: CircularProgressIndicator()),
                ] else if (routine == null) ...<Widget>[
                  Text(
                    state.errorMessage ?? l10n.routineNotFound,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ] else ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              RoutineCategoryUi.background(routine.category),
                          foregroundColor:
                              RoutineCategoryUi.foreground(routine.category),
                          child: Icon(
                            RoutineCategoryUi.icon(
                              routine.category,
                              iconKey: routine.iconKey,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(routine.title, style: textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          RoutineCategoryUi.routineLabel(l10n, routine.category),
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DetailCard(
                    title: l10n.scheduleLabel,
                    rows: <String>[
                      L10nFormatters.repeatDays(l10n, routine.repeatDays),
                      L10nFormatters.timeOfDayLabel(
                        context,
                        routine.reminderTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _DetailCard(
                    title: l10n.reminderBehavior,
                    rows: <String>[
                      l10n.snoozeForMinutes(routine.snoozeMinutes),
                      routine.isEnabled
                          ? l10n.routineIsActive
                          : l10n.routineIsDisabled,
                    ],
                  ),
                  if (routine.notes != null &&
                      routine.notes!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.cardGap),
                    _DetailCard(
                      title: l10n.notesLabel,
                      rows: <String>[routine.notes!.trim()],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: l10n.editRoutineAction,
                    onPressed: () => context.push(
                      Uri(
                        path: OpenLifeRoute.newRoutine.path,
                        queryParameters: <String, String>{'id': routineId},
                      ).toString(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: l10n.deleteRoutine,
                    isSecondary: true,
                    onPressed: () {
                      context.read<RoutineBloc>().add(
                        RoutineDeleteRequested(routineId),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.rows});

  final String title;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...rows.map(
            (String row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                row,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
