import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/empty_states/app_empty_state.dart';

class TemplatesEmptyPage extends StatelessWidget {
  const TemplatesEmptyPage({this.onBrowseRoutines, super.key});

  final VoidCallback? onBrowseRoutines;

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
              title: context.l10n.templatesEmptyTitle,
              description: context.l10n.templatesEmptyDesc,
              buttonLabel: context.l10n.browseRoutines,
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
