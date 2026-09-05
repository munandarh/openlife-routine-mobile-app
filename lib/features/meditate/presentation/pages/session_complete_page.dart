import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class SessionCompletePage extends StatefulWidget {
  const SessionCompletePage({
    this.completedCount = 1,
    this.source = 'manual',
    this.sessionId,
    this.minutes = 7,
    this.type = 'anxiety_breath',
    super.key,
  });

  final int completedCount;
  final String source;
  final String? sessionId;
  final int minutes;
  final String type;

  @override
  State<SessionCompletePage> createState() => _SessionCompletePageState();
}

class _SessionCompletePageState extends State<SessionCompletePage> {
  String? _selectedMood;

  bool _saving = false;
  Future<void> _onDone() async {
    if (_saving) return;
    setState(() => _saving = true);
    if (widget.sessionId != null && _selectedMood != null) {
      try {
        final repo = AppScope.read(context).meditationRepository;
        final sessions = await repo.getSessions();
        final session = sessions
            .where((s) => s.id == widget.sessionId)
            .firstOrNull;
        if (session != null) {
          await repo.saveSession(session.copyWith(mood: _selectedMood));
        }
      } catch (_) {
        if (mounted) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                medText(
                  context,
                  'Mood could not save. Try again.',
                  'Suasana hati belum tersimpan. Coba lagi.',
                ),
              ),
            ),
          );
        }
        return;
      }
    }
    if (!mounted) return;
    if (GoRouter.maybeOf(context) == null) {
      Navigator.of(context).pop();
      return;
    }
    if (widget.source == 'routine' || widget.source == 'notification') {
      context.go(OpenLifeRoute.today.path);
    } else {
      context.go(OpenLifeRoute.meditate.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final int count = widget.completedCount.clamp(0, 5);
    final double progress = (count / 5).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageMargin,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      // Checkmark circle
                      MeditationEntrance(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.forestGreen,
                            boxShadow: AppShadows.primary,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.sessionCompleteTitle,
                        style: AppTextStyles.pageTitle.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        widget.type == 'anxiety_breath'
                            ? l10n.sessionCompleteSubtitle
                            : medText(
                                context,
                                'You gave yourself ${widget.minutes} minutes to simply be.',
                                'Kamu memberi dirimu ${widget.minutes} menit untuk hadir.',
                              ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14.5,
                          color: context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Anxiety target counts only Anxiety Breath.
                      if (widget.type == 'anxiety_breath')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md + 4),
                          decoration: BoxDecoration(
                            color: context.palette.surface,
                            borderRadius: BorderRadius.circular(
                              AppRadius.large,
                            ),
                            border: Border.all(
                              color: context.palette.border.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                count >= 5
                                    ? l10n.allSessionsCompleteToday
                                    : l10n.sessionsCompleteTodayFull(count, 5),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyEmphasis.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: AppColors.forestGreenSoft,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.forestGreen,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      // "How do you feel?"
                      Text(
                        l10n.howDoYouFeel,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children:
                            <(String, String)>[
                              ('calmer', l10n.moodCalmer),
                              ('same', l10n.moodSame),
                              ('uncomfortable', l10n.moodUncomfortable),
                            ].map(((String, String) item) {
                              final (String key, String label) = item;
                              final bool isSelected = _selectedMood == key;
                              return Material(
                                color: isSelected
                                    ? AppColors.forestGreen
                                    : context.palette.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedMood = isSelected ? null : key;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm + 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.pill,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.forestGreen
                                            : context.palette.border,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: AppTextStyles.button.copyWith(
                                        fontSize: 13,
                                        color: isSelected
                                            ? Colors.white
                                            : context.palette.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const Spacer(),
                      // Done button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Material(
                          color: AppColors.forestGreen,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            onTap: _saving ? null : _onDone,
                            child: Center(
                              child: Text(
                                l10n.doneAction,
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
