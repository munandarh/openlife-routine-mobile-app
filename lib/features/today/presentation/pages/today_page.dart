import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:openlife_routine/features/routines/presentation/utils/routine_category_ui.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';
import 'package:openlife_routine/features/today/presentation/widgets/today_greeting.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
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
  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<String>? _actionSubscription;

  @override
  void initState() {
    super.initState();

    // Today snapshots its routines, so anything that changes them behind the
    // screen has to ask for a reload: coming back from another app, and a
    // reminder answered from the notification shade.
    _lifecycleListener = AppLifecycleListener(onResume: _refresh);
    _actionSubscription = AppScope.read(
      context,
    ).notificationService.routineActionStream.listen((_) => _refresh());
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _actionSubscription?.cancel();
    super.dispose();
  }

  /// Opens the routine editor and reloads on the way back.
  ///
  /// Every entry point into the editor has to do this: the one that did not
  /// (the empty state) left Today insisting nothing was scheduled while the
  /// routine existed and its reminder was already queued.
  Future<void> _openNewRoutine() async {
    await context.push(OpenLifeRoute.newRoutine.path);
    _refresh();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }
    context.read<TodayBloc>().add(const TodayRefreshRequested());
  }

  bool get _reducedMotion {
    final SettingsBloc? settings = context.read<SettingsBloc?>();
    return settings?.state.reducedMotion ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;

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
              if (!_reducedMotion) {
                setState(() => _showCelebration = true);
              }
            }
          },
          builder: (BuildContext context, TodayState state) {
            if (state.status == TodayStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!state.hasRoutines) {
              return TodayEmptyPage(onCreateRoutine: _openNewRoutine);
            }

            final List<WeekDateItem> weekItems = _buildWeekItems(
              l10n,
              state.selectedDate,
            );
            final TodayRoutineItem? nextRoutine = state.nextRoutine;

            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  leadingWidth: 68,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.pageMargin),
                    child: Center(
                      child: IconCircleButton(
                        icon: Icons.person_outline,
                        onPressed: () =>
                            context.push(OpenLifeRoute.profile.path),
                      ),
                    ),
                  ),
                  title: Text(
                    l10n.todayTab,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  actions: <Widget>[
                    IconCircleButton(
                      icon: Icons.notifications_none_rounded,
                      onPressed: () =>
                          context.push(OpenLifeRoute.notifications.path),
                    ),
                    const SizedBox(width: AppSpacing.pageMargin),
                  ],
                  pinned: true,
                  backgroundColor: context.palette.background,
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
                      subtitle: _supportiveSubtitle(l10n, state),
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
                      _ProgressCard(state: state),
                      const SizedBox(height: AppSpacing.lg),
                      _NextRoutineCard(item: nextRoutine),
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
                      Text(l10n.dailyRoutine, style: textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.items.isEmpty)
                        AppEmptyState(
                          title: l10n.noRoutinesYet,
                          description: l10n.noRoutinesForDateDesc,
                          buttonLabel: l10n.createRoutine,
                          icon: Icons.calendar_today_outlined,
                          onPressed: () async {
                            await _openNewRoutine();
                          },
                        )
                      else
                        ...state.items.map(
                          (TodayRoutineItem item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.cardGap,
                            ),
                            child: _TodayRoutineCard(item: item),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
        if (_showCelebration)
          _CelebrationOverlay(
            onDismiss: () => setState(() => _showCelebration = false),
          ),
        Positioned(
          right: AppSpacing.pageMargin,
          // The shell already keeps the bottom nav outside this Stack, so the
          // FAB only needs to clear the body edge. A larger offset pushed it
          // up over the first routine card's completion circle.
          bottom: AppSpacing.xl,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            tooltip: l10n.createRoutine,
            onPressed: () async {
              await _openNewRoutine();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  static String _supportiveSubtitle(AppLocalizations l10n, TodayState state) {
    if (state.totalCount == 0) {
      return l10n.calmDayAhead;
    }
    if (state.completedCount == state.totalCount) {
      return l10n.allFinished;
    }
    return l10n.smallProgress;
  }

  static DateTime _startOfWeek(DateTime selectedDate) {
    return selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
  }

  static int _selectedWeekIndex(DateTime selectedDate) {
    return selectedDate.weekday - 1;
  }

  static List<WeekDateItem> _buildWeekItems(
    AppLocalizations l10n,
    DateTime selectedDate,
  ) {
    final List<String> weekdays = L10nFormatters.weekdayInitials(l10n);
    final DateTime start = _startOfWeek(selectedDate);
    return List<WeekDateItem>.generate(7, (int index) {
      final DateTime date = start.add(Duration(days: index));
      return WeekDateItem(
        weekday: weekdays[index],
        dayNumber: date.day.toString(),
      );
    });
  }
}

/// Daily completion hero: counts on the left, animated ring on the right.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;
    final bool allDone =
        state.totalCount > 0 && state.completedCount == state.totalCount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[context.palette.heroStart, context.palette.heroEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.dailyProgress, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.totalCount == 0
                      ? l10n.noRoutinesScheduledForDay
                      : l10n.completedOfTotal(
                          state.completedCount,
                          state.totalCount,
                        ),
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
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
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    allDone ? l10n.allDoneBadge : l10n.stayConsistentBadge,
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
    );
  }
}

/// "Next — 08:30 Vitamin D3" strip required by PRD §8.2.
///
/// Shows the earliest routine still awaiting an answer; once everything is
/// resolved it flips to a short all-clear line rather than disappearing, so the
/// layout does not jump.
class _NextRoutineCard extends StatelessWidget {
  const _NextRoutineCard({required this.item});

  final TodayRoutineItem? item;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TodayRoutineItem? next = item;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: next == null
                ? context.palette.surfaceSoft
                : RoutineCategoryUi.background(next.category),
            foregroundColor: next == null
                ? context.palette.textSecondary
                : RoutineCategoryUi.foreground(next.category),
            child: Icon(
              next == null
                  ? Icons.check_circle_outline
                  : RoutineCategoryUi.icon(
                      next.category,
                      iconKey: next.iconKey,
                    ),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.nextUp,
                  style: textTheme.labelMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  next == null
                      ? l10n.nothingLeftToday
                      : '${L10nFormatters.timeOfDayLabel(context, next.reminderTime)} — ${next.title}',
                  style: textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in the Today checklist, wired to the bloc's done/skip/snooze events.
class _TodayRoutineCard extends StatelessWidget {
  const _TodayRoutineCard({required this.item});

  final TodayRoutineItem item;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TodayBloc bloc = context.read<TodayBloc>();

    return RoutineCard(
      title: item.title,
      timeLabel: L10nFormatters.timeOfDayLabel(context, item.reminderTime),
      statusLabel: _statusLabel(context, l10n),
      statusTone: _statusTone(),
      actions: _actions(bloc, l10n),
      icon: RoutineCategoryUi.icon(item.category, iconKey: item.iconKey),
      iconBackground: RoutineCategoryUi.background(item.category),
      iconColor: RoutineCategoryUi.foreground(item.category),
      isDone: item.status == TodayRoutineItemStatus.done,
      isDueNow: item.isDueNow,
      checkSemanticLabel: item.status == TodayRoutineItemStatus.done
          ? l10n.undoAction
          : l10n.statusDone,
      onTap: () async {
        await context.push(
          Uri(
            path: OpenLifeRoute.routineDetail.path,
            queryParameters: <String, String>{'id': item.routineId},
          ).toString(),
        );
        if (context.mounted) {
          context.read<TodayBloc>().add(const TodayRefreshRequested());
        }
      },
      onCheckTap: () {
        HapticFeedback.lightImpact();
        bloc.add(TodayRoutineCompletionToggled(item.routineId));
      },
    );
  }

  String? _statusLabel(BuildContext context, AppLocalizations l10n) {
    return switch (item.status) {
      TodayRoutineItemStatus.done => l10n.statusDone,
      TodayRoutineItemStatus.skipped => l10n.statusSkipped,
      TodayRoutineItemStatus.missed => l10n.statusMissed,
      TodayRoutineItemStatus.snoozed => item.snoozedUntil == null
          ? l10n.statusSnoozed
          : l10n.snoozedUntil(
              L10nFormatters.timeLabel(
                context,
                TimeOfDay.fromDateTime(item.snoozedUntil!),
              ),
            ),
      TodayRoutineItemStatus.pending when item.isDueNow => l10n.statusDueNow,
      TodayRoutineItemStatus.pending => null,
    };
  }

  RoutineCardTone _statusTone() {
    return switch (item.status) {
      TodayRoutineItemStatus.done => RoutineCardTone.positive,
      TodayRoutineItemStatus.missed => RoutineCardTone.attention,
      TodayRoutineItemStatus.skipped => RoutineCardTone.muted,
      TodayRoutineItemStatus.snoozed => RoutineCardTone.muted,
      TodayRoutineItemStatus.pending => item.isDueNow
          ? RoutineCardTone.attention
          : RoutineCardTone.positive,
    };
  }

  List<RoutineCardAction> _actions(TodayBloc bloc, AppLocalizations l10n) {
    // Skip and Snooze are only offered while the routine is still open;
    // anything already resolved offers a single Undo instead.
    if (item.isOpen) {
      return <RoutineCardAction>[
        RoutineCardAction(
          label: l10n.skipAction,
          onPressed: () => bloc.add(TodayRoutineSkipped(item.routineId)),
        ),
        RoutineCardAction(
          label: l10n.snoozeAction,
          onPressed: () => bloc.add(TodayRoutineSnoozed(item.routineId)),
        ),
      ];
    }

    if (item.status == TodayRoutineItemStatus.missed) {
      return const <RoutineCardAction>[];
    }

    return <RoutineCardAction>[
      RoutineCardAction(
        label: l10n.undoAction,
        onPressed: () {
          if (item.status == TodayRoutineItemStatus.skipped) {
            bloc.add(TodayRoutineSkipped(item.routineId));
            return;
          }
          bloc.add(TodayRoutineCompletionToggled(item.routineId));
        },
      ),
    ];
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
    final AppLocalizations l10n = context.l10n;

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
                    illustrationPath: AssetVectors.todayDailyCelebration.path,
                    fallbackIcon: Icons.celebration_outlined,
                    size: 120,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.allDone,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.allDoneMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.palette.textSecondary,
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
