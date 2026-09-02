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
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
import 'package:openlife_routine/features/routines/presentation/pages/routines_empty_page.dart';
import 'package:openlife_routine/features/routines/presentation/utils/routine_category_ui.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';

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
    final TextTheme textTheme = Theme.of(context).textTheme;
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
            SliverAppBar(
              leadingWidth: 68,
              leading: const Padding(
                padding: EdgeInsets.only(left: AppSpacing.pageMargin),
                child: Center(
                  child: IconCircleButton(icon: Icons.person_outline),
                ),
              ),
              title: Text(
                l10n.routinesTab,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              actions: const <Widget>[
                IconCircleButton(
                  icon: Icons.notifications_none_rounded,
                ),
                SizedBox(width: AppSpacing.pageMargin),
              ],
              pinned: true,
              backgroundColor: context.palette.background,
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
                  Text(
                    l10n.discoverRoutines,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.addStructured,
                    style: textTheme.bodyLarge?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: l10n.browseTemplates,
                    icon: Icons.dashboard_customize_outlined,
                    onPressed: () => context.push(OpenLifeRoute.templates.path),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.yourRoutines, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            if (state.status == RoutineStatus.loading &&
                state.routines.isEmpty) ...<Widget>[
              const Center(child: CircularProgressIndicator()),
            ] else if (state.routines.isEmpty) ...<Widget>[
              AppEmptyState(
                title: l10n.noRoutinesYet,
                description: l10n.routinesListEmptyDesc,
                buttonLabel: l10n.createRoutine,
                icon: Icons.calendar_today_outlined,
                onPressed: () => context.push(OpenLifeRoute.newRoutine.path),
              ),
            ] else ...<Widget>[
              ...state.routines.map((Routine routine) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: RoutineCard(
                    title: routine.title,
                    timeLabel: L10nFormatters.timeOfDayLabel(
                      context,
                      routine.reminderTime,
                    ),
                    statusLabel: routine.isEnabled
                        ? null
                        : l10n.routineIsDisabled,
                    statusTone: RoutineCardTone.muted,
                    icon: RoutineCategoryUi.icon(
                      routine.category,
                      iconKey: routine.iconKey,
                    ),
                    iconBackground:
                        RoutineCategoryUi.background(routine.category),
                    iconColor: RoutineCategoryUi.foreground(routine.category),
                    onTap: () => context.push(
                      Uri(
                        path: OpenLifeRoute.routineDetail.path,
                        queryParameters: <String, String>{'id': routine.id},
                      ).toString(),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: AppSpacing.cardGap),
            PrimaryButton(
              label: l10n.createRoutine,
              icon: Icons.add,
              onPressed: () => context.push(OpenLifeRoute.newRoutine.path),
            ),
          ]),
        ),
      ),
    ],
  );
      },
    );
  }
}
