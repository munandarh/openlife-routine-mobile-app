import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';

class TodayEmptyPage extends StatelessWidget {
  const TodayEmptyPage({this.onCreateRoutine, super.key});

  final VoidCallback? onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        // Scrollable so the card stays reachable at large OS text scales
        // instead of overflowing a centred, unscrollable column.
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: AppEmptyState(
              title: context.l10n.todayEmptyTitle,
              description: context.l10n.todayEmptyDesc,
              buttonLabel: context.l10n.createRoutine,
              icon: Icons.event_note_outlined,
              illustrationPath: AssetVectors.todayNotificationBell.path,
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
