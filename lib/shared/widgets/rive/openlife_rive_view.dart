import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// A wrapper around [RiveAnimation.asset] that gracefully falls back to
/// a static [Icon] when the Rive asset cannot be loaded.
///
/// While `.riv` files are not yet bundled in the project, this widget
/// always renders the [fallbackIcon]. When assets are added, remove the
/// early fallback guard in [build] to enable Rive rendering.
class OpenLifeRiveView extends StatefulWidget {
  const OpenLifeRiveView({
    required this.assetName,
    required this.fallbackIcon,
    this.artboard,
    this.stateMachine,
    this.fit = BoxFit.contain,
    this.size = 120,
    this.onInit,
    super.key,
  });

  /// Path to the `.riv` asset (e.g. `assets/rive/empty_no_routines.riv`).
  final String assetName;

  /// Icon shown when the Rive asset is missing or fails to load.
  final IconData fallbackIcon;

  /// Optional artboard name inside the Rive file.
  final String? artboard;

  /// Optional state machine name.
  final String? stateMachine;

  /// How the Rive artboard or fallback icon fits within the bounds.
  final BoxFit fit;

  /// Width and height of the viewport.
  final double size;

  /// Called when the Rive [Artboard] is initialized.
  final void Function(Artboard)? onInit;

  @override
  State<OpenLifeRiveView> createState() => _OpenLifeRiveViewState();
}

class _OpenLifeRiveViewState extends State<OpenLifeRiveView> {
  final bool _showFallback = true;

  @override
  Widget build(BuildContext context) {
    // TODO(openlife): Remove `_showFallback` early-return when .riv files
    // are bundled. RiveAnimation.asset will handle loading then.
    if (_showFallback) {
      return _buildFallback();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        widget.assetName,
        artboard: widget.artboard,
        stateMachines: widget.stateMachine != null
            ? <String>[widget.stateMachine!]
            : const <String>[],
        fit: widget.fit,
        onInit: widget.onInit,
      ),
    );
  }

  Widget _buildFallback() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Icon(widget.fallbackIcon, size: widget.size * 0.6),
    );
  }
}

/// A predictable stateless fallback for use when Rive assets are not
/// bundled yet.
class OpenLifeRiveFallback extends StatelessWidget {
  const OpenLifeRiveFallback({
    required this.icon,
    this.size = 120,
    this.color,
    super.key,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(icon, size: size * 0.6, color: color),
    );
  }
}
