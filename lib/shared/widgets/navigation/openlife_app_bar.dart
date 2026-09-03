import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

/// The tab-screen header: profile avatar, an optional add action, and the bell.
///
/// One widget rather than a copy per screen — five hand-rolled headers is how
/// the icons ended up with no `onPressed` at all for as long as they did.
///
/// [onAddRoutine] is null on screens where creating a routine is not what the
/// screen is for (Insights, Settings), which is the whole reason this is a
/// parameter and not a constant.
class OpenLifeAppBar extends StatelessWidget {
  const OpenLifeAppBar({this.onAddRoutine, super.key});

  static const double _buttonSize = 44;

  final VoidCallback? onAddRoutine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin - 4,
        AppSpacing.md + 2,
        AppSpacing.pageMargin - 4,
        0,
      ),
      child: Row(
        children: <Widget>[
          _CircleAction(
            icon: Icons.person_outline,
            tooltip: context.l10n.profileTitle,
            onPressed: () => context.push(OpenLifeRoute.profile.path),
          ),
          const Spacer(),
          if (onAddRoutine != null) ...<Widget>[
            _AddRoutinePill(onPressed: onAddRoutine!),
            const SizedBox(width: AppSpacing.sm + 2),
          ],
          _CircleAction(
            icon: Icons.notifications_none_rounded,
            tooltip: context.l10n.notificationsTitle,
            onPressed: () => context.push(OpenLifeRoute.notifications.path),
          ),
        ],
      ),
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
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: OpenLifeAppBar._buttonSize,
            height: OpenLifeAppBar._buttonSize,
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
            height: OpenLifeAppBar._buttonSize,
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
