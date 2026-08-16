import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(l10n.privacyTitle),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                _InfoCard(
                  icon: Icons.phone_android_outlined,
                  title: l10n.privacyLocal,
                  body: l10n.privacyLocalBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.no_accounts_outlined,
                  title: l10n.privacyNoAccount,
                  body: l10n.privacyNoAccountBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.wifi_off_outlined,
                  title: l10n.privacyOffline,
                  body: l10n.privacyOfflineBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.file_download_outlined,
                  title: l10n.privacyControl,
                  body: l10n.privacyControlBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.security_outlined,
                  title: l10n.privacyNoTracking,
                  body: l10n.privacyNoTrackingBody,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.privacyDisclaimer,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.privacyDisclaimerBody,
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
