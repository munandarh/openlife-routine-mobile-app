import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/settings/presentation/widgets/settings_info_card.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(title: Text(l10n.privacyTitle), pinned: true),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                SettingsInfoCard(
                  icon: Icons.phone_android_outlined,
                  title: l10n.privacyLocal,
                  body: l10n.privacyLocalBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsInfoCard(
                  icon: Icons.no_accounts_outlined,
                  title: l10n.privacyNoAccount,
                  body: l10n.privacyNoAccountBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsInfoCard(
                  icon: Icons.wifi_off_outlined,
                  title: l10n.privacyOffline,
                  body: l10n.privacyOfflineBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsInfoCard(
                  icon: Icons.file_download_outlined,
                  title: l10n.privacyControl,
                  body: l10n.privacyControlBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsInfoCard(
                  icon: Icons.security_outlined,
                  title: l10n.privacyNoTracking,
                  body: l10n.privacyNoTrackingBody,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.privacyDisclaimer,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.privacyDisclaimerBody,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
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
