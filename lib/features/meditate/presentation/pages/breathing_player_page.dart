import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/notifications/notification_actions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_audio.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_preferences.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_session_writer.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_practice.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/breathing_player_cubit.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/session_complete_page.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/breathing_orb.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/end_session_dialog.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';

class BreathingPlayerPage extends StatefulWidget {
  const BreathingPlayerPage({
    required this.exhaleSeconds,
    this.source = 'manual',
    this.routineId,
    this.reminderTime,
    this.occurrenceDate,
    this.practice,
    this.durationMinutes,
    super.key,
  });
  final int exhaleSeconds;
  final String source;
  final String? routineId, reminderTime, occurrenceDate;
  final MeditationPractice? practice;
  final int? durationMinutes;
  @override
  State<BreathingPlayerPage> createState() => _BreathingPlayerPageState();
}

class _BreathingPlayerPageState extends State<BreathingPlayerPage>
    with SingleTickerProviderStateMixin {
  late final BreathingPlayerCubit _cubit;
  late final AnimationController _phaseMotion;
  late final MeditationAudio _audio;
  final MeditationPreferences _preferences = MeditationPreferences();
  final Stopwatch _generalClock = Stopwatch();
  Timer? _generalTicker;
  AppLifecycleListener? _lifecycle;
  late final DateTime _startedAt;
  late final String _sessionId;
  bool _generalPaused = false, _generalCompleted = false;
  bool _saving = false,
      _saveFailed = false,
      _allowExit = false,
      _dialogOpen = false,
      _haptics = false;
  int _generalElapsed = 0;
  BreathingPhase _animatedPhase = BreathingPhase.inhale;
  bool _reduced = false;
  MeditationSession? _finishedSession;
  bool get _breathing => widget.practice == null;
  int get _planned => _breathing
      ? 420
      : (widget.durationMinutes ?? widget.practice!.minutes) * 60;
  bool get _paused => _breathing ? _cubit.state.isPaused : _generalPaused;
  bool get _completed =>
      _breathing ? _cubit.state.isCompleted : _generalCompleted;
  Color get _color => meditationColor(widget.practice?.category ?? 'calm');
  String get _type => widget.practice?.id ?? 'anxiety_breath';
  Map<String, Object?> get _eventProperties => {
    'source': widget.source,
    'exercise_type': _type,
    'exhale_seconds': _breathing ? widget.exhaleSeconds : null,
    'routine_id': widget.routineId,
    'occurrence_id': _occurrenceId,
  };
  String? get _occurrenceId =>
      widget.routineId == null || widget.reminderTime == null
      ? null
      : '${widget.routineId}|${widget.occurrenceDate ?? routineLogDateKey(_startedAt)}|${widget.reminderTime}';
  void _event(String verb) => unawaited(
    _preferences.event(
      '${_breathing ? 'anxiety_breath' : 'meditation'}_$verb',
      _eventProperties,
    ),
  );

  @override
  void initState() {
    super.initState();
    _audio = AppScope.read(context).createMeditationAudio();
    _startedAt = DateTime.now();
    _sessionId = 'session_${_startedAt.microsecondsSinceEpoch}';
    _cubit = BreathingPlayerCubit(
      exhaleSeconds: widget.exhaleSeconds,
      autoStart: _breathing,
    );
    _phaseMotion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (_breathing) _phaseMotion.forward();
    if (!_breathing) {
      _generalClock.start();
      _generalTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final elapsed = _generalClock.elapsed.inSeconds.clamp(0, _planned);
        if (!mounted || _generalCompleted || elapsed == _generalElapsed) return;
        setState(() => _generalElapsed = elapsed);
        if (elapsed >= _planned) {
          _generalCompleted = true;
          _generalClock.stop();
          _generalTicker?.cancel();
          unawaited(_finish());
        }
      });
    }
    _lifecycle = AppLifecycleListener(
      onInactive: _pause,
      onPause: _pause,
      onHide: _pause,
    );
    _event('started');
    _audio.addListener(_audioChanged);
    unawaited(_startAudio());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = meditationReducedMotion(context);
    if (_reduced) _phaseMotion.stop();
  }

  Future<void> _startAudio() async {
    try {
      _audio.enabled = await _preferences.musicEnabled();
      _audio.volume = await _preferences.musicVolume();
    } catch (_) {
      /* Default music is still available offline. */
    }
    if (!mounted) return;
    await _audio.start(widget.practice?.sound ?? 'forest_stream_flow');
    if (_paused || _completed) await _audio.pause();
  }

  void _audioChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    _generalTicker?.cancel();
    _generalClock.stop();
    _phaseMotion.dispose();
    _cubit.close();
    _audio.removeListener(_audioChanged);
    _audio.dispose();
    super.dispose();
  }

  void _pause() {
    if (_paused || _completed) return;
    if (_breathing) {
      _cubit.pause();
    } else {
      _generalClock.stop();
      setState(() => _generalPaused = true);
    }
    _phaseMotion.stop();
    unawaited(_audio.pause());
    _event('paused');
  }

  void _resume() {
    if (!_paused || _completed) return;
    if (_breathing) {
      _cubit.resume();
    } else {
      _generalClock.start();
      setState(() => _generalPaused = false);
    }
    unawaited(_audio.resume());
    _event('resumed');
  }

  void _animatePhase(BreathingPlayerState state, {bool restart = false}) {
    if (_reduced || state.isPaused || state.isCompleted) {
      _phaseMotion.stop();
      return;
    }
    if (restart) _phaseMotion.value = 0;
    _phaseMotion.duration = Duration(seconds: state.currentPhaseDuration);
    unawaited(_phaseMotion.forward());
  }

  Future<void> _finish({bool abandoned = false}) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    _phaseMotion.stop();
    unawaited(_audio.pause());
    final dependencies = AppScope.read(context);
    final now = DateTime.now();
    _finishedSession ??= MeditationSession(
      id: _sessionId,
      type: _type,
      source: widget.source,
      routineId: widget.routineId,
      occurrenceId: _occurrenceId,
      inhaleSec: _breathing ? 3 : 0,
      exhaleSec: _breathing ? widget.exhaleSeconds : 0,
      plannedDurationSec: _planned,
      actualDurationSec: abandoned
          ? (_breathing
                ? 420 - _cubit.state.totalSecondsRemaining
                : _generalElapsed)
          : _planned,
      status: abandoned ? 'abandoned' : 'completed',
      startedAt: _startedAt,
      completedAt: abandoned ? null : now,
    );
    try {
      await MeditationSessionWriter(
        dependencies.meditationRepository,
        dependencies.appDatabase,
      ).save(
        _finishedSession!,
        occurrenceDate: widget.occurrenceDate ?? routineLogDateKey(_startedAt),
        reminderTime: widget.reminderTime,
      );
      final count = await dependencies.meditationRepository
          .getDailyAnxietyBreathCompletedCount(now);
      unawaited(
        _preferences.event(
          '${_breathing ? 'anxiety_breath' : 'meditation'}_${abandoned ? 'abandoned' : 'completed'}',
          {
            ..._eventProperties,
            'actual_duration_seconds': _finishedSession!.actualDurationSec,
            'session_index_today': count,
          },
        ),
      );
      if (_breathing && !abandoned && count == 5) {
        _event('daily_target_completed');
      }
      if (!mounted) return;
      if (abandoned) {
        _exit();
        return;
      }
      if (GoRouter.maybeOf(context) != null) {
        context.go(
          Uri(
            path: OpenLifeRoute.sessionComplete.path,
            queryParameters: {
              'completedCount': '$count',
              'source': widget.source,
              'sessionId': _sessionId,
              'minutes': '${_planned ~/ 60}',
              'type': _type,
            },
          ).toString(),
        );
      } else {
        unawaited(
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => SessionCompletePage(
                completedCount: count,
                source: widget.source,
                sessionId: _sessionId,
                minutes: _planned ~/ 60,
                type: _type,
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saveFailed = true;
          _saving = false;
        });
      }
    }
  }

  void _exit() {
    setState(() => _allowExit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = GoRouter.maybeOf(context);
      if (router != null && !router.canPop()) {
        router.go(OpenLifeRoute.meditate.path);
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _confirmEndSession() async {
    if (_dialogOpen || _saving || _completed) return;
    _dialogOpen = true;
    final wasPaused = _paused;
    _pause();
    final idLocale = Localizations.localeOf(context).languageCode == 'id';
    final end = await EndSessionDialog.show(
      context,
      message: widget.routineId != null
          ? null
          : (idLocale
                ? 'Sesi ini akan disimpan sebagai sesi yang diakhiri lebih awal.'
                : 'This session will be saved as ended early.'),
      continueLabel: _breathing
          ? null
          : (idLocale ? 'Lanjut meditasi' : 'Keep meditating'),
    );
    _dialogOpen = false;
    if (!mounted) return;
    if (end == true) {
      await _finish(abandoned: true);
    } else if (!wasPaused) {
      _resume();
    }
  }

  String _time(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: _allowExit,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmEndSession();
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<BreathingPlayerCubit, BreathingPlayerState>(
            bloc: _cubit,
            listenWhen: (a, b) =>
                a.phase != b.phase ||
                a.isPaused != b.isPaused ||
                a.isCompleted != b.isCompleted,
            listener: (context, state) {
              if (state.isCompleted) {
                unawaited(_finish());
                return;
              }
              final newPhase = state.phase != _animatedPhase;
              _animatedPhase = state.phase;
              _animatePhase(state, restart: newPhase);
              if (_haptics && newPhase) {
                unawaited(
                  HapticFeedback.lightImpact().catchError((Object _) {}),
                );
              }
            },
            builder: (context, state) {
              final remaining = _breathing
                  ? state.totalSecondsRemaining
                  : _planned - _generalElapsed;
              return LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight - 32),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton.filledTonal(
                                tooltip: medText(context, 'Back', 'Kembali'),
                                onPressed: _confirmEndSession,
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              Expanded(
                                child: Text(
                                  medText(
                                    context,
                                    'A MOMENT FOR YOU',
                                    'WAKTU UNTUKMU',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    color: context.palette.textSecondary,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: medText(context, 'Music', 'Musik'),
                                onPressed: _audio.available
                                    ? () {
                                        unawaited(
                                          _audio.setEnabled(
                                            !_audio.enabled,
                                            paused: _paused,
                                          ),
                                        );
                                        unawaited(
                                          _preferences
                                              .setMusic(_audio.enabled)
                                              .catchError((Object _) {}),
                                        );
                                      }
                                    : null,
                                icon: Icon(
                                  _audio.enabled && _audio.available
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _breathing
                                ? l10n.anxietyBreathTitle
                                : widget.practice!.title(
                                    meditationIndonesian(context),
                                  ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _breathing
                                ? l10n.anxietyBreathSubtitle
                                : widget.practice!.description(
                                    meditationIndonesian(context),
                                  ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.palette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Spacer(),
                          if (_breathing)
                            AnimatedBuilder(
                              animation: _phaseMotion,
                              builder: (context, child) {
                                final progress =
                                    meditationReducedMotion(context)
                                    ? state.phaseProgress
                                    : _phaseMotion.value;
                                final eased = Curves.easeInOutSine.transform(
                                  progress,
                                );
                                return BreathingOrb(
                                  phase: state.phase,
                                  countdown: state.phaseCountdown,
                                  progress: progress,
                                  scale: state.phase == BreathingPhase.inhale
                                      ? .83 + .17 * eased
                                      : state.phase == BreathingPhase.exhale
                                      ? 1 - .17 * eased
                                      : .86,
                                  paused: _paused || _completed,
                                  subtext: state.phase == BreathingPhase.inhale
                                      ? l10n.inhaleGentlySubtext
                                      : state.phase == BreathingPhase.exhale
                                      ? l10n.slowExhaleSubtext
                                      : l10n.settleOutroSubtext,
                                );
                              },
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(120),
                              child: SizedBox(
                                width: 270,
                                height: 270,
                                child: MediaQuery.withClampedTextScaling(
                                  maxScaleFactor: 1.3,
                                  child: MeditationLandscape(
                                    color: _color,
                                    paused: _paused || _completed,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            meditationIcon(
                                              widget.practice!.category,
                                            ),
                                            size: 44,
                                            color: AppColors.meditationIvory,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _paused
                                                ? l10n.pauseAction
                                                : _time(remaining),
                                            style: const TextStyle(
                                              fontSize: 38,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            medText(
                                              context,
                                              'JUST BE HERE',
                                              'HADIR DI SINI',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 3,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 22),
                          if (!_breathing)
                            AnimatedSwitcher(
                              duration: meditationReducedMotion(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 600),
                              child: Text(
                                widget.practice!.guidance(
                                  _generalElapsed / _planned,
                                  meditationIndonesian(context),
                                ),
                                key: ValueKey(
                                  _generalElapsed ~/ (_planned / 6),
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  height: 1.5,
                                  color: context.palette.textSecondary,
                                ),
                              ),
                            ),
                          const Spacer(),
                          const SizedBox(height: 20),
                          if (_breathing) ...[
                            Text(
                              l10n.timeLeft(_time(remaining)),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: context.palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.secExhaleSelected(widget.exhaleSeconds),
                              style: TextStyle(
                                color: context.palette.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 1 - remaining / _planned,
                              minHeight: 3,
                              color: _color,
                              backgroundColor: _color.withValues(alpha: .12),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.graphic_eq_rounded,
                                color: _color,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              if (MediaQuery.sizeOf(context).width > 340 &&
                                  MediaQuery.textScalerOf(context).scale(1) <=
                                      1.4)
                                Text(
                                  medText(
                                    context,
                                    'Soundscape',
                                    'Musik suasana',
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              Expanded(
                                child: Slider(
                                  value: _audio.volume,
                                  onChanged: _audio.available
                                      ? (value) {
                                          _audio.setVolume(value);
                                          _preferences.setVolume(value);
                                        }
                                      : null,
                                  semanticFormatterCallback: (v) =>
                                      '${(v * 100).round()}%',
                                  activeColor: _color,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  '${(_audio.volume * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_breathing)
                                IconButton(
                                  tooltip: medText(
                                    context,
                                    'Haptic cues',
                                    'Isyarat getaran',
                                  ),
                                  isSelected: _haptics,
                                  onPressed: () =>
                                      setState(() => _haptics = !_haptics),
                                  icon: Icon(
                                    _haptics
                                        ? Icons.vibration
                                        : Icons.phonelink_erase,
                                  ),
                                ),
                            ],
                          ),
                          if (!_audio.available)
                            Text(
                              medText(
                                context,
                                'Music unavailable. You can continue in quiet.',
                                'Musik tidak tersedia. Kamu bisa melanjutkan dalam hening.',
                              ),
                              style: TextStyle(
                                color: context.palette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          if (_saveFailed) ...[
                            Text(
                              medText(
                                context,
                                'Your session could not be saved. Please retry.',
                                'Sesi belum tersimpan. Silakan coba lagi.',
                              ),
                            ),
                            FilledButton(
                              onPressed: () => _finish(
                                abandoned:
                                    _finishedSession?.status == 'abandoned',
                              ),
                              child: Text(
                                medText(
                                  context,
                                  'Retry save',
                                  'Coba simpan lagi',
                                ),
                              ),
                            ),
                          ] else
                            SizedBox(
                              width: double.infinity,
                              height:
                                  56 *
                                  MediaQuery.textScalerOf(context).scale(1),
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _color,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _saving
                                    ? null
                                    : () => _paused ? _resume() : _pause(),
                                icon: Icon(
                                  _paused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                ),
                                label: Text(
                                  _saving
                                      ? medText(
                                          context,
                                          'Saving…',
                                          'Menyimpan…',
                                        )
                                      : _paused
                                      ? l10n.resumeAction
                                      : l10n.pauseAction,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: _saving || _completed
                                ? null
                                : _confirmEndSession,
                            child: Text(l10n.endSessionAction),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
