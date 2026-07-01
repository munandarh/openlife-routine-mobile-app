import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';
import 'package:openlife_routine/shared/widgets/cards/routine_card.dart';
import 'package:openlife_routine/shared/widgets/forms/week_date_selector.dart';
import 'package:openlife_routine/shared/widgets/progress/progress_ring.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    const List<WeekDateItem> days = <WeekDateItem>[
      WeekDateItem(weekday: 'M', dayNumber: '12'),
      WeekDateItem(weekday: 'T', dayNumber: '13', hasIndicator: true),
      WeekDateItem(weekday: 'W', dayNumber: '14'),
      WeekDateItem(weekday: 'T', dayNumber: '15'),
      WeekDateItem(weekday: 'F', dayNumber: '16'),
      WeekDateItem(weekday: 'S', dayNumber: '17'),
    ];

    return Stack(
      children: <Widget>[
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.pageMargin,
            AppSpacing.pageMargin,
            120,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                const IconCircleButton(icon: Icons.person_outline),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Good Morning, Alex',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const IconCircleButton(icon: Icons.notifications_none_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.primarySoft, Color(0xFFE9F2D7)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.extraLarge),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Daily Progress', style: textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          "You're doing great today.",
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '3 DAY STREAK',
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ProgressRing(progress: 0.6, label: '6/10'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const WeekDateSelector(selectedIndex: 2, items: days),
            const SizedBox(height: AppSpacing.xxxl),
            Text('Daily routine', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            RoutineCard(
              title: 'Breakfast',
              timeLabel: '07:00',
              icon: Icons.restaurant_outlined,
              iconBackground: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE4A323),
              isDone: true,
              onTap: () => context.push(OpenLifeRoute.routineDetail.path),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            RoutineCard(
              title: 'Water',
              timeLabel: '08:00',
              icon: Icons.water_drop_outlined,
              iconBackground: const Color(0xFFDDEBF5),
              iconColor: AppColors.secondary,
              onTap: () => context.push(OpenLifeRoute.routineDetail.path),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            RoutineCard(
              title: 'Vitamin D',
              timeLabel: 'Due Now',
              statusLabel: 'Due Now',
              icon: Icons.medication_outlined,
              iconBackground: const Color(0xFFFFF1C8),
              iconColor: AppColors.warning,
              isDueNow: true,
              onTap: () => context.push(OpenLifeRoute.routineDetail.path),
            ),
          ],
        ),
        Positioned(
          right: AppSpacing.pageMargin,
          bottom: 104,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () => context.push(OpenLifeRoute.newRoutine.path),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
