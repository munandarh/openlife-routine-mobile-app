import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

/// Colour treatment for the small status chip on a [RoutineCard].
///
/// A "Missed" chip must not read like a "Done" chip, so the tone is chosen by
/// the caller rather than derived from `isDueNow` alone.
enum RoutineCardTone { positive, attention, muted }

/// One tappable chip in a routine card's action row (Skip, Snooze, Undo…).
class RoutineCardAction {
  const RoutineCardAction({required this.label, this.onPressed, this.key});

  final String label;
  final VoidCallback? onPressed;
  final Key? key;
}

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.statusLabel,
    this.statusTone = RoutineCardTone.positive,
    this.actions = const <RoutineCardAction>[],
    this.onTap,
    this.onCheckTap,
    this.checkSemanticLabel,
    this.isDone = false,
    this.isDueNow = false,
    super.key,
  });

  final String title;
  final String timeLabel;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String? statusLabel;
  final RoutineCardTone statusTone;
  final List<RoutineCardAction> actions;
  final VoidCallback? onTap;
  final VoidCallback? onCheckTap;

  /// Spoken label for the completion circle, which is otherwise icon-only.
  final String? checkSemanticLabel;
  final bool isDone;
  final bool isDueNow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isDueNow ? AppColors.warning : context.palette.border,
            width: isDueNow ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Hug the content: the card sizes to its text, it does not
                // stretch to whatever height the row is offered.
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _AnimatedStrikethroughText(
                    text: title,
                    isStruckThrough: isDone,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      _Chip(
                        label: timeLabel,
                        background: context.palette.surfaceSoft,
                        foreground: context.palette.textSecondary,
                      ),
                      if (statusLabel != null)
                        _Chip(
                          label: statusLabel!,
                          background: _statusBackground(context),
                          foreground: _statusForeground(context),
                        ),
                      for (final RoutineCardAction action in actions)
                        _ActionChip(key: action.key, action: action),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _CheckCircle(
              isDone: isDone,
              onTap: onCheckTap,
              semanticLabel: checkSemanticLabel,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBackground(BuildContext context) {
    return switch (statusTone) {
      RoutineCardTone.positive => AppColors.primarySoft,
      RoutineCardTone.attention => AppColors.accentSoft,
      RoutineCardTone.muted => context.palette.surfaceSoft,
    };
  }

  Color _statusForeground(BuildContext context) {
    return switch (statusTone) {
      RoutineCardTone.positive => AppColors.primary,
      RoutineCardTone.attention => AppColors.warning,
      RoutineCardTone.muted => context.palette.textSecondary,
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: foreground),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action, super.key});

  final RoutineCardAction action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // Its own node, so a screen reader can reach "Skip" and "Snooze"
      // separately instead of hearing them merged into the card's label.
      container: true,
      label: action.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.small),
        onTap: action.onPressed,
        child: Container(
          // Floor the tap target at 44px without an `alignment`: a Container
          // with an alignment expands to the loose width the Wrap offers,
          // which pushed every action chip onto its own full-width row.
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            action.label,
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.isDone, this.onTap, this.semanticLabel});

  final bool isDone;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      container: true,
      checked: isDone,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFE0F5E4) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isDone ? Colors.transparent : context.palette.border,
              width: 2,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isDone ? Icons.check_rounded : Icons.circle_outlined,
              key: ValueKey<bool>(isDone),
              color: isDone ? AppColors.success : context.palette.border,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedStrikethroughText extends StatelessWidget {
  const _AnimatedStrikethroughText({
    required this.text,
    required this.isStruckThrough,
  });

  final String text;
  final bool isStruckThrough;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: isStruckThrough ? 1.0 : 0.0,
        end: isStruckThrough ? 1.0 : 0.0,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Text(
          text,
          style: AppTextStyles.cardTitle.copyWith(
            decoration: value > 0.5 ? TextDecoration.lineThrough : null,
            color: Color.lerp(
              context.palette.textPrimary,
              context.palette.textSecondary,
              value,
            ),
          ),
        );
      },
    );
  }
}
