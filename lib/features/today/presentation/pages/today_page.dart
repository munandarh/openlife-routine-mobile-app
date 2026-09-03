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
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/routines/presentation/utils/routine_category_ui.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/today/presentation/bloc/today_bloc.dart';
import 'package:openlife_routine/features/today/presentation/pages/today_empty_page.dart';
import 'package:openlife_routine/features/today/presentation/widgets/today_greeting.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';
import 'package:openlife_routine/shared/widgets/forms/week_date_selector.dart';
import 'package:openlife_routine/shared/widgets/illustrations/app_illustration.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';
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
              // The app bar stays: without it the empty state is the one
              // screen where Profile and Notifications cannot be reached.
              return Column(
                children: <Widget>[
                  const OpenLifeAppBar.tab(),
                  Expanded(
                    child: TodayEmptyPage(onCreateRoutine: _openNewRoutine),
                  ),
                ],
              );
            }

            final List<WeekDateItem> weekItems = _buildWeekItems(
              l10n,
              state.selectedDate,
            );
            final TodayRoutineItem? nextRoutine = state.nextRoutine;

            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: const OpenLifeAppBar.tab()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageMargin,
                      AppSpacing.lg,
                      AppSpacing.pageMargin,
                      0,
                    ),
                    child: _GreetingAndProgress(
                      state: state,
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
                      _NextRoutineCard(item: nextRoutine),
                      const SizedBox(height: AppSpacing.lg),
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
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              l10n.dailyRoutine,
                              style: AppTextStyles.sectionTitle,
                            ),
                          ),
                          if (state.totalCount > state.completedCount)
                            Text(
                              l10n.routinesLeft(
                                state.totalCount - state.completedCount,
                              ),
                              style: AppTextStyles.label.copyWith(
                                color: context.palette.textMuted,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
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
                              bottom: AppSpacing.sm + 2,
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
/// The Today header: greeting and streak on the left, the day's dial on the
/// right.
///
/// This replaced a full-width gradient hero card. Pairing the two halves is
/// what buys the vertical room the routine list needs — the hero card and a
/// separate greeting cost roughly 90px more for the same information.
class _GreetingAndProgress extends StatelessWidget {
  const _GreetingAndProgress({required this.state, required this.subtitle});

  final TodayState state;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TodayGreeting(subtitle: subtitle),
              if (state.streak > 0) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                _StreakPill(days: state.streak),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        ProgressRing(
          progress: state.progress,
          label: '${state.completedCount}/${state.totalCount}',
          caption: l10n.doneLabel,
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm - 1),
          Text(
            context.l10n.streakDays(days),
            style: AppTextStyles.bodyEmphasis.copyWith(
              color: context.palette.textPrimary,
            ),
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
/// The next reminder due, filled with the primary colour.
///
/// It is the one thing on the screen that says "this is what happens next", so
/// it carries the weight rather than sitting in another white card.
class _NextRoutineCard extends StatelessWidget {
  const _NextRoutineCard({required this.item});

  final TodayRoutineItem? item;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TodayRoutineItem? next = item;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.primary,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              next == null
                  ? Icons.check_circle_outline
                  : RoutineCategoryUi.icon(
                      next.category,
                      iconKey: next.iconKey,
                    ),
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md + 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.nextUp.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11.5,
                    letterSpacing: 0.9,
                    color: AppColors.primarySoft,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  next == null
                      ? l10n.nothingLeftToday
                      : '${L10nFormatters.timeOfDayLabel(context, next.reminderTime)}'
                            ' · '
                            '${next.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One routine on Today, in the three shapes the mockups define.
///
/// The routine that is due fills its card with the category tint and puts
/// Snooze and Skip on full-width white pills underneath — it is the only card
/// asking for something, so it is the only one that looks different. Done and
/// upcoming routines stay quiet on white.
class _TodayRoutineCard extends StatelessWidget {
  const _TodayRoutineCard({required this.item});

  final TodayRoutineItem item;

  bool get _isDue =>
      item.isDueNow && item.status == TodayRoutineItemStatus.pending;
  bool get _isDone => item.status == TodayRoutineItemStatus.done;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Brightness brightness = Theme.of(context).brightness;
    final Color tint = RoutineCategoryUi.background(
      item.category,
      brightness: brightness,
    );
    final Color ink = RoutineCategoryUi.foreground(
      item.category,
      brightness: brightness,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 1),
      decoration: BoxDecoration(
        color: _isDue ? tint : context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: _isDue
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  // On a tinted card the chip goes white so the icon still
                  // reads; elsewhere the chip carries the tint.
                  color: _isDue ? context.palette.surface : tint,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(
                  RoutineCategoryUi.icon(item.category, iconKey: item.iconKey),
                  size: 19,
                  color: ink,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _titleAndStatus(context, l10n, ink)),
              const SizedBox(width: AppSpacing.sm),
              _CompletionCircle(
                isDone: _isDone,
                outline: _isDue
                    ? context.palette.surface
                    : context.palette.border,
                // The circle had no accessible name at all: a screen reader
                // announced only "button" for the screen's primary action.
                label: _isDone
                    ? l10n.markNotDoneAction(item.title)
                    : l10n.markDoneAction(item.title),
                onTap: () => context.read<TodayBloc>().add(
                  TodayRoutineCompletionToggled(item.routineId),
                ),
              ),
            ],
          ),
          if (_isDue) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: _QuietAction(
                    label: l10n.snoozeAction,
                    tone: context.palette.primaryInk,
                    onTap: () => context.read<TodayBloc>().add(
                      TodayRoutineSnoozed(item.routineId),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _QuietAction(
                    label: l10n.skipAction,
                    tone: context.palette.textSecondary,
                    onTap: () => context.read<TodayBloc>().add(
                      TodayRoutineSkipped(item.routineId),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _titleAndStatus(
    BuildContext context,
    AppLocalizations l10n,
    Color ink,
  ) {
    final String time = L10nFormatters.timeOfDayLabel(
      context,
      item.reminderTime,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.cardTitle.copyWith(
            color: _isDone
                ? context.palette.textMuted
                : context.palette.textPrimary,
            decoration: _isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(height: 3),
        if (_isDue)
          // Wrap, not Row: at 320dp a long time plus the badge is wider than
          // the card, and dropping the badge to a second line beats clipping.
          Wrap(
            spacing: AppSpacing.sm - 1,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                time,
                style: AppTextStyles.bodyEmphasis.copyWith(color: ink),
              ),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: context.palette.accentSoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    l10n.statusDueNow.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10.5,
                      letterSpacing: 0.5,
                      color: context.palette.accentInk,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            _statusLine(l10n, time),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyEmphasis.copyWith(
              color: _isDone
                  ? context.palette.primaryInk
                  : context.palette.textSecondary,
            ),
          ),
      ],
    );
  }

  String _statusLine(AppLocalizations l10n, String time) {
    return switch (item.status) {
      TodayRoutineItemStatus.done => '${l10n.statusDone} · $time',
      TodayRoutineItemStatus.skipped => '${l10n.statusSkipped} · $time',
      TodayRoutineItemStatus.missed => '${l10n.statusMissed} · $time',
      TodayRoutineItemStatus.snoozed => l10n.snoozedUntil(
        item.snoozedUntil == null ? time : _hhmm(item.snoozedUntil!),
      ),
      TodayRoutineItemStatus.pending => '${l10n.statusUpcoming} · $time',
    };
  }

  static String _hhmm(DateTime value) {
    final String h = value.hour.toString().padLeft(2, '0');
    final String m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// The tap target for completing a routine: an outline when open, a filled
/// sage disc with a check when done.
class _CompletionCircle extends StatelessWidget {
  const _CompletionCircle({
    required this.isDone,
    required this.outline,
    required this.label,
    required this.onTap,
  });

  final bool isDone;
  final Color outline;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: isDone,
      label: label,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primary : Colors.transparent,
            border: isDone ? null : Border.all(color: outline, width: 2.5),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 22, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

/// Snooze and Skip on the due card: white pills on the tint, weight carried by
/// the completion circle rather than by these.
class _QuietAction extends StatelessWidget {
  const _QuietAction({
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final Color tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.button.copyWith(color: tone),
            ),
          ),
        ),
      ),
    );
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
                  AppIllustration(
                    assetPath: AssetVectors.todayDailyCelebration.path,
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
      AppColors.primary,
      AppColors.accent,
      AppColors.mealInk,
      AppColors.waterInk,
      AppColors.sleepInk,
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
