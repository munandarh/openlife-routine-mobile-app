import 'package:flutter/material.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/notifications/reminder_health.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';

/// Answers the one question this app lives or dies by: will the reminder
/// actually arrive?
///
/// Every condition here fails silently on a real phone. A suspended app shows
/// no error, a batched alarm looks like the app forgot, and a revoked
/// permission looks like nothing at all — so people conclude the app is broken
/// rather than that a setting needs changing.
class ReminderHealthPage extends StatefulWidget {
  const ReminderHealthPage({super.key});

  @override
  State<ReminderHealthPage> createState() => _ReminderHealthPageState();
}

class _ReminderHealthPageState extends State<ReminderHealthPage>
    with WidgetsBindingObserver {
  ReminderHealthReport? _report;
  late final ReminderHealth _health;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _health = ReminderHealth(
      notificationService: AppScope.read(context).notificationService,
    );
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Every fix here happens in the OS settings app, so the answer is stale
    // the moment the user leaves — re-checking on return is what makes the
    // green tick trustworthy.
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final ReminderHealthReport report = await _health.check();
    if (mounted) {
      setState(() => _report = report);
    }
  }

  Future<void> _sendTestReminder() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String sent = context.l10n.testReminderSent;

    await AppScope.read(context).notificationService.showTestReminder();

    if (!mounted) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(sent)));
  }

  Future<void> _fix(ReminderCheck check) async {
    switch (check) {
      case ReminderCheck.notifications:
      case ReminderCheck.exactAlarms:
        final bool? granted = await _health.requestPermissions();
        // Android shows the notification prompt at most twice; after that the
        // request returns false with nothing on screen. Without this the
        // button would look broken and the user would have no way to turn
        // reminders back on.
        if (granted == false) {
          await _health.openAppSettings();
        }
      case ReminderCheck.batteryOptimisation:
        await _health.openBatterySettings();
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ReminderHealthReport? report = _report;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            OpenLifeAppBar.page(title: l10n.reminderHealthTitle),
            Expanded(
              child: report == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageMargin,
                        AppSpacing.lg,
                        AppSpacing.pageMargin,
                        AppSpacing.xxxl,
                      ),
                      children: <Widget>[
                        _Summary(report: report),
                        const SizedBox(height: AppSpacing.lg),
                        for (final ReminderCheck check in ReminderCheck.values)
                          if (report[check] != null) ...<Widget>[
                            _CheckCard(
                              check: check,
                              isOk: report[check]!,
                              onFix: () => _fix(check),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        if (report.needsVendorGuidance) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs),
                          _VendorCard(
                            brand: report.manufacturer,
                            onOpenAutostart: _health.openAutostartSettings,
                            onOpenSettings: _health.openAppSettings,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        // Every check above can pass while nothing arrives:
                        // a vendor suspends the app, a channel is muted, a
                        // Do-Not-Disturb rule swallows the post. This is the
                        // one answer that does not depend on the OS telling
                        // the truth about itself.
                        PrimaryButton(
                          label: l10n.sendTestReminder,
                          isSecondary: true,
                          icon: Icons.notifications_active_outlined,
                          onPressed: _sendTestReminder,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.report});

  final ReminderHealthReport report;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool healthy = report.isHealthy;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: healthy ? AppColors.primary : context.palette.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: healthy ? AppShadows.primary : AppShadows.card,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            healthy
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            size: 26,
            color: healthy ? Colors.white : context.palette.dangerInk,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              healthy
                  ? l10n.reminderHealthAllGood
                  : l10n.reminderHealthProblems(report.failing.length),
              style: AppTextStyles.cardTitle.copyWith(
                color: healthy ? Colors.white : context.palette.dangerInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.check,
    required this.isOk,
    required this.onFix,
  });

  final ReminderCheck check;
  final bool isOk;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final (String title, String ok, String bad) = switch (check) {
      ReminderCheck.notifications => (
        l10n.checkNotifications,
        l10n.checkNotificationsOk,
        l10n.checkNotificationsBad,
      ),
      ReminderCheck.exactAlarms => (
        l10n.checkExactAlarms,
        l10n.checkExactAlarmsOk,
        l10n.checkExactAlarmsBad,
      ),
      ReminderCheck.batteryOptimisation => (
        l10n.checkBattery,
        l10n.checkBatteryOk,
        l10n.checkBatteryBad,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOk
                      ? context.palette.primarySoft
                      : context.palette.dangerSoft,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(
                  isOk ? Icons.check_rounded : Icons.priority_high_rounded,
                  size: 17,
                  color: isOk
                      ? context.palette.primaryInk
                      : context.palette.dangerInk,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: AppTextStyles.cardTitle)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isOk ? ok : bad,
            style: AppTextStyles.body.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
          if (!isOk) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: onFix,
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      l10n.fixIt,
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown only on the vendors that keep an autostart permission no API can
/// read, so the app cannot tick it off — it can only tell the user it exists.
class _VendorCard extends StatelessWidget {
  const _VendorCard({
    required this.brand,
    required this.onOpenAutostart,
    required this.onOpenSettings,
  });

  final String brand;

  /// Opens the vendor's own autostart list. Worth a button of its own because
  /// that toggle does not exist anywhere in the app's normal settings page,
  /// which is where the only button here used to lead.
  final Future<void> Function() onOpenAutostart;

  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String display = brand.isEmpty
        ? brand
        : brand[0].toUpperCase() + brand.substring(1);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.palette.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.vendorWarningTitle(display),
            style: AppTextStyles.cardTitle.copyWith(
              color: context.palette.accentInk,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            l10n.vendorWarningBody,
            style: AppTextStyles.body.copyWith(
              color: context.palette.accentInk,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final String step in <String>[
            l10n.vendorStepAutostart,
            l10n.vendorStepBattery,
            l10n.vendorStepLock,
          ]) ...<Widget>[
            _VendorStep(text: step),
            const SizedBox(height: AppSpacing.xs + 2),
          ],
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: AppColors.accentDeep,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onOpenAutostart,
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    l10n.openAutostartSettings,
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onOpenSettings,
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    l10n.openAppSettings,
                    style: AppTextStyles.button.copyWith(
                      color: context.palette.accentInk,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One instruction inside the vendor card.
class _VendorStep extends StatelessWidget {
  const _VendorStep({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 15,
            color: context.palette.accentInk,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: context.palette.accentInk,
            ),
          ),
        ),
      ],
    );
  }
}
