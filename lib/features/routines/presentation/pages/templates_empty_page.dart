import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';

class TemplatesEmptyPage extends StatelessWidget {
  const TemplatesEmptyPage({this.onBrowseRoutines, super.key});

  final VoidCallback? onBrowseRoutines;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: AppEmptyState(
              title: 'No templates yet',
              description:
                  'Templates are ready to help once you start building a routine library.',
              buttonLabel: 'Browse routines',
              icon: Icons.dashboard_customize_outlined,
              onPressed:
                  onBrowseRoutines ??
                  () => context.go(OpenLifeRoute.routines.path),
            ),
          ),
        ),
      ),
    );
  }
}
