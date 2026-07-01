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
          context.pop();
        }
      },
      builder: (BuildContext context, RoutineState state) {
        final TextTheme textTheme = Theme.of(context).textTheme;
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
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Routine Detail',
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
                    state.errorMessage ?? 'Routine not found.',
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
                          backgroundColor: _iconBackground(routine.category),
                          foregroundColor: _iconColor(routine.category),
                          child: Icon(_icon(routine.category)),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(routine.title, style: textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _categoryLabel(routine.category),
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DetailCard(
                    title: 'Schedule',
                    rows: <String>[
                      _formatRepeatDays(routine.repeatDays),
                      _formatTime(routine.reminderTime),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _DetailCard(
                    title: 'Reminder behavior',
                    rows: <String>[
                      'Snooze for ${routine.snoozeMinutes} minutes',
                      routine.isEnabled
                          ? 'Routine is active'
                          : 'Routine is disabled',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: 'Edit routine',
                    onPressed: () => context.push(
                      Uri(
                        path: OpenLifeRoute.newRoutine.path,
                        queryParameters: <String, String>{'id': routineId},
                      ).toString(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Delete routine',
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

  String _categoryLabel(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.meal => 'Meal routine',
      RoutineCategory.water => 'Hydration routine',
      RoutineCategory.vitamin => 'Vitamin routine',
      RoutineCategory.medicine => 'Medicine routine',
      RoutineCategory.sleep => 'Sleep routine',
      RoutineCategory.exercise => 'Exercise routine',
      RoutineCategory.breakTime => 'Break routine',
      RoutineCategory.custom => 'Custom routine',
    };
  }

  String _formatRepeatDays(List<int> repeatDays) {
    const List<String> labels = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return repeatDays.map((int day) => labels[day - 1]).join(', ');
  }

  String _formatTime(String reminderTime) {
    final List<String> parts = reminderTime.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = int.tryParse(parts.last) ?? 0;
    final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
    final int displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String displayMinute = time.minute.toString().padLeft(2, '0');
    final String suffix = time.period == DayPeriod.pm ? 'PM' : 'AM';
    return '$displayHour:$displayMinute $suffix';
  }

  IconData _icon(RoutineCategory category) {
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

  Color _iconBackground(RoutineCategory category) {
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

  Color _iconColor(RoutineCategory category) {
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
