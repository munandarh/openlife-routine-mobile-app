import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';
import 'package:openlife_routine/shared/widgets/rive/openlife_rive_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

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

        if (state.status == OnboardingStatus.completed ||
            state.status == OnboardingStatus.skipped) {
          context.go(OpenLifeRoute.today.path);
        }
      },
      builder: (BuildContext context, OnboardingState state) {
        final OnboardingBloc bloc = context.read<OnboardingBloc>();

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (state.pageIndex > 0)
                        IconButton(
                          onPressed: () =>
                              bloc.add(const OnboardingBackPressed()),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        )
                      else ...<Widget>[
                        const Icon(
                          Icons.spa_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'OpenLife Routine',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      TextButton(
                        onPressed: () => bloc.add(const OnboardingSkipped()),
                        child: const Text('Skip'),
                      ),
                    ],
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
                          hero: _SlideHero(
                            backgroundColor: AppColors.primarySoft.withValues(
                              alpha: 0.45,
                            ),
                            icon: Icons.fact_check_outlined,
                            illustrationPath:
                                AssetVectors.onboardingBuildBetterDays.path,
                          ),
                          footer: _LanguageSelector(
                            selectedLanguageCode: state.selectedLanguageCode,
                            onSelected: (String languageCode) {
                              bloc.add(
                                OnboardingLanguageSelected(languageCode),
                              );
                            },
                          ),
                        ),
                        _OnboardingSlide(
                          title: 'Never miss what matters',
                          description:
                              'Receive calm reminders for meals, water, vitamins, and small routines that support your day.',
                          hero: _SlideHero(
                            backgroundColor: Color(0xFFFFF1C8),
                            icon: Icons.notifications_active_outlined,
                            illustrationPath:
                                AssetVectors.onboardingSmartRoutines.path,
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
                          hero: _SlideHero(
                            backgroundColor: Color(0xFFDDEBF5),
                            icon: Icons.lock_outline_rounded,
                            illustrationPath:
                                AssetVectors.onboardingPrivateByDefault.path,
                          ),
                          footer: _InfoPanel(
                            title: 'Static fallback ready',
                            message:
                                'Sprint 2 uses lightweight static hero panels now. Rive can replace these later without changing the flow.',
                          ),
                        ),
                        _OnboardingSlide(
                          title: 'Start with a template',
                          description:
                              'Pick a starter template to begin, or add routines yourself one at a time.',
                          hero: _SlideHero(
                            backgroundColor: AppColors.primarySoft,
                            icon: Icons.dashboard_customize_outlined,
                            illustrationPath:
                                AssetVectors.onboardingStarterTemplate.path,
                          ),
                          footer: const _StarterTemplatePanel(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _PageIndicators(
                    currentPage: state.pageIndex,
                    totalPages: state.totalPages,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: state.isLastPage ? 'Get Started' : 'Continue',
                    onPressed: () => bloc.add(const OnboardingNextPressed()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: state.isLastPage ? 'Back' : 'Skip',
                    isSecondary: true,
                    onPressed: () {
                      if (state.isLastPage) {
                        bloc.add(const OnboardingBackPressed());
                        return;
                      }

                      bloc.add(const OnboardingSkipped());
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

    return Column(
      children: <Widget>[
        Expanded(child: hero),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          title,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          description,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        footer,
      ],
    );
  }
}

class _SlideHero extends StatelessWidget {
  const _SlideHero({
    required this.backgroundColor,
    required this.icon,
    this.illustrationPath,
  });

  final Color backgroundColor;
  final IconData icon;

  /// Optional PNG illustration path. When provided, this is rendered
  /// instead of the icon. See `AssetVectors` for the registry.
  final String? illustrationPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        ),
        child: Center(
          child: illustrationPath != null
              ? OpenLifeRiveView.illustration(
                  illustrationPath: illustrationPath!,
                  fallbackIcon: icon,
                  size: 120,
                )
              : OpenLifeRiveView.asset(
                  assetName: 'assets/rive/onboarding_build_better_days.riv',
                  fallbackIcon: icon,
                  size: 120,
                ),
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
      children: <Widget>[
        Text(
          'Choose your starting language',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _LanguageChip(
              label: 'English',
              value: 'en',
              selectedValue: selectedLanguageCode,
              onSelected: onSelected,
            ),
            const SizedBox(width: AppSpacing.md),
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
          color: selected ? AppColors.primarySoft : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
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
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(totalPages, (int index) {
        final bool isSelected = index == currentPage;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}

class _StarterTemplatePanel extends StatelessWidget {
  const _StarterTemplatePanel();

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Pick a starter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose a starter template or skip and add routines yourself.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _StarterTemplateChip(
                label: 'Morning Routine',
                icon: Icons.wb_sunny_outlined,
                background: AppColors.accentSoft,
                foreground: AppColors.warning,
              ),
              _StarterTemplateChip(
                label: 'Hydration',
                icon: Icons.water_drop_outlined,
                background: AppColors.secondarySoft,
                foreground: AppColors.secondary,
              ),
              _StarterTemplateChip(
                label: 'Vitamin',
                icon: Icons.medication_outlined,
                background: AppColors.accentSoft,
                foreground: AppColors.warning,
              ),
              _StarterTemplateChip(
                label: 'Sleep',
                icon: Icons.bedtime_outlined,
                background: AppColors.secondarySoft,
                foreground: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Or, you can start empty and add routines later from the Routines tab.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Start empty',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarterTemplateChip extends StatelessWidget {
  const _StarterTemplateChip({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
