import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';

bool meditationReducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    MediaQuery.accessibleNavigationOf(context) ||
    (context.watch<SettingsBloc?>()?.state.reducedMotion ?? false);
bool meditationIndonesian(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id';
String medText(BuildContext context, String en, String id) =>
    meditationIndonesian(context) ? id : en;
Color meditationColor(String category) => switch (category) {
  'focus' => AppColors.meditationFocus,
  'reset' => AppColors.meditationReset,
  'sleep' => AppColors.meditationSleep,
  'stress' => AppColors.meditationStress,
  'breathe' => AppColors.meditationBreathe,
  _ => AppColors.meditationCalm,
};
IconData meditationIcon(String category) => switch (category) {
  'focus' => Icons.filter_center_focus_rounded,
  'reset' => Icons.wb_sunny_outlined,
  'sleep' => Icons.nights_stay_outlined,
  'stress' => Icons.favorite_border_rounded,
  'breathe' => Icons.air_rounded,
  _ => Icons.spa_outlined,
};

/// A single slow clock drives scenery; repaint boundaries contain per-frame work.
class MeditationLandscape extends StatefulWidget {
  const MeditationLandscape({
    super.key,
    this.color = AppColors.meditationCalm,
    this.paused = false,
    this.child,
    this.orb = false,
  });
  final Color color;
  final bool paused, orb;
  final Widget? child;
  @override
  State<MeditationLandscape> createState() => _MeditationLandscapeState();
}

class _MeditationLandscapeState extends State<MeditationLandscape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );
  void _sync() {
    if (meditationReducedMotion(context) ||
        widget.paused ||
        !TickerMode.valuesOf(context).enabled) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant MeditationLandscape oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: CustomPaint(
              painter: MeditationLandscapePainter(
                _clock,
                widget.color,
                widget.orb,
              ),
            ),
          ),
        ),
        ?widget.child,
      ],
    ),
  );
}

class MeditationLandscapePainter extends CustomPainter {
  MeditationLandscapePainter(this.clock, this.color, this.orb)
    : super(repaint: clock);
  final Animation<double> clock;
  final Color color;
  final bool orb;
  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value * 2 * math.pi;
    final paint = Paint();
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: orb
          ? [
              AppColors.meditationOrbHighlight,
              Color.lerp(color, Colors.white, .58)!,
              color.withValues(alpha: .6),
            ]
          : [color, Color.lerp(color, AppColors.meditationNight, .55)!],
    ).createShader(sky);
    canvas.drawRect(sky, paint);
    paint.shader = null;
    final sun = Offset(
      size.width * .79 + math.sin(t) * 4,
      size.height * .25 + math.cos(t) * 5,
    );
    paint.color = AppColors.meditationGlow.withValues(alpha: .06);
    for (var i = 3; i > 0; i--) {
      canvas.drawCircle(sun, size.shortestSide * (.09 + .025 * i), paint);
    }
    paint.color = AppColors.meditationSun.withValues(alpha: orb ? .45 : .95);
    canvas.drawCircle(sun, size.shortestSide * .09, paint);
    for (var layer = 0; layer < 4; layer++) {
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width + 4; x += 4) {
        final y =
            size.height * (.59 + layer * .1) +
            math.sin(x / size.width * math.pi * 2 + t + layer * 1.6) *
                size.height *
                (.055 + layer * .006);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      paint.color = Color.lerp(
        color,
        layer.isEven ? Colors.white : AppColors.meditationHillShadow,
        .22,
      )!.withValues(alpha: .2 + layer * .09);
      canvas.drawPath(path, paint);
    }
    for (var i = 0; i < 13; i++) {
      final x = ((i * .173 + .035 * math.sin(t + i)) % 1) * size.width;
      final y =
          size.height * (.13 + (i * .137 % .62)) + math.cos(t + i * .8) * 8;
      paint.color = Colors.white.withValues(
        alpha: .12 + .12 * (1 + math.sin(t + i)) / 2,
      );
      canvas.drawCircle(Offset(x, y), i.isEven ? 1.6 : .9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MeditationLandscapePainter old) =>
      color != old.color || orb != old.orb || clock != old.clock;
}

class MeditationEntrance extends StatelessWidget {
  const MeditationEntrance({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (meditationReducedMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

class BreathingPacePreview extends StatefulWidget {
  const BreathingPacePreview({required this.exhaleSeconds, super.key});
  final int exhaleSeconds;
  @override
  State<BreathingPacePreview> createState() => _BreathingPacePreviewState();
}

class _BreathingPacePreviewState extends State<BreathingPacePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: Duration(seconds: 3 + widget.exhaleSeconds),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (meditationReducedMotion(context)) {
      _clock.stop();
    } else {
      _clock.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BreathingPacePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exhaleSeconds != widget.exhaleSeconds) {
      _clock.duration = Duration(seconds: 3 + widget.exhaleSeconds);
      if (!meditationReducedMotion(context)) _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: MeditationLandscape(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 65,
              height: 65,
              child: AnimatedBuilder(
                animation: _clock,
                builder: (context, child) {
                  final seconds = _clock.value * (3 + widget.exhaleSeconds);
                  final expanded = seconds < 3
                      ? seconds / 3
                      : 1 - (seconds - 3) / widget.exhaleSeconds;
                  return Center(
                    child: Transform.scale(
                      scale:
                          .65 +
                          .35 *
                              Curves.easeInOutSine.transform(
                                expanded.clamp(0, 1),
                              ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.meditationPreviewGlow.withValues(
                            alpha: .7,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.air_rounded,
                            color: AppColors.meditationOrbInk,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medText(
                      context,
                      'A preview of your rhythm',
                      'Pratinjau ritme napasmu',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    medText(
                      context,
                      '3 sec in · ${widget.exhaleSeconds} sec out',
                      'Tarik 3 dtk · Hembus ${widget.exhaleSeconds} dtk',
                    ),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
