import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';

class TodayEmptyPage extends StatelessWidget {
  const TodayEmptyPage({this.onCreateRoutine, super.key});

  final VoidCallback? onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: AppEmptyState(
              title: 'Nothing scheduled today',
              description:
                  'Add a routine to see your day fill up with calm reminders.',
              buttonLabel: 'Create routine',
              icon: Icons.event_note_outlined,
              onPressed:
                  onCreateRoutine ??
                  () => context.push(OpenLifeRoute.newRoutine.path),
            ),
          ),
        ),
      ),
    );
  }
}
