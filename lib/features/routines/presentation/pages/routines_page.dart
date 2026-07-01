import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({super.key});

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
            Expanded(child: Text('Routines', style: textTheme.headlineMedium)),
            const IconCircleButton(icon: Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Discover Routines',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Add structured, calm habits to your day with a single tap.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Browse Templates',
                icon: Icons.dashboard_customize_outlined,
                onPressed: () => context.push(OpenLifeRoute.templates.path),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Your routines', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        RoutineCard(
          title: 'Morning hydration',
          timeLabel: '08:00',
          icon: Icons.water_drop_outlined,
          iconBackground: const Color(0xFFDDEBF5),
          iconColor: AppColors.secondary,
          onTap: () => context.push(OpenLifeRoute.routineDetail.path),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        RoutineCard(
          title: 'Vitamin D',
          timeLabel: '09:00',
          icon: Icons.medication_outlined,
          iconBackground: const Color(0xFFFFF1C8),
          iconColor: AppColors.warning,
          onTap: () => context.push(OpenLifeRoute.routineDetail.path),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        PrimaryButton(
          label: 'Create routine',
          icon: Icons.add,
          onPressed: () => context.push(OpenLifeRoute.newRoutine.path),
        ),
      ],
    );
  }
}
