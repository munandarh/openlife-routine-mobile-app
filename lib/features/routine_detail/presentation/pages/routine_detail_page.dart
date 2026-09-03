import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/app/router/navigation_extensions.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/localization/l10n_formatters.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
import 'package:openlife_routine/features/routines/presentation/utils/routine_category_ui.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class RoutineDetailPage extends StatelessWidget {
  const RoutineDetailPage({required this.routineId, super.key});

  final String routineId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoutineBloc>(
      create: (BuildContext context) =>
          AppScope.read(context).createRoutineBloc()
            ..add(RoutineDetailRequested(routineId)),
      child: _RoutineDetailView(routineId: routineId),
    );
  }
}

class _RoutineDetailView extends StatefulWidget {
  const _RoutineDetailView({required this.routineId});

  final String routineId;

  @override
  State<_RoutineDetailView> createState() => _RoutineDetailViewState();
}

class _RoutineDetailViewState extends State<_RoutineDetailView> {
  String get routineId => widget.routineId;

  // Editing happens on a pushed route, so this page is still alive and holding
  // the snapshot it loaded on entry. Without this reload it kept showing the
  // old time after a save, which reads as "the edit did not stick" even though
  // the alarms had already been rescheduled.
  void _reload() {
    if (!mounted) {
      return;
    }
    context.read<RoutineBloc>().add(RoutineDetailRequested(routineId));
  }

  Future<void> _openEditor() async {
    await context.push(
      Uri(
        path: OpenLifeRoute.newRoutine.path,
        queryParameters: <String, String>{'id': routineId},
      ).toString(),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutineBloc, RoutineState>(
      listener: (BuildContext context, RoutineState state) {
        if (state.deleted) {
          context.popOrGo(OpenLifeRoute.today.path);
        }
      },
      builder: (BuildContext context, RoutineState state) {
        final TextTheme textTheme = Theme.of(context).textTheme;
        final AppLocalizations l10n = context.l10n;
        final Routine? routine = state.selectedRoutine;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.pageMargin,
                AppSpacing.pageMargin,
                AppSpacing.xxxl,
              ),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _CircleBack(
                      onPressed: () =>
                          context.popOrGo(OpenLifeRoute.today.path),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        l10n.routineDetailTitle,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (routine == null &&
                    state.status == RoutineStatus.loading) ...<Widget>[
                  const Center(child: CircularProgressIndicator()),
                ] else if (routine == null) ...<Widget>[
                  Text(
                    state.errorMessage ?? l10n.routineNotFound,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ] else ...<Widget>[
                  _SurfaceCard(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: RoutineCategoryUi.background(
                              routine.category,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadius.extraLarge,
                            ),
                          ),
                          child: Icon(
                            RoutineCategoryUi.icon(
                              routine.category,
                              iconKey: routine.iconKey,
                            ),
                            size: 27,
                            color: RoutineCategoryUi.foreground(
                              routine.category,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md + 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                routine.title,
                                style: AppTextStyles.pageTitle.copyWith(
                                  fontSize: 21,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                RoutineCategoryUi.routineLabel(
                                  l10n,
                                  routine.category,
                                ),
                                style: AppTextStyles.bodyEmphasis.copyWith(
                                  color: context.palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                l10n.scheduleLabel,
                                style: AppTextStyles.cardTitle,
                              ),
                            ),
                            Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: context.palette.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs + 3),
                            Text(
                              L10nFormatters.timeOfDayLabel(
                                context,
                                routine.reminderTime,
                              ),
                              style: AppTextStyles.cardTitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md + 1),
                        _RepeatDayChips(selected: routine.repeatDays),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.reminderBehavior,
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DetailRow(
                          icon: Icons.snooze_outlined,
                          label: l10n.snoozeDuration,
                          value: l10n.minutesShort(routine.snoozeMinutes),
                        ),
                        _DetailRow(
                          icon: Icons.notifications_active_outlined,
                          label: l10n.routineAlerts,
                          isLast: true,
                          toggle: routine.isEnabled,
                          onToggle: (bool value) =>
                              context.read<RoutineBloc>().add(
                                RoutineEnabledToggled(
                                  routineId: routineId,
                                  isEnabled: value,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (routine.notes != null &&
                      routine.notes!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    _SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(l10n.notesLabel, style: AppTextStyles.cardTitle),
                          const SizedBox(height: AppSpacing.xs + 2),
                          Text(
                            routine.notes!.trim(),
                            style: AppTextStyles.body.copyWith(
                              color: context.palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: l10n.editRoutineAction,
                    onPressed: _openEditor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DangerButton(
                    label: l10n.deleteRoutine,
                    onPressed: () {
                      context.read<RoutineBloc>().add(
                        RoutineDeleteRequested(routineId),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The one card shape this screen uses: white, 24px, one soft shadow.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
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
    );
  }
}

/// A settings-style row inside a detail card: tinted icon, label, and either a
/// value or a switch.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.toggle,
    this.onToggle,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool? toggle;
  final ValueChanged<bool>? onToggle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.palette.background),
              ),
            ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: 15,
                color: context.palette.textPrimary,
              ),
            ),
          ),
          if (toggle != null)
            Switch.adaptive(
              value: toggle!,
              onChanged: onToggle,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
            )
          else if (value != null)
            Text(
              value!,
              style: AppTextStyles.bodyEmphasis.copyWith(
                fontSize: 13,
                color: context.palette.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerSoft,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.delete_outline_rounded,
                size: 17,
                color: AppColors.danger,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The seven repeat days, the selected ones filled.
///
/// Read-only here — it mirrors the editor's picker so the two screens describe
/// a schedule the same way.
class _RepeatDayChips extends StatelessWidget {
  const _RepeatDayChips({required this.selected});

  final List<int> selected;

  @override
  Widget build(BuildContext context) {
    final List<String> initials = L10nFormatters.weekdayInitials(context.l10n);

    return Row(
      children: <Widget>[
        for (int weekday = 1; weekday <= 7; weekday += 1) ...<Widget>[
          if (weekday > 1) const SizedBox(width: AppSpacing.xs + 1),
          Expanded(
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected.contains(weekday)
                    ? AppColors.primary
                    : context.palette.background,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Text(
                initials[weekday - 1],
                style: AppTextStyles.button.copyWith(
                  fontSize: 13,
                  color: selected.contains(weekday)
                      ? Colors.white
                      : context.palette.textMuted,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
