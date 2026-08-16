import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';

class RoutinesEmptyPage extends StatelessWidget {
  const RoutinesEmptyPage({this.onCreateRoutine, super.key});

  final VoidCallback? onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: AppEmptyState(
              title: l10n.noRoutinesYet,
              description:
                  'Create your first routine so the app can start guiding your day.',
              buttonLabel: l10n.createRoutine,
              icon: Icons.calendar_today_outlined,
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
