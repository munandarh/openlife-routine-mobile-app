import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';
import 'package:openlife_routine/features/templates/domain/usecases/apply_template_use_case.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_bloc.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_event.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_state.dart';
import 'package:openlife_routine/features/templates/presentation/utils/template_l10n.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';
import 'package:openlife_routine/shared/widgets/illustrations/app_illustration.dart';

/// Key for the circular primary action (Continue / Get Started).
const Key onboardingPrimaryActionKey = Key('onboardingPrimaryAction');

/// Key for the "start empty" option on the starter-template step.
const Key onboardingStartEmptyKey = Key('onboardingStartEmpty');

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<OnboardingBloc>(
          create: (BuildContext context) => OnboardingBloc(
            repository: AppScope.read(context).onboardingRepository,
          )..add(const OnboardingStarted()),
        ),
        BlocProvider<TemplateBloc>(
          create: (BuildContext context) =>
              AppScope.read(context).createTemplateBloc()
                ..add(const TemplatesLoaded()),
        ),
      ],
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
  bool _isFinishing = false;

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

  /// Applies the chosen starter template (if any) before handing control to the
  /// bloc, so the user lands on a Today screen that already has routines.
  Future<void> _finish(OnboardingState state) async {
    if (_isFinishing) {
      return;
    }
    setState(() => _isFinishing = true);

    final OnboardingBloc bloc = context.read<OnboardingBloc>();
    try {
      final String? templateId = state.selectedTemplateId;
      if (templateId != null) {
        final AppLocalizations l10n = context.l10n;
        final TemplateState templates = context.read<TemplateBloc>().state;
        final RoutineTemplate? template = templates.templates
            .where((RoutineTemplate t) => t.id == templateId)
            .firstOrNull;

        if (template != null) {
          final ApplyTemplateUseCase applyTemplate = AppScope.read(
            context,
          ).createApplyTemplateUseCase();
          await applyTemplate(
            template,
            titleResolver: (TemplateRoutineItem item) =>
                TemplateL10n.routineTitle(l10n, item),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isFinishing = false);
      }
    }

    bloc.add(const OnboardingNextPressed());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

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
          backgroundColor: context.palette.background,
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
                        title: l10n.onboardingSlide1Title,
                        description: l10n.onboardingSlide1Desc,
                        hero: const _HeroCard(
                          illustration: AssetVectors.onboardingBuildBetterDays,
                          fallbackIcon: Icons.fact_check_outlined,
                        ),
                        // No language picker here: the dedicated
                        // Language Selection page already asked, before this
                        // screen, and asking twice reads as the first answer
                        // not having been saved.
                      ),
                      _OnboardingSlide(
                        title: l10n.onboardingSlide2Title,
                        description: l10n.onboardingSlide2Desc,
                        hero: const _HeroCard(
                          illustration: AssetVectors.onboardingSmartRoutines,
                          fallbackIcon: Icons.notifications_active_outlined,
                        ),
                        footer: _InfoPanel(
                          title: l10n.notificationEducationTitle,
                          message: l10n.notificationEducationMessage,
                        ),
                      ),
                      _OnboardingSlide(
                        title: l10n.onboardingSlide3Title,
                        description: l10n.onboardingSlide3Desc,
                        hero: const _HeroCard(
                          illustration: AssetVectors.onboardingPrivateByDefault,
                          fallbackIcon: Icons.lock_outline_rounded,
                        ),
                        footer: _InfoPanel(
                          title: l10n.privacyPanelTitle,
                          message: l10n.privacyPanelMessage,
                        ),
                      ),
                      _OnboardingSlide(
                        title: l10n.onboardingSlide4Title,
                        description: l10n.onboardingSlide4Desc,
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
                    isBusy: _isFinishing,
                    progress: (state.pageIndex + 1) / state.totalPages,
                    onPrimaryPressed: () {
                      if (state.isLastPage) {
                        unawaited(_finish(state));
                        return;
                      }
                      bloc.add(const OnboardingNextPressed());
                    },
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
            tooltip: context.l10n.backButton,
          )
        else ...<Widget>[
          Icon(Icons.spa_outlined, color: context.palette.primaryInk, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.l10n.appTitle,
            style: textTheme.titleMedium?.copyWith(
              color: context.palette.primaryInk,
            ),
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
        color: context.palette.surface,
        shape: CircleBorder(side: BorderSide(color: context.palette.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 16, color: context.palette.textPrimary),
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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.card,
      ),
      child: Text(
        context.l10n.onboardingStepCounter(current, total),
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: context.palette.textSecondary),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.hero,
    this.footer,
  });

  final String title;
  final String description;
  final Widget hero;

  /// Optional: the first slide carries no footer now that the language
  /// question has its own page.
  final Widget? footer;

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
                  color: context.palette.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ?footer,
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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: AppIllustration.fill(
        assetPath: illustration.path,
        fallbackIcon: fallbackIcon,
      ),
    );
  }
}

/// Secondary text action on the left, circular primary action on the right.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isLastPage,
    required this.isBusy,
    required this.progress,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final bool isLastPage;
  final bool isBusy;
  final double progress;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Row(
      children: <Widget>[
        TextButton(
          onPressed: isBusy ? null : onSecondaryPressed,
          style: TextButton.styleFrom(
            foregroundColor: context.palette.textSecondary,
          ),
          child: Text(isLastPage ? l10n.backButton : l10n.skipButton),
        ),
        const Spacer(),
        _NextButton(
          key: onboardingPrimaryActionKey,
          progress: progress,
          label: isLastPage ? l10n.getStarted : l10n.continueButton,
          icon: isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
          isBusy: isBusy,
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
    required this.isBusy,
    required this.onPressed,
    super.key,
  });

  final double progress;
  final String label;
  final IconData icon;
  final bool isBusy;
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
                      backgroundColor: context.palette.border,
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
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.lifted,
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isBusy ? null : onPressed,
                    child: Center(
                      child: isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(icon, color: Colors.white, size: 22),
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

/// Final onboarding step: pick one of the seed templates, or start empty.
///
/// The pick is only recorded here; it is applied when the user taps
/// "Get Started" so backing out of the step leaves no routines behind.
class _StarterTemplatePicker extends StatelessWidget {
  const _StarterTemplatePicker({
    required this.selectedTemplateId,
    required this.onSelected,
  });

  final String? selectedTemplateId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return BlocBuilder<TemplateBloc, TemplateState>(
      builder: (BuildContext context, TemplateState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.pickStarter,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final RoutineTemplate template in state.templates)
                  _SelectableChip(
                    label: TemplateL10n.title(l10n, template),
                    selected: template.id == selectedTemplateId,
                    onTap: () => onSelected(template.id),
                  ),
                _SelectableChip(
                  key: onboardingStartEmptyKey,
                  label: l10n.startEmpty,
                  selected: selectedTemplateId == null,
                  onTap: () => onSelected(null),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.orStartEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Pill-shaped single choice used by both the language and template pickers.
class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected
                ? context.palette.primarySoft
                : context.palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected
                  ? context.palette.primaryInk
                  : context.palette.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (selected) ...<Widget>[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: context.palette.primaryInk,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? AppColors.primary
                      : context.palette.textSecondary,
                ),
              ),
            ],
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
        color: context.palette.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.palette.primaryInk,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
