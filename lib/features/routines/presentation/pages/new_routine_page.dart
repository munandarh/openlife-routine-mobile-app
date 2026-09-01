import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/app/router/navigation_extensions.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/localization/l10n_formatters.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
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
                    IconButton(
                      onPressed: () => context.popOrGo(OpenLifeRoute.today.path),
                      tooltip: l10n.closeAction,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Expanded(
                      child: Text(
                        isEditing ? l10n.editRoutine : l10n.newRoutine,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.routineName, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(hintText: l10n.routineNameHint),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.categoryLabel, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _CategoryGrid(
                  selectedCategory: _selectedCategory,
                  onSelected: (RoutineCategory category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.iconLabel, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _IconPicker(
                  category: _selectedCategory,
                  selectedIconKey: _iconKey,
                  onSelected: (String? iconKey) {
                    setState(() {
                      _iconKey = iconKey;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.timeLabel, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedTime = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.schedule_outlined),
                    ),
                    child: Text(
                      L10nFormatters.timeLabel(context, _selectedTime),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.repeatLabel, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(7, (int index) {
                      final int dayValue = index + 1;
                      final List<String> initials =
                          L10nFormatters.weekdayInitials(l10n);
                      final List<String> names =
                          L10nFormatters.weekdayAbbreviations(l10n);

                      return _RepeatChip(
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
                Text(l10n.snoozeDuration, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Slider(
                        value: _snoozeMinutes.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        label: l10n.minutesLabel(_snoozeMinutes),
                        onChanged: (double value) {
                          setState(() {
                            _snoozeMinutes = value.round();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        l10n.minutesShort(_snoozeMinutes),
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ],
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
          isEnabled: true,
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

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      physics: const NeverScrollableScrollPhysics(),
      children: RoutineCategory.values.map((RoutineCategory category) {
        return _CategoryTile(
          label: RoutineCategoryUi.label(l10n, category),
          icon: RoutineCategoryUi.defaultIcon(category),
          background: RoutineCategoryUi.background(category),
          foreground: RoutineCategoryUi.foreground(category),
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
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: background,
                foregroundColor: foreground,
                child: Icon(icon),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
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
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: selected ? AppColors.primary : AppColors.textSecondary,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Center(
            child: ExcludeSemantics(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
