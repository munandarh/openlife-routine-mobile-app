import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

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
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceSoft,
              child: Icon(Icons.insights_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Insights',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const IconCircleButton(icon: Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                value: '72%',
                label: 'Completed this week',
                icon: Icons.adjust_outlined,
                iconColor: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: _MetricCard(
                value: '5 days',
                label: 'Best streak',
                icon: Icons.local_fire_department_outlined,
                iconColor: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          height: 320,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("This Week's Flow", style: textTheme.titleLarge),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('M'),
                  Text('T'),
                  Text('W'),
                  Text('T'),
                  Text('F'),
                  Text('S'),
                  Text('S'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Focus Areas', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          ),
          child: Row(
            children: <Widget>[
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.secondary,
                child: Icon(Icons.water_drop_outlined),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hydration is your most consistent routine.',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "You're doing great, maintaining a steady pace.",
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

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
          Icon(icon, color: iconColor),
          const SizedBox(height: AppSpacing.lg),
          Text(value, style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
