import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
import 'package:openlife_routine/features/routines/presentation/pages/templates_empty_page.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_bloc.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_event.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_state.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TemplateBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createTemplateBloc()
            ..add(const TemplatesLoaded()),
      child: const _TemplatesView(),
    );
  }
}

class _TemplatesView extends StatelessWidget {
  const _TemplatesView();

  IconData _iconForKey(String iconKey) {
    return switch (iconKey) {
      'wb_sunny' => Icons.wb_sunny_outlined,
      'water_drop' => Icons.water_drop_outlined,
      'medication' => Icons.medication_outlined,
      'bedtime' => Icons.bedtime_outlined,
      'self_improvement' => Icons.self_improvement_outlined,
      _ => Icons.star_outline_rounded,
    };
  }

  Color _iconBgForKey(String iconKey) {
    return switch (iconKey) {
      'wb_sunny' => const Color(0xFFFFF1C8),
      'water_drop' => const Color(0xFFDDEBF5),
      'medication' => const Color(0xFFFFF1C8),
      'bedtime' => const Color(0xFFDDEBF5),
      'self_improvement' => const Color(0xFFF0EAE2),
      _ => AppColors.primarySoft,
    };
  }

  Color _iconColorForKey(String iconKey) {
    return switch (iconKey) {
      'wb_sunny' => AppColors.warning,
      'water_drop' => AppColors.secondary,
      'medication' => AppColors.warning,
      'bedtime' => AppColors.secondary,
      'self_improvement' => AppColors.primary,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BlocBuilder<TemplateBloc, TemplateState>(
      builder: (BuildContext context, TemplateState state) {
        if (state.status == TemplateStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.templates.isEmpty) {
          return const TemplatesEmptyPage();
        }

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  leadingWidth: 68,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.pageMargin),
                    child: Center(
                      child: IconCircleButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  title: Text(
                    'Templates',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  actions: const <Widget>[
                    IconCircleButton(
                      icon: Icons.notifications_none_rounded,
                    ),
                    SizedBox(width: AppSpacing.pageMargin),
                  ],
                  pinned: true,
                  backgroundColor: AppColors.background,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageMargin,
                    AppSpacing.xl,
                    AppSpacing.pageMargin,
                    120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
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
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ...state.templates.map(
                        (RoutineTemplate template) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                          child: _TemplateCard(
                            title: template.title,
                            description: template.description,
                            badge: template.badge,
                            icon: _iconForKey(template.iconKey),
                            iconBackground: _iconBgForKey(template.iconKey),
                            iconColor: _iconColorForKey(template.iconKey),
                            meta: '${template.routineCount} steps',
                            isPrimary: template.isPrimary,
                            onApply: () => _applyTemplate(context, template),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyTemplate(BuildContext context, RoutineTemplate template) {
    final RoutineBloc routineBloc = AppScope.read(context).createRoutineBloc();

    for (final TemplateRoutineItem item in template.routines) {
      final RoutineCategory category = RoutineCategory.values.firstWhere(
        (RoutineCategory c) => c.name == item.category,
        orElse: () => RoutineCategory.custom,
      );

      routineBloc.add(
        RoutineCreateRequested(
          title: item.title,
          category: category,
          reminderTime: item.reminderTime,
          repeatDays: item.repeatDays,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${template.title}" routines added!'),
        behavior: SnackBarBehavior.floating,
      ),
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
    this.onApply,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String meta;
  final String? badge;
  final bool isPrimary;
  final VoidCallback? onApply;

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
            onPressed: onApply,
          ),
        ],
      ),
    );
  }
}
