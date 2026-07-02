import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;
  final bool isLoading;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.isSecondary
                ? AppColors.primarySoft
                : AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isLoading
                      ? SizedBox(
                          key: const ValueKey<String>('loading'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: widget.isSecondary
                                ? AppColors.primary
                                : Colors.white,
                          ),
                        )
                      : Row(
                          key: const ValueKey<String>('label'),
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (widget.icon != null) ...<Widget>[
                              Icon(
                                widget.icon,
                                size: 20,
                                color: widget.isSecondary
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              widget.label,
                              style: AppTextStyles.button.copyWith(
                                color: widget.isSecondary
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
