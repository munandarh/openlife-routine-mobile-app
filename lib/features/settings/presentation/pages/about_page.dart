import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            title: Text('About Open Source'),
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
                        'OpenLife Routine',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Version 1.0.0',
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
                  title: 'Open source',
                  body:
                      'OpenLife Routine is free and open-source software. The full source '
                      'code is available on GitHub under the Apache 2.0 license.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.build_outlined,
                  title: 'Built with Flutter',
                  body:
                      'This app is built with Flutter and Dart, using Clean Architecture, '
                      'BLoC state management, Drift SQLite, local notifications, and Rive animations.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.favorite_outline,
                  title: 'Portfolio project',
                  body:
                      'OpenLife Routine was built as a production-quality open-source '
                      'portfolio project to demonstrate Flutter engineering, architecture, '
                      'and product design skills.',
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  icon: Icons.gavel_outlined,
                  title: 'License',
                  body:
                      'Apache License 2.0 — Free for personal and commercial use. '
                      'The OpenLife Routine name and logo are reserved for the official project.',
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
