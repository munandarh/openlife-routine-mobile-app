import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/app/router/navigation_extensions.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/localization/l10n_formatters.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/storage/app_database.dart'
    show RoutineBundleRow;
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/utils/routine_category_ui.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// What the bell in the app bar opens: the reminders that are actually
/// queued, so "did my reminder get set?" has an answer inside the app.
///
/// The list comes from [AppNotificationService.upcomingReminders], the same
/// arithmetic the scheduler uses, so this screen cannot claim a reminder the
/// OS was never told about.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Routine>> _routines;

  @override
  void initState() {
    super.initState();
    _routines = _load();
  }

  /// Reads the rows directly rather than watching the repository stream:
  /// Drift streams never deliver under `testWidgets`, and this screen only
  /// needs the state as it is when opened.
  Future<List<Routine>> _load() async {
    final List<RoutineBundleRow> bundles = await AppScope.read(
      context,
    ).appDatabase.getRoutineBundles();
    return bundles.map(AppNotificationService.routineFromBundle).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Routine>>(
          future: _routines,
          builder:
              (BuildContext context, AsyncSnapshot<List<Routine>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<RoutineReminderSlot> upcoming =
                    AppNotificationService.upcomingReminders(
                      snapshot.data ?? const <Routine>[],
                    );

                return ListView(
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
                          onPressed: () =>
                              context.popOrGo(OpenLifeRoute.today.path),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.notificationsTitle,
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 19,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.upcomingRemindersDesc,
                      style: AppTextStyles.body.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (upcoming.isEmpty)
                      _EmptyState(l10n: l10n)
                    else
                      ..._grouped(context, l10n, upcoming),
                    const SizedBox(height: AppSpacing.lg),
                    _WhitePillAction(
                      icon: Icons.notifications_active_outlined,
                      label: l10n.manageAlerts,
                      onPressed: () => context.go(OpenLifeRoute.settings.path),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }
}

/// Splits the queue into Today / Tomorrow / Later, each under its own label.
///
/// A flat list forced every row to repeat the day; the grouping lets a row say
/// only what is particular to it.
List<Widget> _grouped(
  BuildContext context,
  AppLocalizations l10n,
  List<RoutineReminderSlot> slots,
) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  int bucketOf(RoutineReminderSlot slot) {
    final int days = DateTime(
      slot.firesAt.year,
      slot.firesAt.month,
      slot.firesAt.day,
    ).difference(today).inDays;
    return days <= 0 ? 0 : (days == 1 ? 1 : 2);
  }

  final List<Widget> children = <Widget>[];
  int? lastBucket;

  for (final RoutineReminderSlot slot in slots) {
    final int bucket = bucketOf(slot);
    if (bucket != lastBucket) {
      children.add(
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xs,
            top: lastBucket == null ? 0 : AppSpacing.sm,
            bottom: AppSpacing.sm - 2,
          ),
          child: Text(
            switch (bucket) {
              0 => l10n.todayTab,
              1 => l10n.tomorrowLabel,
              _ => l10n.laterLabel,
            }.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              letterSpacing: 1.1,
              color: context.palette.textMuted,
            ),
          ),
        ),
      );
      lastBucket = bucket;
    }
    children.add(
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        child: _ReminderTile(slot: slot),
      ),
    );
  }

  return children;
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.slot});

  final RoutineReminderSlot slot;

  /// "Today"/"Tomorrow" where that is true, otherwise the weekday, because a
  /// bare date is harder to place than the day it lands on.
  String _whenLabel(BuildContext context, AppLocalizations l10n) {
    final String time = L10nFormatters.timeOfDayLabel(
      context,
      slot.routine.reminderTime,
    );
    final DateTime now = DateTime.now();
    final DateTime fires = slot.firesAt;
    final int daysAway = DateTime(
      fires.year,
      fires.month,
      fires.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    // Under a TODAY heading the word "today" says nothing; what is useful is
    // how soon. Beyond today the weekday carries it.
    if (daysAway == 0) {
      final int minutes = slot.firesAt.difference(now).inMinutes;
      if (minutes >= 0 && minutes <= 60) {
        return '${l10n.inMinutes(minutes)} · $time';
      }
      return time;
    }
    return '${L10nFormatters.repeatDays(l10n, <int>[slot.weekday])} · $time';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.md,
      ),
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
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RoutineCategoryUi.background(slot.routine.category),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              RoutineCategoryUi.icon(
                slot.routine.category,
                iconKey: slot.routine.iconKey,
              ),
              size: 18,
              color: RoutineCategoryUi.foreground(slot.routine.category),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  slot.routine.title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _whenLabel(context, l10n),
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    color: context.palette.textSecondary,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.palette.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.notifications_off_outlined,
            size: 36,
            color: context.palette.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.noUpcomingReminders,
            style: AppTextStyles.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.noUpcomingRemindersDesc,
            style: AppTextStyles.body.copyWith(
              color: context.palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

class _WhitePillAction extends StatelessWidget {
  const _WhitePillAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 17, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
