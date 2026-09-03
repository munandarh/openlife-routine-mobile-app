import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';

/// One shadow per role, so a card cannot pick up a different elevation on a
/// different screen.
///
/// Before this, the same white card was drawn with three different recipes and
/// several screens used a hairline border instead of a shadow entirely.
final class AppShadows {
  const AppShadows._();

  /// Every white card, chip and field.
  static List<BoxShadow> get card => <BoxShadow>[
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.07),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  /// Something that sits above the page: the bottom nav, the profile avatar.
  static List<BoxShadow> get lifted => <BoxShadow>[
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.12),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  /// A surface filled with the primary colour, which needs its own tint of
  /// shadow or it reads as flat against the page.
  static List<BoxShadow> get primary => <BoxShadow>[
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.26),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
