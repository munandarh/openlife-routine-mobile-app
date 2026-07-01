import 'package:flutter/material.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_bottom_nav.dart';

class OpenLifeShell extends StatelessWidget {
  const OpenLifeShell({
    required this.currentRoute,
    required this.child,
    super.key,
  });

  final OpenLifeRoute currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          0,
          AppSpacing.pageMargin,
          AppSpacing.pageMargin,
        ),
        child: OpenLifeBottomNav(currentRoute: currentRoute),
      ),
    );
  }
}
