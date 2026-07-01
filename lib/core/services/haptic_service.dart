import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] so that haptic calls can be
/// injected during tests.
class HapticService {
  HapticService({
    VoidCallback? lightImpactFn,
    VoidCallback? mediumImpactFn,
    VoidCallback? selectionClickFn,
  }) : _lightImpactFn = lightImpactFn ?? HapticFeedback.lightImpact,
       _mediumImpactFn = mediumImpactFn ?? HapticFeedback.mediumImpact,
       _selectionClickFn = selectionClickFn ?? HapticFeedback.selectionClick;

  final VoidCallback _lightImpactFn;
  final VoidCallback _mediumImpactFn;
  final VoidCallback _selectionClickFn;

  /// A light collision — good for marking a routine done.
  void lightImpact() => _lightImpactFn();

  /// A medium collision — good for daily-complete celebration.
  void mediumImpact() => _mediumImpactFn();

  /// A click — good for picker / selector taps.
  void selectionClick() => _selectionClickFn();
}
