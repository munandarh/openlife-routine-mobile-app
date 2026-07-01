import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class NewRoutinePage extends StatelessWidget {
  const NewRoutinePage({super.key});

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
                  icon: const Icon(Icons.close_rounded),
                ),
                Expanded(
                  child: Text(
                    'New Routine',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Routine Name', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const TextField(
              decoration: InputDecoration(hintText: 'e.g., Morning Yoga'),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Category', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const _CategoryGrid(),
            const SizedBox(height: AppSpacing.xxl),
            Text('Time', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const TextField(
              decoration: InputDecoration(
                hintText: '08:00 AM',
                suffixIcon: Icon(Icons.schedule_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Repeat', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _RepeatChip(label: 'M', selected: true),
                  _RepeatChip(label: 'T', selected: true),
                  _RepeatChip(label: 'W', selected: true),
                  _RepeatChip(label: 'T'),
                  _RepeatChip(label: 'F'),
                  _RepeatChip(label: 'S'),
                  _RepeatChip(label: 'S'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const PrimaryButton(label: 'Save Routine'),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      physics: const NeverScrollableScrollPhysics(),
      children: const <Widget>[
        _CategoryTile(
          label: 'Meal',
          icon: Icons.restaurant_outlined,
          background: Color(0xFFFFF1C8),
          foreground: AppColors.warning,
        ),
        _CategoryTile(
          label: 'Water',
          icon: Icons.water_drop_outlined,
          background: AppColors.primarySoft,
          foreground: AppColors.primary,
          selected: true,
        ),
        _CategoryTile(
          label: 'Vitamin',
          icon: Icons.medication_outlined,
          background: Color(0xFFFFF1C8),
          foreground: AppColors.warning,
        ),
        _CategoryTile(
          label: 'Medicine',
          icon: Icons.vaccines_outlined,
          background: Color(0xFFFFE0DF),
          foreground: AppColors.danger,
        ),
        _CategoryTile(
          label: 'Sleep',
          icon: Icons.bedtime_outlined,
          background: Color(0xFFDDEBF5),
          foreground: AppColors.secondary,
        ),
        _CategoryTile(
          label: 'Exercise',
          icon: Icons.fitness_center_outlined,
          background: Color(0xFFDDEBF5),
          foreground: AppColors.secondary,
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primarySoft
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: background,
            foregroundColor: foreground,
            child: Icon(icon),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
