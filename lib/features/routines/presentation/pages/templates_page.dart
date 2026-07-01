import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.pageMargin,
        AppSpacing.pageMargin,
        120,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            const IconCircleButton(icon: Icons.person_outline),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text('Templates', style: textTheme.headlineMedium)),
            const IconCircleButton(icon: Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Discover Routines',
          style: textTheme.displayLarge?.copyWith(
            color: AppColors.primary,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add structured, calm habits to your day with a single tap.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        const _TemplateCard(
          title: 'Morning Routine',
          description: 'Start your day with intention and a gentle pace.',
          badge: 'POPULAR',
          icon: Icons.wb_sunny_outlined,
          iconBackground: Color(0xFFFFF1C8),
          iconColor: AppColors.warning,
          meta: '3 steps',
          isPrimary: true,
        ),
        const SizedBox(height: AppSpacing.cardGap),
        const _TemplateCard(
          title: 'Hydration Tracker',
          description: 'Keep your water intake consistent throughout the day.',
          icon: Icons.water_drop_outlined,
          iconBackground: Color(0xFFDDEBF5),
          iconColor: AppColors.secondary,
          meta: '8 glasses total',
        ),
        const SizedBox(height: AppSpacing.cardGap),
        const _TemplateCard(
          title: 'Vitamin Routine',
          description: 'Never miss a supplement with timed daily reminders.',
          icon: Icons.medication_outlined,
          iconBackground: Color(0xFFFFF1C8),
          iconColor: AppColors.warning,
          meta: '2 steps',
        ),
        const SizedBox(height: AppSpacing.cardGap),
        const _TemplateCard(
          title: 'Programmer Break',
          description: 'Eye rest and posture resets to combat screen fatigue.',
          badge: 'NEW',
          icon: Icons.self_improvement_outlined,
          iconBackground: Color(0xFFF0EAE2),
          iconColor: AppColors.primary,
          meta: 'Every 45 mins',
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.meta,
    this.badge,
    this.isPrimary = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String meta;
  final String? badge;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: iconBackground,
                foregroundColor: iconColor,
                child: Icon(icon),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    badge!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(meta, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Add Template',
            isSecondary: !isPrimary,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }
}
