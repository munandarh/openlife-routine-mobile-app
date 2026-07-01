import 'package:flutter/material.dart';

import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';

class AppPlaceholderPage extends StatelessWidget {
  const AppPlaceholderPage({
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final String ctaLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primarySoft,
                    foregroundColor: AppColors.primary,
                    child: Icon(icon),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Sprint 0 app shell', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This placeholder keeps the foundation honest while Sprint 1 builds the real design system and screen composition.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(onPressed: () {}, child: Text(ctaLabel)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
