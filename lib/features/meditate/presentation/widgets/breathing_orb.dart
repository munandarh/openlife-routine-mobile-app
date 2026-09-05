import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/breathing_player_cubit.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';

class BreathingOrb extends StatelessWidget {
  const BreathingOrb({
    required this.phase,
    required this.countdown,
    required this.progress,
    required this.scale,
    required this.subtext,
    this.paused = false,
    super.key,
  });
  final BreathingPhase phase;
  final int countdown;
  final double progress, scale;
  final String subtext;
  final bool paused;
  @override
  Widget build(BuildContext context) {
    final reduced = meditationReducedMotion(context);
    final label = paused
        ? medText(context, 'Paused', 'Dijeda')
        : switch (phase) {
            BreathingPhase.inhale => context.l10n.inhaleLabel,
            BreathingPhase.exhale => context.l10n.exhaleLabel,
            BreathingPhase.settle => medText(context, 'Rest', 'Istirahat'),
          };
    final size = math.min(MediaQuery.sizeOf(context).width - 48, 340.0);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: reduced ? .94 : scale,
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: ClipOval(
                    child: SizedBox.expand(
                      child: MeditationLandscape(orb: true, paused: paused),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _OrbTrackPainter(progress: progress),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      liveRegion: true,
                      label:
                          '$label, ${phase == BreathingPhase.inhale
                              ? 3
                              : phase == BreathingPhase.settle
                              ? 12
                              : medText(context, 'slowly', 'perlahan')}',
                      child: ExcludeSemantics(
                        child: Text(
                          label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w800,
                            color: AppColors.meditationOrbInk,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '$countdown',
                      style: const TextStyle(
                        fontSize: 64,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.meditationNumberInk,
                      ),
                    ),
                    Text(
                      subtext,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.meditationPromptInk,
                      ),
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
}

class _OrbTrackPainter extends CustomPainter {
  const _OrbTrackPainter({required this.progress});
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 7;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.meditationRingTrack;
    canvas.drawCircle(center, radius, paint);
    paint
      ..color = AppColors.meditationRingActive
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final angle = 2 * math.pi * progress.clamp(0, 1);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      angle,
      false,
      paint,
    );
    final dot =
        center +
        Offset(math.cos(angle - math.pi / 2), math.sin(angle - math.pi / 2)) *
            radius;
    canvas.drawCircle(dot, 7, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _OrbTrackPainter old) =>
      progress != old.progress;
}
