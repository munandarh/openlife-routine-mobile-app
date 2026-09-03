import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

/// The one header in the app, in its two shapes.
///
/// There used to be two widgets and five hand-rolled copies, and they had
/// drifted: tab screens inset their buttons 20px while pushed screens used 24,
/// and five call sites put the header inside a list that already had 24px of
/// padding, so those screens sat 48px in and a row lower than the rest.
///
/// The header owns its own inset for exactly that reason — **give it no
/// padding of your own**. Put it outside a scroll view's padding, not inside.
class OpenLifeAppBar extends StatelessWidget {
  /// Tab screens: profile avatar, an optional add action, and the bell.
  ///
  /// [onAddRoutine] is null where creating a routine is not what the screen is
  /// for (Insights, Settings).
  const OpenLifeAppBar.tab({this.onAddRoutine, super.key})
    : title = null,
      onBack = null;

  /// Pushed screens: a back button and the screen's title.
  const OpenLifeAppBar.page({
    required String this.title,
    this.onBack,
    super.key,
  }) : onAddRoutine = null;

  /// Every button is this tall and wide, so the row's height never depends on
  /// which shape is in use.
  static const double buttonSize = 44;

  /// The single horizontal inset. Both shapes use it; nothing else may.
  static const double horizontalInset = AppSpacing.pageMargin;

  static const double _topInset = AppSpacing.md + 2;

  final VoidCallback? onAddRoutine;
  final String? title;
  final VoidCallback? onBack;

  bool get _isPage => title != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        horizontalInset,
        _topInset,
        horizontalInset,
        0,
      ),
      child: SizedBox(
        height: buttonSize,
        child: _isPage ? _pageRow(context) : _tabRow(context),
      ),
    );
  }

  Widget _pageRow(BuildContext context) {
    return Row(
      children: <Widget>[
        _CircleAction(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onBack ?? () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 19),
          ),
        ),
      ],
    );
  }

  Widget _tabRow(BuildContext context) {
    return Row(
      children: <Widget>[
        _CircleAction(
          icon: Icons.person_outline,
          tooltip: context.l10n.profileTitle,
          onPressed: () => context.push(OpenLifeRoute.profile.path),
        ),
        const Spacer(),
        if (onAddRoutine != null) ...<Widget>[
          // Flexible, not fixed: at 320dp the Indonesian label makes the pill
          // wider than the row, and the two circular buttons must not be the
          // ones that give way.
          Flexible(child: _AddRoutinePill(onPressed: onAddRoutine!)),
          const SizedBox(width: AppSpacing.sm + 2),
        ],
        _CircleAction(
          icon: Icons.notifications_none_rounded,
          tooltip: context.l10n.notificationsTitle,
          onPressed: () => context.push(OpenLifeRoute.notifications.path),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.palette.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: OpenLifeAppBar.buttonSize,
            height: OpenLifeAppBar.buttonSize,
            child: Icon(icon, size: 20, color: context.palette.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _AddRoutinePill extends StatelessWidget {
  const _AddRoutinePill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.lg - 1,
            0,
          ),
          child: SizedBox(
            height: OpenLifeAppBar.buttonSize,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                const SizedBox(width: AppSpacing.xs + 2),
                Flexible(
                  child: Text(
                    context.l10n.routinesTab,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
