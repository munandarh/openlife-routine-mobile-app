import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// The floating pill nav from the Sage & Clay mockups.
///
/// Only the selected tab carries a label; the rest are icon-only. That is what
/// lets four tabs sit in one 70px pill without crowding — but it also means
/// every unselected item must still offer a full 44px target, which the
/// icon glyph alone does not, hence the explicit [_navTargetHeight] box.
class OpenLifeBottomNav extends StatelessWidget {
  const OpenLifeBottomNav({required this.currentRoute, super.key});

  static const double _navHeight = 70;
  static const double _navTargetHeight = 44;

  final OpenLifeRoute currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _navHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.lifted,
      ),
      child: Row(
        children: OpenLifeRoute.bottomNavRoutes.map((OpenLifeRoute route) {
          final bool isSelected =
              route == currentRoute ||
              (route == OpenLifeRoute.routines &&
                  currentRoute.isNestedUnderRoutines);

          return Expanded(
            // The labelled tab needs far more than an equal quarter: at 320dp
            // an equal share is ~66px against a pill that wants ~100 for
            // "Hari ini". The pill is min-width anyway, so a generous share
            // costs the icon-only tabs nothing on a wider screen.
            flex: isSelected ? 7 : 3,
            child: Semantics(
              selected: isSelected,
              button: true,
              label: _label(context.l10n, route),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () => context.go(route.path),
                child: Center(
                  child: isSelected
                      ? _SelectedTab(route: route)
                      : SizedBox(
                          height: _navTargetHeight,
                          child: Center(
                            child: Icon(
                              route.icon,
                              size: 21,
                              color: context.palette.iconMuted,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SelectedTab extends StatelessWidget {
  const _SelectedTab({required this.route});

  final OpenLifeRoute route;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: context.palette.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(route.icon, size: 19, color: context.palette.primaryInk),
          const SizedBox(width: AppSpacing.sm - 1),
          Flexible(
            child: Text(
              _label(context.l10n, route),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.button.copyWith(
                fontSize: 13,
                color: context.palette.primaryInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom-nav labels come from the active locale, not the route enum's
/// English `label`, which stays for debugging and route naming.
String _label(AppLocalizations l10n, OpenLifeRoute route) {
  return switch (route) {
    OpenLifeRoute.today => l10n.todayTab,
    OpenLifeRoute.routines => l10n.routinesTab,
    OpenLifeRoute.insights => l10n.insightsTab,
    OpenLifeRoute.settings => l10n.settingsTab,
    _ => route.label,
  };
}
