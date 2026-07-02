import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            title: Text('Privacy & Data'),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                _InfoCard(
                  icon: Icons.phone_android_outlined,
                  title: 'Your data stays on your device',
                  body:
                      'OpenLife Routine stores all your routines, schedules, and logs locally '
                      'on your phone. No data is sent to any server.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.no_accounts_outlined,
                  title: 'No account required',
                  body:
                      'You can use all features without creating an account. There is no '
                      'login, no registration, and no personal information collected.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.wifi_off_outlined,
                  title: 'Works offline',
                  body:
                      'All core features work without an internet connection. Reminders '
                      'are scheduled locally and trigger even when you are offline.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.file_download_outlined,
                  title: 'You control your data',
                  body:
                      'You can export your data as JSON at any time from Settings. You can '
                      'also import a backup or reset all data from your device.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.security_outlined,
                  title: 'No tracking or analytics',
                  body:
                      'This app does not use third-party analytics, advertising trackers, '
                      'or any form of user monitoring. Your routine is yours alone.',
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'OpenLife Routine is not a medical app.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'It is a lifestyle and routine reminder app designed to help you build '
                  'better days. It does not diagnose, treat, or cure any condition.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            child: Icon(icon, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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
