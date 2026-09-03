import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';

/// Icon + title + body card shared by the Privacy and About screens.
class SettingsInfoCard extends StatelessWidget {
  const SettingsInfoCard({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
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
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
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
                    color: context.palette.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
