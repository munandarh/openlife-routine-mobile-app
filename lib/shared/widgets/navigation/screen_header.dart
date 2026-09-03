import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';

/// The header every pushed screen uses: a white circular back button and a
/// left-aligned title.
///
/// It replaced five separate `AppBar`s that each drew the title differently —
/// centred, sage green, or in a different size — which made a pushed screen
/// look like a different app from the tab it was opened from.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({required this.title, this.onBack, super.key});

  final String title;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.md + 2,
        AppSpacing.pageMargin,
        0,
      ),
      child: Row(
        children: <Widget>[
          Material(
            color: context.palette.surface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: context.palette.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 19),
            ),
          ),
        ],
      ),
    );
  }
}
