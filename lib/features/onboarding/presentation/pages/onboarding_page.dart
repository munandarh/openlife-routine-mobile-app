import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/presentation/bloc/routine_bloc.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';
import 'package:openlife_routine/features/templates/domain/repositories/template_repository.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

/// Key for the circular primary action (Continue / Get Started).
const Key onboardingPrimaryActionKey = Key('onboardingPrimaryAction');

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (BuildContext context) => OnboardingBloc(
        repository: AppScope.read(context).onboardingRepository,
      )..add(const OnboardingStarted()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Creates the routines of the chosen starter template, then leaves the
  /// first-run flow. A null [templateId] means the user chose to start empty.
  Future<void> _applyStarterAndLeave(
    BuildContext context,
    String? templateId,
  ) async {
    if (templateId != null) {
      final RoutineBloc routineBloc = AppScope.read(
        context,
      ).createRoutineBloc();
      final List<RoutineTemplate> templates = await const TemplateRepository()
          .getTemplates();

      for (final RoutineTemplate template in templates) {
        if (template.id != templateId) {
          continue;
        }

        for (final TemplateRoutineItem item in template.routines) {
          routineBloc.add(
            RoutineCreateRequested(
              title: item.title,
              category: RoutineCategory.values.firstWhere(
                (RoutineCategory category) => category.name == item.category,
                orElse: () => RoutineCategory.custom,
              ),
              reminderTime: item.reminderTime,
              repeatDays: item.repeatDays,
            ),
          );
        }
      }
    }

    if (!context.mounted) {
      return;
    }

    context.go(OpenLifeRoute.today.path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (OnboardingState previous, OnboardingState current) {
        return previous.pageIndex != current.pageIndex ||
            previous.status != current.status;
      },
      listener: (BuildContext context, OnboardingState state) {
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.pageIndex) {
          unawaited(
            _pageController.animateToPage(
              state.pageIndex,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            ),
          );
        }

        if (state.status == OnboardingStatus.completed) {
          unawaited(_applyStarterAndLeave(context, state.selectedTemplateId));
          return;
        }

        if (state.status == OnboardingStatus.skipped) {
          context.go(OpenLifeRoute.today.path);
        }
      },
      builder: (BuildContext context, OnboardingState state) {
        final OnboardingBloc bloc = context.read<OnboardingBloc>();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageMargin,
                    AppSpacing.sm,
                    AppSpacing.pageMargin,
                    0,
                  ),
                  child: _TopBar(
                    pageIndex: state.pageIndex,
                    totalPages: state.totalPages,
                    onBack: () => bloc.add(const OnboardingBackPressed()),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      bloc.add(OnboardingPageChanged(index));
                    },
                    children: <Widget>[
                      _OnboardingSlide(
                        title: 'Build better days',
                        description:
                            'Design a routine that fits your life. Gentle nudges, not rigid rules.',
                        hero: const _HeroCard(
                          illustration: AssetVectors.onboardingBuildBetterDays,
                          fallbackIcon: Icons.fact_check_outlined,
                        ),
                        footer: _LanguageSelector(
                          selectedLanguageCode: state.selectedLanguageCode,
                          onSelected: (String languageCode) {
                            bloc.add(OnboardingLanguageSelected(languageCode));
                          },
                        ),
                      ),
                      const _OnboardingSlide(
                        title: 'Never miss what matters',
                        description:
                            'Receive calm reminders for meals, water, vitamins, and small routines that support your day.',
                        hero: _HeroCard(
                          illustration: AssetVectors.onboardingSmartRoutines,
                          fallbackIcon: Icons.notifications_active_outlined,
                        ),
                        footer: _InfoPanel(
                          title: 'Notification education',
                          message:
                              'We will ask for notification permission later, only when reminder scheduling is ready.',
                        ),
                      ),
                      _OnboardingSlide(
                        title: 'Private by default',
                        description:
                            'Your routines stay on-device first. No account required to start, and no forced cloud setup.',
                        hero: const _HeroCard(
                          illustration: AssetVectors.onboardingPrivateByDefault,
                          fallbackIcon: Icons.lock_outline_rounded,
                        ),
                        footer: const _InfoPanel(
                          title: 'On-device storage',
                          message:
                              'Routines and history live in a local database on this phone. Export a JSON backup any time from Settings.',
                        ),
                      ),
                      _OnboardingSlide(
                        title: 'Start with a template',
                        description:
                            'Pick a starter to begin, or start empty and add routines yourself.',
                        hero: const _HeroCard(
                          illustration: AssetVectors.onboardingStarterTemplate,
                          fallbackIcon: Icons.dashboard_customize_outlined,
                        ),
                        footer: _StarterTemplatePicker(
                          selectedTemplateId: state.selectedTemplateId,
                          onSelected: (String? templateId) {
                            bloc.add(OnboardingTemplateSelected(templateId));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageMargin,
                    AppSpacing.lg,
                    AppSpacing.pageMargin,
                    AppSpacing.xl,
                  ),
                  child: _BottomBar(
                    isLastPage: state.isLastPage,
                    progress: (state.pageIndex + 1) / state.totalPages,
                    onPrimaryPressed: () =>
                        bloc.add(const OnboardingNextPressed()),
                    onSecondaryPressed: () {
                      if (state.isLastPage) {
                        bloc.add(const OnboardingBackPressed());
                        return;
                      }

                      bloc.add(const OnboardingSkipped());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Brand (or back button) on the left, step counter on the right.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.pageIndex,
    required this.totalPages,
    required this.onBack,
  });

  final int pageIndex;
  final int totalPages;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        if (pageIndex > 0)
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
            tooltip: 'Back',
          )
        else ...<Widget>[
          const Icon(Icons.spa_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'OpenLife Routine',
            style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
          ),
        ],
        const Spacer(),
        _StepCounter(current: pageIndex + 1, total: totalPages),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 16, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _StepCounter extends StatelessWidget {
  const _StepCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$current / $total',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.hero,
    required this.footer,
  });

  final String title;
  final String description;
  final Widget hero;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // The hero owns the largest share of the slide so the artwork fills
        // the card instead of floating inside a nested frame.
        final double heroHeight = (constraints.maxHeight * 0.52).clamp(
          200.0,
          380.0,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: heroHeight, child: hero),
              const SizedBox(height: AppSpacing.xl),
              Text(title, style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              footer,
            ],
          ),
        );
      },
    );
  }
}

/// A single rounded card filled edge to edge by the slide illustration.
///
/// The artwork is drawn with [BoxFit.cover] so it bleeds to the card corners
/// instead of sitting in a nested frame. The hairline border keeps the card
/// readable: the illustration's own cream backdrop is nearly the same tone as
/// the page background.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.illustration, required this.fallbackIcon});

  final AssetVectorEntry illustration;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: OpenLifeRiveView.illustrationFill(
        illustrationPath: illustration.path,
        fallbackIcon: fallbackIcon,
      ),
    );
  }
}

/// Secondary text action on the left, circular primary action on the right.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isLastPage,
    required this.progress,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final bool isLastPage;
  final double progress;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        TextButton(
          onPressed: onSecondaryPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: Text(isLastPage ? 'Back' : 'Skip'),
        ),
        const Spacer(),
        _NextButton(
          key: onboardingPrimaryActionKey,
          progress: progress,
          label: isLastPage ? 'Get Started' : 'Continue',
          icon: isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
          onPressed: onPrimaryPressed,
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.progress,
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final double progress;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (BuildContext context, double value, Widget? child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.floating,
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onPressed,
                    child: Center(
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
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

/// Interactive starter picker on the last slide. Selecting a chip stores the
/// template id in the bloc; "Start empty" clears it. The routines are created
/// when the user taps Get Started.
class _StarterTemplatePicker extends StatelessWidget {
  const _StarterTemplatePicker({
    required this.selectedTemplateId,
    required this.onSelected,
  });

  final String? selectedTemplateId;
  final ValueChanged<String?> onSelected;

  static const List<_StarterOption> _options = <_StarterOption>[
    _StarterOption(
      id: 'morning',
      label: 'Morning Routine',
      icon: Icons.wb_sunny_outlined,
    ),
    _StarterOption(
      id: 'hydration',
      label: 'Hydration',
      icon: Icons.water_drop_outlined,
    ),
    _StarterOption(
      id: 'vitamin',
      label: 'Vitamin',
      icon: Icons.medication_outlined,
    ),
    _StarterOption(id: 'sleep', label: 'Sleep', icon: Icons.bedtime_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Pick a starter',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final _StarterOption option in _options)
              _StarterChip(
                option: option,
                isSelected: option.id == selectedTemplateId,
                onTap: () => onSelected(
                  option.id == selectedTemplateId ? null : option.id,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          selectedTemplateId == null
              ? 'Nothing selected — you will start with an empty list.'
              : 'These routines are added when you tap Get Started. You can '
                    'edit or delete them any time.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StarterOption {
  const _StarterOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _StarterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isSelected ? Icons.check_rounded : option.icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              option.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedLanguageCode,
    required this.onSelected,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose your starting language',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            _LanguageChip(
              label: 'English',
              value: 'en',
              selectedValue: selectedLanguageCode,
              onSelected: onSelected,
            ),
            const SizedBox(width: AppSpacing.sm),
            _LanguageChip(
              label: 'Bahasa',
              value: 'id',
              selectedValue: selectedLanguageCode,
              onSelected: onSelected,
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool selected = value == selectedValue;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: () => onSelected(value),
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (selected) ...<Widget>[
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
