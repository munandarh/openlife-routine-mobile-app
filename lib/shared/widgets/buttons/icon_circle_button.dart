import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';

class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onPressed,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor ?? context.palette.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: context.palette.border),
        ),
        child: Icon(
          icon,
          color: foregroundColor ?? context.palette.textSecondary,
          size: 22,
        ),
      ),
    );
  }
}
