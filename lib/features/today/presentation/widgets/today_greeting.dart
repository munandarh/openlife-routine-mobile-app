import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/today/presentation/widgets/greeting_helper.dart';

/// A small, opinionated greeting header used at the top of the Today
/// screen. Displays a time-of-day greeting ("Good morning", "Selamat
/// siang", etc.) and an optional supportive subtitle.
class TodayGreeting extends StatelessWidget {
  const TodayGreeting({this.hour, this.subtitle, super.key});

  /// Hour of the day (0-23). When null, the widget derives the hour
  /// from `DateTime.now()`.
  final int? hour;

  /// Optional subtitle text shown below the greeting.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final int effectiveHour = hour ?? DateTime.now().hour;
    final String greeting = greetingForContext(context, effectiveHour);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            greeting,
            style: AppTextStyles.sectionTitle.copyWith(
              color: context.palette.textPrimary,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.body.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
