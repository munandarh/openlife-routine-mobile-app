import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/features/today/presentation/widgets/today_greeting.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';
import 'package:openlife_routine/shared/widgets/forms/week_date_selector.dart';
import 'package:openlife_routine/shared/widgets/progress/progress_ring.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

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

class _TodayView extends StatefulWidget {
  const _TodayView();

  @override
  State<_TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<_TodayView> {
  bool _showCelebration = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      children: <Widget>[
        BlocConsumer<TodayBloc, TodayState>(
          listenWhen: (TodayState previous, TodayState current) {
            // Trigger celebration when all routines are completed.
            return current.totalCount > 0 &&
                current.completedCount == current.totalCount &&
                (previous.completedCount != current.completedCount ||
                    previous.totalCount != current.totalCount);
          },
          listener: (BuildContext context, TodayState state) {
            if (state.totalCount > 0 &&
                state.completedCount == state.totalCount) {
              HapticFeedback.mediumImpact();
              setState(() => _showCelebration = true);
            }
          },
          builder: (BuildContext context, TodayState state) {
            if (state.status == TodayStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!state.hasRoutines) {
              return const TodayEmptyPage();
            }

            final List<WeekDateItem> weekItems = _buildWeekItems(
              state.selectedDate,
            );

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
                    'Today',
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
              backgroundColor: AppColors.background,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.md,
                  AppSpacing.pageMargin,
                  0,
                ),
                child: TodayGreeting(
                  subtitle: _supportiveSubtitle(state),
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
                          HapticFeedback.lightImpact();
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
              ]),
            ),
          ),
        ],
      );
          },
        ),
        // Celebration overlay.
        if (_showCelebration)
          _CelebrationOverlay(
            onDismiss: () => setState(() => _showCelebration = false),
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

  static String _supportiveSubtitle(TodayState state) {
    if (state.totalCount == 0) {
      return 'A calm day ahead. Add a routine whenever you are ready.';
    }
    if (state.completedCount == state.totalCount) {
      return 'You finished all your routines today. Great work.';
    }
    return 'Small progress still counts. Take it one step at a time.';
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

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black38,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.xl),
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.extraLarge),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  OpenLifeRiveView.illustration(
                    illustrationPath:
                        AssetVectors.todayDailyCelebration.path,
                    fallbackIcon: Icons.celebration_outlined,
                    size: 120,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'All Done!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'You completed all your routines for today. Great work!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ..._buildSparkles(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    const List<Color> colors = <Color>[
      AppColors.success,
      AppColors.warning,
      AppColors.secondary,
      AppColors.primary,
      AppColors.danger,
    ];

    return List<Widget>.generate(5, (int i) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colors[i].withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}
