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
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
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
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        leading: IconButton(
          onPressed: () => context.popOrGo(OpenLifeRoute.today.path),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: FutureBuilder<List<Routine>>(
        future: _routines,
        builder: (BuildContext context, AsyncSnapshot<List<Routine>> snapshot) {
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
              AppSpacing.pageMargin,
              AppSpacing.pageMargin,
              AppSpacing.xxxl,
            ),
            children: <Widget>[
              Text(l10n.upcomingReminders, style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.upcomingRemindersDesc,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (upcoming.isEmpty)
                _EmptyState(l10n: l10n)
              else
                ...upcoming.map(
                  (RoutineReminderSlot slot) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ReminderTile(slot: slot),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () => context.go(OpenLifeRoute.settings.path),
                icon: const Icon(Icons.tune_rounded),
                label: Text(l10n.manageAlerts),
              ),
            ],
          );
        },
      ),
    );
  }
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

    return switch (daysAway) {
      0 => l10n.reminderTodayAt(time),
      1 => l10n.reminderTomorrowAt(time),
      _ => '${L10nFormatters.repeatDays(l10n, <int>[slot.weekday])}, $time',
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
            backgroundColor: RoutineCategoryUi.background(
              slot.routine.category,
            ),
            foregroundColor: RoutineCategoryUi.foreground(
              slot.routine.category,
            ),
            child: Icon(
              RoutineCategoryUi.icon(
                slot.routine.category,
                iconKey: slot.routine.iconKey,
              ),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  slot.routine.title,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _whenLabel(context, l10n),
                  style: textTheme.bodyMedium?.copyWith(
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
    final TextTheme textTheme = Theme.of(context).textTheme;

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
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.noUpcomingRemindersDesc,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
