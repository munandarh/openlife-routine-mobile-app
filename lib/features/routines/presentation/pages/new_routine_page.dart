import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
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
  RoutineCategory _selectedCategory = RoutineCategory.water;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  Set<int> _repeatDays = <int>{1, 2, 3};
  bool _seededFromExisting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing =
        widget.routineId != null && widget.routineId!.isNotEmpty;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BlocConsumer<RoutineBloc, RoutineState>(
      listener: (BuildContext context, RoutineState state) {
        if (!_seededFromExisting &&
            state.selectedRoutine != null &&
            isEditing) {
          final Routine routine = state.selectedRoutine!;
          _nameController.text = routine.title;
          _selectedCategory = routine.category;
          _selectedTime = _parseTime(routine.reminderTime);
          _repeatDays = routine.repeatDays.toSet();
          _seededFromExisting = true;
          setState(() {});
        }

        if (state.saved) {
          context.pop();
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
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Routine' : 'New Routine',
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
                Text('Routine Name', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Morning Yoga',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Category', style: textTheme.titleLarge),
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
                Text('Time', style: textTheme.titleLarge),
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
                    child: Text(_formatTime(_selectedTime)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Repeat', style: textTheme.titleLarge),
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
                      final List<String> labels = <String>[
                        'M',
                        'T',
                        'W',
                        'T',
                        'F',
                        'S',
                        'S',
                      ];
                      return _RepeatChip(
                        label: labels[index],
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
                const SizedBox(height: AppSpacing.xxxl),
                PrimaryButton(
                  label: isEditing ? 'Save Changes' : 'Save Routine',
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

  String _formatTime(TimeOfDay time) {
    final bool isPm = time.period == DayPeriod.pm;
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String suffix = isPm ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  TimeOfDay _parseTime(String reminderTime) {
    final List<String> parts = reminderTime.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _serializeTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _submit(BuildContext context, bool isEditing) {
    final RoutineBloc bloc = context.read<RoutineBloc>();
    final List<int> repeatDays = _repeatDays.toList()..sort();

    if (isEditing) {
      bloc.add(
        RoutineUpdateRequested(
          id: widget.routineId!,
          title: _nameController.text,
          category: _selectedCategory,
          reminderTime: _serializeTime(_selectedTime),
          repeatDays: repeatDays,
          isEnabled: true,
        ),
      );
      return;
    }

    bloc.add(
      RoutineCreateRequested(
        title: _nameController.text,
        category: _selectedCategory,
        reminderTime: _serializeTime(_selectedTime),
        repeatDays: repeatDays,
      ),
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
    const List<_CategoryOption> options = <_CategoryOption>[
      _CategoryOption(
        category: RoutineCategory.meal,
        label: 'Meal',
        icon: Icons.restaurant_outlined,
        background: Color(0xFFFFF1C8),
        foreground: AppColors.warning,
      ),
      _CategoryOption(
        category: RoutineCategory.water,
        label: 'Water',
        icon: Icons.water_drop_outlined,
        background: AppColors.primarySoft,
        foreground: AppColors.primary,
      ),
      _CategoryOption(
        category: RoutineCategory.vitamin,
        label: 'Vitamin',
        icon: Icons.medication_outlined,
        background: Color(0xFFFFF1C8),
        foreground: AppColors.warning,
      ),
      _CategoryOption(
        category: RoutineCategory.medicine,
        label: 'Medicine',
        icon: Icons.vaccines_outlined,
        background: Color(0xFFFFE0DF),
        foreground: AppColors.danger,
      ),
      _CategoryOption(
        category: RoutineCategory.sleep,
        label: 'Sleep',
        icon: Icons.bedtime_outlined,
        background: Color(0xFFDDEBF5),
        foreground: AppColors.secondary,
      ),
      _CategoryOption(
        category: RoutineCategory.exercise,
        label: 'Exercise',
        icon: Icons.fitness_center_outlined,
        background: Color(0xFFDDEBF5),
        foreground: AppColors.secondary,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      physics: const NeverScrollableScrollPhysics(),
      children: options.map((_CategoryOption option) {
        return _CategoryTile(
          label: option.label,
          icon: option.icon,
          background: option.background,
          foreground: option.foreground,
          selected: option.category == selectedCategory,
          onTap: () => onSelected(option.category),
        );
      }).toList(),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({
    required this.category,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final RoutineCategory category;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
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
    return InkWell(
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
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
