import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
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

    return BlocBuilder<RoutineBloc, RoutineState>(
      builder: (BuildContext context, RoutineState state) {
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
                const IconCircleButton(icon: Icons.person_outline),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('Routines', style: textTheme.headlineMedium),
                ),
                const IconCircleButton(icon: Icons.notifications_none_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
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
                  Text(
                    'Discover Routines',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add structured, calm habits to your day with a single tap.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Browse Templates',
                    icon: Icons.dashboard_customize_outlined,
                    onPressed: () => context.push(OpenLifeRoute.templates.path),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Your routines', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            if (state.status == RoutineStatus.loading &&
                state.routines.isEmpty) ...<Widget>[
              const Center(child: CircularProgressIndicator()),
            ] else if (state.routines.isEmpty) ...<Widget>[
              AppEmptyState(
                title: 'No routines yet',
                description:
                    'Start one small routine today. Your list will update here automatically.',
                buttonLabel: 'Create Routine',
                icon: Icons.calendar_today_outlined,
                onPressed: () => context.push(OpenLifeRoute.newRoutine.path),
              ),
            ] else ...<Widget>[
              ...state.routines.map((Routine routine) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: RoutineCard(
                    title: routine.title,
                    timeLabel: _formatTime(routine.reminderTime),
                    icon: _iconForCategory(routine.category),
                    iconBackground: _iconBackgroundForCategory(
                      routine.category,
                    ),
                    iconColor: _iconColorForCategory(routine.category),
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
              label: 'Create routine',
              icon: Icons.add,
              onPressed: () => context.push(OpenLifeRoute.newRoutine.path),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(String reminderTime) {
    final List<String> parts = reminderTime.split(':');
    if (parts.length != 2) {
      return reminderTime;
    }

    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;
    final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
    final bool isPm = time.period == DayPeriod.pm;
    final int displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String displayMinute = time.minute.toString().padLeft(2, '0');
    final String suffix = isPm ? 'PM' : 'AM';
    return '$displayHour:$displayMinute $suffix';
  }

  IconData _iconForCategory(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => Icons.restaurant_outlined,
      RoutineCategory.water => Icons.water_drop_outlined,
      RoutineCategory.vitamin => Icons.medication_outlined,
      RoutineCategory.medicine => Icons.vaccines_outlined,
      RoutineCategory.sleep => Icons.bedtime_outlined,
      RoutineCategory.exercise => Icons.fitness_center_outlined,
      RoutineCategory.breakTime => Icons.self_improvement_outlined,
      RoutineCategory.custom => Icons.star_outline_rounded,
    };
  }

  Color _iconBackgroundForCategory(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => const Color(0xFFFFF1C8),
      RoutineCategory.water => const Color(0xFFDDEBF5),
      RoutineCategory.vitamin => const Color(0xFFFFF1C8),
      RoutineCategory.medicine => const Color(0xFFFFE0DF),
      RoutineCategory.sleep => const Color(0xFFDDEBF5),
      RoutineCategory.exercise => const Color(0xFFDDEBF5),
      RoutineCategory.breakTime => AppColors.surfaceSoft,
      RoutineCategory.custom => AppColors.primarySoft,
    };
  }

  Color _iconColorForCategory(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => AppColors.warning,
      RoutineCategory.water => AppColors.secondary,
      RoutineCategory.vitamin => AppColors.warning,
      RoutineCategory.medicine => AppColors.danger,
      RoutineCategory.sleep => AppColors.secondary,
      RoutineCategory.exercise => AppColors.secondary,
      RoutineCategory.breakTime => AppColors.primary,
      RoutineCategory.custom => AppColors.primary,
    };
  }
}
