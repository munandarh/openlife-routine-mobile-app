import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';
import 'package:openlife_routine/shared/widgets/forms/week_date_selector.dart';
import 'package:openlife_routine/shared/widgets/progress/progress_ring.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodayBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createTodayBloc()..add(const TodayStarted()),
      child: const _TodayView(),
    );
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      children: <Widget>[
        BlocBuilder<TodayBloc, TodayState>(
          builder: (BuildContext context, TodayState state) {
            final List<WeekDateItem> weekItems = _buildWeekItems(
              state.selectedDate,
            );

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
                      child: Text(
                        'Today',
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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.primarySoft, Color(0xFFE9F2D7)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Daily Progress', style: textTheme.titleLarge),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              state.totalCount == 0
                                  ? 'No routines scheduled for this day.'
                                  : '${state.completedCount} of ${state.totalCount} routines completed.',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                state.completedCount == state.totalCount &&
                                        state.totalCount > 0
                                    ? 'ALL DONE'
                                    : 'STAY CONSISTENT',
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ProgressRing(
                        progress: state.progress,
                        label: '${state.completedCount}/${state.totalCount}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                WeekDateSelector(
                  selectedIndex: _selectedWeekIndex(state.selectedDate),
                  items: weekItems,
                  onSelected: (int index) {
                    context.read<TodayBloc>().add(
                      TodayDateSelected(
                        _startOfWeek(
                          state.selectedDate,
                        ).add(Duration(days: index)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text('Daily routine', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                if (state.status == TodayStatus.loading)
                  const Center(child: CircularProgressIndicator())
                else if (state.items.isEmpty)
                  AppEmptyState(
                    title: 'No routines yet',
                    description:
                        'There is nothing scheduled for this date. Add one or pick another day.',
                    buttonLabel: 'Create routine',
                    icon: Icons.calendar_today_outlined,
                    onPressed: () =>
                        context.push(OpenLifeRoute.newRoutine.path),
                  )
                else
                  ...state.items.map(
                    (TodayRoutineItem item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.cardGap,
                      ),
                      child: RoutineCard(
                        title: item.title,
                        timeLabel: _formatTime(item.reminderTime),
                        statusLabel: switch (item.status) {
                          TodayRoutineItemStatus.done => 'Done',
                          TodayRoutineItemStatus.skipped => 'Skipped',
                          TodayRoutineItemStatus.pending when item.isDueNow =>
                            'Due Now',
                          _ => null,
                        },
                        secondaryActionLabel:
                            item.status == TodayRoutineItemStatus.pending
                            ? 'Skip'
                            : 'Undo',
                        icon: _iconForCategory(item.category),
                        iconBackground: _iconBackgroundForCategory(
                          item.category,
                        ),
                        iconColor: _iconColorForCategory(item.category),
                        isDone: item.status == TodayRoutineItemStatus.done,
                        isDueNow: item.isDueNow,
                        onTap: () => context.push(
                          Uri(
                            path: OpenLifeRoute.routineDetail.path,
                            queryParameters: <String, String>{
                              'id': item.routineId,
                            },
                          ).toString(),
                        ),
                        onCheckTap: () {
                          context.read<TodayBloc>().add(
                            TodayRoutineCompletionToggled(item.routineId),
                          );
                        },
                        onSecondaryAction: () {
                          if (item.status == TodayRoutineItemStatus.pending) {
                            context.read<TodayBloc>().add(
                              TodayRoutineSkipped(item.routineId),
                            );
                            return;
                          }

                          if (item.status == TodayRoutineItemStatus.skipped) {
                            context.read<TodayBloc>().add(
                              TodayRoutineSkipped(item.routineId),
                            );
                            return;
                          }

                          context.read<TodayBloc>().add(
                            TodayRoutineCompletionToggled(item.routineId),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Positioned(
          right: AppSpacing.pageMargin,
          bottom: 104,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () => context.push(OpenLifeRoute.newRoutine.path),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  static String _formatTime(String reminderTime) {
    final List<String> parts = reminderTime.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = int.tryParse(parts.last) ?? 0;
    final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
    final int displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String displayMinute = time.minute.toString().padLeft(2, '0');
    final String suffix = time.period == DayPeriod.pm ? 'PM' : 'AM';
    return '$displayHour:$displayMinute $suffix';
  }

  static DateTime _startOfWeek(DateTime selectedDate) {
    return selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
  }

  static int _selectedWeekIndex(DateTime selectedDate) {
    return selectedDate.weekday - 1;
  }

  static List<WeekDateItem> _buildWeekItems(DateTime selectedDate) {
    const List<String> weekdays = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final DateTime start = _startOfWeek(selectedDate);
    return List<WeekDateItem>.generate(7, (int index) {
      final DateTime date = start.add(Duration(days: index));
      return WeekDateItem(
        weekday: weekdays[index],
        dayNumber: date.day.toString(),
      );
    });
  }

  static IconData _iconForCategory(RoutineCategory category) {
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

  static Color _iconBackgroundForCategory(RoutineCategory category) {
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

  static Color _iconColorForCategory(RoutineCategory category) {
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
