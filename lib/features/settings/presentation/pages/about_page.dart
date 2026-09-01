import 'package:flutter/material.dart';
import 'package:openlife_routine/core/app_info.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/settings/presentation/widgets/settings_info_card.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(title: Text(l10n.aboutTitle), pinned: true),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primary,
                        child: Icon(Icons.spa_outlined, size: 36),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.appTitle,
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.aboutVersion(AppInfo.version),
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SettingsInfoCard(
                  icon: Icons.code_outlined,
                  title: l10n.aboutOpenSource,
                  body: l10n.aboutOpenSourceBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsInfoCard(
                  icon: Icons.build_outlined,
                  title: l10n.aboutBuiltWith,
                  body: l10n.aboutBuiltWithBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsInfoCard(
                  icon: Icons.favorite_outline,
                  title: l10n.aboutPortfolio,
                  body: l10n.aboutPortfolioBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsInfoCard(
                  icon: Icons.gavel_outlined,
                  title: l10n.aboutLicense,
                  body: l10n.aboutLicenseBody,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
