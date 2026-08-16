import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';

class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// What a screen reader announces, and the tooltip text. Required in
  /// practice for anything tappable: an icon on its own says nothing.
  ///
  /// Leave it null only for decorative chrome, which is then hidden from
  /// the semantics tree rather than announced as an unusable control.
  final String? semanticLabel;

  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final Widget button = InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onPressed,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: foregroundColor ?? AppColors.textSecondary,
          size: 22,
        ),
      ),
    );

    if (semanticLabel == null) {
      // Decorative: an unlabelled icon announced as a control is noise.
      return ExcludeSemantics(child: button);
    }

    return Semantics(
      button: onPressed != null,
      label: semanticLabel,
      child: Tooltip(message: semanticLabel!, child: button),
    );
  }
}
