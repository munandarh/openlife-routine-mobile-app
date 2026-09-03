import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:openlife_routine/features/routines/presentation/utils/routine_icons.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class NewRoutinePage extends StatelessWidget {
  const NewRoutinePage({this.routineId, super.key});

  final String? routineId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoutineBloc>(
      create: (BuildContext context) {
        final RoutineBloc bloc = AppScope.read(context).createRoutineBloc();
        if (routineId != null && routineId!.isNotEmpty) {
          bloc.add(RoutineDetailRequested(routineId!));
        }
        return bloc;
      },
      child: _NewRoutineView(routineId: routineId),
    );
  }
}

class _NewRoutineView extends StatefulWidget {
  const _NewRoutineView({required this.routineId});

  final String? routineId;

  @override
  State<_NewRoutineView> createState() => _NewRoutineViewState();
}

class _NewRoutineViewState extends State<_NewRoutineView> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  RoutineCategory _selectedCategory = RoutineCategory.water;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  Set<int> _repeatDays = <int>{1, 2, 3};
  bool _seededFromExisting = false;
  int _snoozeMinutes = 10;

  /// Snooze used to be a slider; a slider cannot share a row with the time
  /// field and was fiddly for values that are only ever multiples of five.
  Future<void> _pickSnooze() async {
    final AppLocalizations l10n = context.l10n;
    final int? picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.snoozeDuration,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              for (final int minutes in <int>[5, 10, 15, 20, 30, 45, 60])
                ListTile(
                  title: Text(l10n.minutesLabel(minutes)),
                  trailing: minutes == _snoozeMinutes
                      ? Icon(
                          Icons.check_rounded,
                          color: context.palette.primaryInk,
                        )
                      : null,
                  onTap: () => Navigator.pop(sheetContext, minutes),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _snoozeMinutes = picked);
    }
  }

  bool _isEnabled = true;

  /// Null means "use the category default icon".
  String? _iconKey;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing =
        widget.routineId != null && widget.routineId!.isNotEmpty;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;

    return BlocConsumer<RoutineBloc, RoutineState>(
      listener: (BuildContext context, RoutineState state) {
        if (!_seededFromExisting &&
            state.selectedRoutine != null &&
            isEditing) {
          final Routine routine = state.selectedRoutine!;
          _nameController.text = routine.title;
          _notesController.text = routine.notes ?? '';
          _selectedCategory = routine.category;
          _selectedTime = L10nFormatters.parseTime(routine.reminderTime);
          _repeatDays = routine.repeatDays.toSet();
          _snoozeMinutes = routine.snoozeMinutes;
          _iconKey = routine.iconKey;
          _isEnabled = routine.isEnabled;
          _seededFromExisting = true;
          setState(() {});
        }

        if (state.saved) {
          context.popOrGo(OpenLifeRoute.today.path);
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (BuildContext context, RoutineState state) {
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
                    _CircleClose(
                      tooltip: l10n.closeAction,
                      onPressed: () =>
                          context.popOrGo(OpenLifeRoute.today.path),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        isEditing ? l10n.editRoutine : l10n.newRoutine,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _FieldLabel(l10n.routineName),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(hintText: l10n.routineNameHint),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FieldLabel(l10n.categoryLabel),
                _CategoryGrid(
                  selectedCategory: _selectedCategory,
                  onSelected: (RoutineCategory category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _FieldLabel(l10n.iconLabel),
                _IconPicker(
                  category: _selectedCategory,
                  selectedIconKey: _iconKey,
                  onSelected: (String? iconKey) {
                    setState(() {
                      _iconKey = iconKey;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _FieldLabel(l10n.timeLabel),
                          _ValueField(
                            value: L10nFormatters.timeLabel(
                              context,
                              _selectedTime,
                            ),
                            trailing: Icons.schedule_outlined,
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (picked != null) {
                                setState(() => _selectedTime = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md - 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _FieldLabel(l10n.snoozeDuration),
                          _ValueField(
                            value: l10n.minutesLabel(_snoozeMinutes),
                            trailing: Icons.chevron_right_rounded,
                            onTap: _pickSnooze,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(child: _FieldLabel(l10n.repeatLabel)),
                    // Seven taps was the cost of the most common routine of
                    // all: one that happens every day.
                    _EveryDayButton(
                      isEveryDay: _repeatDays.length == 7,
                      onTap: () => setState(
                        () => _repeatDays = <int>{1, 2, 3, 4, 5, 6, 7},
                      ),
                    ),
                  ],
                ),
                // No wrapping card: the chips are white, so a white container
                // behind them swallowed every unselected day.
                Padding(
                  padding: EdgeInsets.zero,
                  // Each day flexes to a seventh of the row. Fixed-width
                  // chips overflowed a 360dp screen by 20px, which collapsed
                  // the gaps and clipped Sunday.
                  child: Row(
                    children: List<Widget>.generate(7, (int index) {
                      final int dayValue = index + 1;
                      final List<String> initials =
                          L10nFormatters.weekdayInitials(l10n);
                      final List<String> names =
                          L10nFormatters.weekdayAbbreviations(l10n);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxs,
                          ),
                          child: _RepeatChip(
                            label: initials[index],
                            semanticLabel: names[index],
                            selected: _repeatDays.contains(dayValue),
                            onTap: () {
                              setState(() {
                                if (_repeatDays.contains(dayValue)) {
                                  _repeatDays.remove(dayValue);
                                } else {
                                  _repeatDays.add(dayValue);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.notesOptional, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(hintText: l10n.notesHint),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(height: AppSpacing.xxl),
                // PRD 8.3 lists Active as a routine field, and 13.1 requires
                // enable/disable. Without it the only way to stop a reminder
                // was to delete the routine and lose its history.
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(color: context.palette.border),
                  ),
                  child: SwitchListTile.adaptive(
                    value: _isEnabled,
                    onChanged: (bool value) {
                      setState(() => _isEnabled = value);
                    },
                    secondary: Icon(
                      _isEnabled
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      color: context.palette.primaryInk,
                    ),
                    title: Text(l10n.routineActiveLabel),
                    subtitle: Text(l10n.routineActiveDescription),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                PrimaryButton(
                  label: isEditing ? l10n.saveChanges : l10n.saveRoutine,
                  onPressed: state.status == RoutineStatus.loading
                      ? null
                      : () => _submit(context, isEditing),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context, bool isEditing) {
    final AppLocalizations l10n = context.l10n;
    final RoutineBloc bloc = context.read<RoutineBloc>();

    // Validate before dispatching, so the user gets the message next to the
    // form instead of a generic failure state.
    if (_nameController.text.trim().isEmpty) {
      _showValidationError(context, l10n.routineNameRequired);
      return;
    }
    if (_repeatDays.isEmpty) {
      _showValidationError(context, l10n.repeatDaysRequired);
      return;
    }

    final List<int> repeatDays = _repeatDays.toList()..sort();
    final String? notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (isEditing) {
      bloc.add(
        RoutineUpdateRequested(
          id: widget.routineId!,
          title: _nameController.text,
          category: _selectedCategory,
          reminderTime: L10nFormatters.serializeTime(_selectedTime),
          repeatDays: repeatDays,
          isEnabled: _isEnabled,
          snoozeMinutes: _snoozeMinutes,
          iconKey: _iconKey,
          notes: notes,
        ),
      );
      return;
    }

    bloc.add(
      RoutineCreateRequested(
        title: _nameController.text,
        category: _selectedCategory,
        reminderTime: L10nFormatters.serializeTime(_selectedTime),
        repeatDays: repeatDays,
        isEnabled: _isEnabled,
        snoozeMinutes: _snoozeMinutes,
        iconKey: _iconKey,
        notes: notes,
      ),
    );
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selectedCategory,
    required this.onSelected,
  });

  final RoutineCategory selectedCategory;
  final ValueChanged<RoutineCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    // Kept as a 3x3 grid. The mockup drew a single row, but it drew four
    // categories and the app has eight: a one-row strip needs a sideways
    // scroller inside a vertical form, which fights the form's own gesture.
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.55,
      physics: const NeverScrollableScrollPhysics(),
      children: RoutineCategory.values.map((RoutineCategory category) {
        return _CategoryTile(
          label: RoutineCategoryUi.label(l10n, category),
          icon: RoutineCategoryUi.defaultIcon(category),
          background: RoutineCategoryUi.background(
            category,
            brightness: Theme.of(context).brightness,
          ),
          foreground: RoutineCategoryUi.foreground(
            category,
            brightness: Theme.of(context).brightness,
          ),
          selected: category == selectedCategory,
          onTap: () => onSelected(category),
        );
      }).toList(),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Ink(
          // The tile wears its own category tint, so the picker speaks the
          // same colour language as the routine cards it will produce.
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: selected ? context.palette.primaryInk : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: foreground),
              const SizedBox(height: AppSpacing.xs + 2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11.5,
                    color: foreground,
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

/// Optional icon override (PRD §8.3). The first option resets to the category
/// default, so the field is always clearable.
class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.category,
    required this.selectedIconKey,
    required this.onSelected,
  });

  final RoutineCategory category;
  final String? selectedIconKey;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        _IconOption(
          icon: RoutineCategoryUi.defaultIcon(category),
          semanticLabel: l10n.iconDefaultForCategory,
          selected: selectedIconKey == null,
          onTap: () => onSelected(null),
        ),
        for (final String key in RoutineIcons.keys)
          _IconOption(
            icon: RoutineIcons.byKey[key]!,
            semanticLabel: key,
            selected: selectedIconKey == key,
            onTap: () => onSelected(key),
          ),
      ],
    );
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? context.palette.primarySoft
                : context.palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: selected
                  ? context.palette.primaryInk
                  : context.palette.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: selected
                ? context.palette.primaryInk
                : context.palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Selects all seven days at once. Deliberately not a toggle: turning it off
/// would leave no days selected, which the form rejects on save.
class _EveryDayButton extends StatelessWidget {
  const _EveryDayButton({required this.isEveryDay, required this.onTap});

  final bool isEveryDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEveryDay ? context.palette.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: isEveryDay ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 1,
          ),
          child: Text(
            context.l10n.everyDay.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: context.palette.primaryInk,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: Material(
        // A real Material rather than `Ink`: it paints its own fill and shape,
        // and clips the ripple to the pill without depending on an ancestor's
        // ink layer.
        color: selected ? AppColors.primary : context.palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    color: selected ? Colors.white : context.palette.textMuted,
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

/// The small bold caption above each field, as in the mockups.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyEmphasis.copyWith(
          color: context.palette.textSecondary,
        ),
      ),
    );
  }
}

class _CircleClose extends StatelessWidget {
  const _CircleClose({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.palette.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.close_rounded,
              size: 19,
              color: context.palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A read-only field that opens a picker: the time and snooze controls.
class _ValueField extends StatelessWidget {
  const _ValueField({
    required this.value,
    required this.trailing,
    required this.onTap,
  });

  final String value;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            height: 54,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15.5),
                  ),
                ),
                Icon(trailing, size: 18, color: context.palette.iconMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
