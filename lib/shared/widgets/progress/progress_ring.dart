import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.label,
    this.caption,
    this.size = 108,
    super.key,
  });

  final double progress;
  final String label;

  /// Small word under the count ("done"). Optional so the ring stays usable
  /// anywhere it is just a gauge.
  final String? caption;
  final double size;

  double get _clampedProgress => progress.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: _clampedProgress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double animatedProgress, Widget? child) {
        final bool isComplete = _clampedProgress >= 1.0;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // The mockup's dial sits on white, not on the page tint.
              Container(
                width: size - 12,
                height: size - 12,
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: 11,
                  strokeCap: StrokeCap.round,
                  backgroundColor: context.palette.border,
                  color: isComplete ? AppColors.success : AppColors.primary,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isComplete ? 0.8 : 1.0,
                  end: isComplete ? 1.0 : 1.0,
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder:
                    (BuildContext context, double scale, Widget? scaleChild) {
                      return Transform.scale(
                        scale: scale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              label,
                              style: AppTextStyles.pageTitle.copyWith(
                                fontSize: 27,
                                color: isComplete
                                    ? AppColors.success
                                    : context.palette.textPrimary,
                              ),
                            ),
                            if (caption != null)
                              Text(
                                caption!,
                                style: AppTextStyles.label.copyWith(
                                  color: context.palette.textMuted,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
              ),
            ],
          ),
        );
      },
    );
  }
}
