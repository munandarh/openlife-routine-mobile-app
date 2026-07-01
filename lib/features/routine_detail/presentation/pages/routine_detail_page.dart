import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class RoutineDetailPage extends StatelessWidget {
  const RoutineDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.pageMargin,
            AppSpacing.pageMargin,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Expanded(
                  child: Text(
                    'Routine Detail',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                ),
                const IconCircleButton(icon: Icons.more_horiz_rounded),
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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFFFF1C8),
                    foregroundColor: AppColors.warning,
                    child: const Icon(Icons.medication_outlined),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Vitamin D', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'A calm reminder after breakfast to keep your supplement routine steady.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _DetailCard(
              title: 'Schedule',
              rows: <String>['Every weekday', '08:30 AM'],
            ),
            const SizedBox(height: AppSpacing.cardGap),
            const _DetailCard(
              title: 'Reminder behavior',
              rows: <String>[
                'Snooze for 10 minutes',
                'Local notification only',
              ],
            ),
            const SizedBox(height: AppSpacing.cardGap),
            const _DetailCard(
              title: 'Recent history',
              rows: <String>[
                'Done yesterday at 08:34',
                'Done Monday at 08:31',
                'Missed Sunday',
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const PrimaryButton(label: 'Edit routine'),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.rows});

  final String title;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...rows.map(
            (String row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                row,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
