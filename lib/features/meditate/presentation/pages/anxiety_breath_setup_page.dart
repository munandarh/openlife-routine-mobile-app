import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_preferences.dart';
import 'package:openlife_routine/features/meditate/domain/repositories/meditation_repository.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class AnxietyBreathSetupAuthorization {
  const AnxietyBreathSetupAuthorization();
}

class AnxietyBreathSetupPage extends StatefulWidget {
  const AnxietyBreathSetupPage({
    this.source = 'manual',
    this.routineId,
    this.reminderTime,
    this.occurrenceDate,
    super.key,
  });

  final String source;
  final String? routineId;
  final String? reminderTime;
  final String? occurrenceDate;

  @override
  State<AnxietyBreathSetupPage> createState() => _AnxietyBreathSetupPageState();
}

class _AnxietyBreathSetupPageState extends State<AnxietyBreathSetupPage> {
  int _selectedExhale = 7;
  bool _isLoading = true;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _loadLastUsedExhale();
    unawaited(
      MeditationPreferences().event('anxiety_breath_opened', {
        'source': widget.source,
        'routine_id': widget.routineId,
      }),
    );
  }

  Future<void> _loadLastUsedExhale() async {
    final MeditationRepository repo = AppScope.read(
      context,
    ).meditationRepository;
    int lastUsed = 7;
    try {
      lastUsed = await repo.getLastUsedExhaleSeconds();
    } catch (_) {
      /* A preference failure uses the safe first-time pace. */
    }
    if (mounted) {
      setState(() {
        _selectedExhale = [7, 12, 21].contains(lastUsed) ? lastUsed : 7;
        _isLoading = false;
      });
    }
  }

  Future<void> _onStartBreathing() async {
    if (_starting || _isLoading) return;
    setState(() => _starting = true);
    final MeditationRepository repo = AppScope.read(
      context,
    ).meditationRepository;
    try {
      await repo.setLastUsedExhaleSeconds(_selectedExhale);
    } catch (_) {
      /* Preferences are optional; the chosen pace still applies. */
    }

    if (!mounted) return;

    final Map<String, String> queryParams = <String, String>{
      'exhaleSeconds': '$_selectedExhale',
      'source': widget.source,
      if (widget.routineId != null) 'routineId': widget.routineId!,
      if (widget.reminderTime != null) 'reminderTime': widget.reminderTime!,
      if (widget.occurrenceDate != null)
        'occurrenceDate': widget.occurrenceDate!,
    };

    final Uri uri = Uri(
      path: OpenLifeRoute.breathingPlayer.path,
      queryParameters: queryParams,
    );

    if (widget.source == 'notification') {
      unawaited(
        MeditationPreferences().event('anxiety_breath_reminder_started', {
          'routine_id': widget.routineId,
          'exhale_seconds': _selectedExhale,
        }),
      );
    }
    await context.push(
      uri.toString(),
      extra: const AnxietyBreathSetupAuthorization(),
    );
    if (mounted) setState(() => _starting = false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header back button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.md,
                AppSpacing.pageMargin,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: context.palette.surface,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageMargin,
                        AppSpacing.md,
                        AppSpacing.pageMargin,
                        AppSpacing.xl,
                      ),
                      children: <Widget>[
                        MeditationEntrance(
                          child: Text(
                            l10n.anxietyBreathTitle,
                            style: AppTextStyles.pageTitle.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md + 4),
                        Text(
                          l10n.anxietyBreathSetupTitle,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.anxietyBreathSetupDesc,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            color: context.palette.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Inhale fixed card
                        _InhaleCard(l10n: l10n),
                        const SizedBox(height: AppSpacing.lg),
                        // Exhale section
                        Text(
                          l10n.exhaleLabel,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm + 2),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <int>[7, 12, 21].map((int seconds) {
                            final bool isSelected = _selectedExhale == seconds;
                            return SizedBox(
                              width:
                                  MediaQuery.textScalerOf(context).scale(1) >
                                      1.4
                                  ? double.infinity
                                  : (MediaQuery.sizeOf(context).width - 64) / 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: _ExhaleOptionCard(
                                  seconds: seconds,
                                  isSelected: isSelected,
                                  l10n: l10n,
                                  onTap: () {
                                    unawaited(
                                      MeditationPreferences().event(
                                        'anxiety_breath_exhale_selected',
                                        {
                                          'exhale_seconds': seconds,
                                          'source': widget.source,
                                        },
                                      ),
                                    );
                                    setState(() {
                                      _selectedExhale = seconds;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm + 4),
                        Text(
                          l10n.comfortSafetyNote,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12.5,
                            color: context.palette.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Session duration card
                        _SessionDurationCard(l10n: l10n),
                        const SizedBox(height: 18),
                        BreathingPacePreview(exhaleSeconds: _selectedExhale),
                      ],
                    ),
            ),
            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.sm,
                AppSpacing.pageMargin,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 54 * MediaQuery.textScalerOf(context).scale(1),
                    child: Material(
                      color: AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: _isLoading || _starting
                            ? null
                            : _onStartBreathing,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  l10n.startBreathingAction,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.button.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs + 2),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.canEndSessionAnytime,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12.5,
                      color: context.palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InhaleCard extends StatelessWidget {
  const _InhaleCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: context.palette.border.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.inhaleCardTint,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.air_rounded,
              size: 22,
              color: AppColors.inhaleCardInk,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.inhaleLabel,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.secUnit(3),
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13.5,
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.exhaleCardTint,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              l10n.fixedBadge,
              style: AppTextStyles.label.copyWith(
                color: AppColors.exhaleCardInk,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExhaleOptionCard extends StatelessWidget {
  const _ExhaleOptionCard({
    required this.seconds,
    required this.isSelected,
    required this.l10n,
    required this.onTap,
  });

  final int seconds;
  final bool isSelected;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? AppColors.forestGreenSoft : context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.large),
          onTap: onTap,
          child: AnimatedContainer(
            duration: meditationReducedMotion(context)
                ? Duration.zero
                : const Duration(milliseconds: 280),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md + 2,
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: isSelected
                    ? AppColors.forestGreen
                    : context.palette.border.withValues(alpha: 0.8),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.forestGreen
                        : AppColors.forestGreenBorder,
                  ),
                  child: Icon(
                    Icons.air_rounded,
                    size: 22,
                    color: isSelected ? Colors.white : AppColors.forestGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm + 2),
                Text(
                  l10n.secUnit(seconds),
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionDurationCard extends StatelessWidget {
  const _SessionDurationCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: context.palette.border.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.durationCardTint,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              size: 22,
              color: AppColors.durationCardInk,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.sessionLabel,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.sevenMinutes,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13.5,
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
