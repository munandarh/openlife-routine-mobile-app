import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(l10n.aboutTitle),
            pinned: true,
          ),
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
                        l10n.aboutVersion,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _InfoCard(
                  icon: Icons.code_outlined,
                  title: l10n.aboutOpenSource,
                  body: l10n.aboutOpenSourceBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.build_outlined,
                  title: l10n.aboutBuiltWith,
                  body: l10n.aboutBuiltWithBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.favorite_outline,
                  title: l10n.aboutPortfolio,
                  body: l10n.aboutPortfolioBody,
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
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
