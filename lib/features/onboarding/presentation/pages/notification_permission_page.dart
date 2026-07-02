import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({
    this.onAllowNotifications,
    this.onSkip,
    super.key,
  });

  final Future<void> Function(BuildContext context)? onAllowNotifications;
  final VoidCallback? onSkip;

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  bool _isLoading = false;

  Future<void> _allowNotifications() async {
    setState(() => _isLoading = true);
    try {
      if (widget.onAllowNotifications != null) {
        await widget.onAllowNotifications!(context);
      } else {
        await AppScope.read(context).notificationService.requestPermissions();
        if (!mounted) {
          return;
        }
        context.go(OpenLifeRoute.onboarding.path);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
      return;
    }
    context.go(OpenLifeRoute.onboarding.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: <Widget>[
            Row(
              children: <Widget>[
                _BrandPill(
                  icon: Icons.notifications_active_outlined,
                  label: 'Notification permission',
                ),
                const Spacer(),
                TextButton(onPressed: _skip, child: const Text('Skip')),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(
                          AppRadius.extraLarge,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        size: 64,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Get gentle reminders',
                      style: AppTextStyles.pageTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'OpenLife can remind you about routines at the right time, without noisy pressure.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _FeatureChip(
                      icon: Icons.schedule_outlined,
                      label: 'Scheduled reminders',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _FeatureChip(
                      icon: Icons.do_not_disturb_on_outlined,
                      label: 'Quiet and respectful',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _FeatureChip(
                      icon: Icons.lock_outline_rounded,
                      label: 'Private on device',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Allow notifications',
              icon: Icons.notifications_active_outlined,
              isLoading: _isLoading,
              onPressed: () => _allowNotifications(),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Not now',
              isSecondary: true,
              onPressed: _skip,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodyEmphasis.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
