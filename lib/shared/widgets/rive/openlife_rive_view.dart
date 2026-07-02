import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image;

/// A widget that renders illustrations in the app using one of three layers,
/// in priority order:
///
/// 1. **Rive** — interactive vector animation loaded from a `.riv` asset.
/// 2. **PNG illustration** — static vector illustration loaded from
///    `assets/vector/...png` (see `AssetVectors`).
/// 3. **Icon fallback** — used when neither asset is available.
///
/// Two named constructors are exposed:
/// - [OpenLifeRiveView.asset] (default) — for `.riv` animations.
/// - [OpenLifeRiveView.illustration] — for static PNG illustrations.
class OpenLifeRiveView extends StatefulWidget {
  const OpenLifeRiveView._({
    this.assetName,
    this.illustrationPath,
    required this.fallbackIcon,
    this.artboard,
    this.stateMachine,
    this.fit = BoxFit.contain,
    this.size = 120,
    this.onInit,
    super.key,
  });

  /// Wrap a `.riv` Rive animation. If the asset is missing, the
  /// [fallbackIcon] is shown.
  ///
  /// While `.riv` files are not yet bundled in the project, this widget
  /// always renders the [fallbackIcon]. When assets are added, remove the
  /// early fallback guard in [build] to enable Rive rendering.
  factory OpenLifeRiveView.asset({
    Key? key,
    required String assetName,
    required IconData fallbackIcon,
    String? artboard,
    String? stateMachine,
    BoxFit fit = BoxFit.contain,
    double size = 120,
    void Function(Artboard)? onInit,
  }) {
    return OpenLifeRiveView._(
      key: key,
      assetName: assetName,
      fallbackIcon: fallbackIcon,
      artboard: artboard,
      stateMachine: stateMachine,
      fit: fit,
      size: size,
      onInit: onInit,
    );
  }

  /// Wrap a static PNG illustration. If the file is missing or fails to
  /// load, the [fallbackIcon] is shown.
  factory OpenLifeRiveView.illustration({
    Key? key,
    required String illustrationPath,
    required IconData fallbackIcon,
    BoxFit fit = BoxFit.contain,
    double size = 120,
  }) {
    return OpenLifeRiveView._(
      key: key,
      illustrationPath: illustrationPath,
      fallbackIcon: fallbackIcon,
      fit: fit,
      size: size,
    );
  }

  /// Path to the `.riv` asset (e.g. `assets/rive/empty_no_routines.riv`).
  final String? assetName;

  /// Path to a PNG illustration under `assets/vector/`.
  final String? illustrationPath;

  /// Icon shown when neither Rive asset nor PNG illustration can render.
  final IconData fallbackIcon;

  /// Optional artboard name inside the Rive file.
  final String? artboard;

  /// Optional state machine name.
  final String? stateMachine;

  /// How the asset fits within the bounds.
  final BoxFit fit;

  /// Width and height of the viewport.
  final double size;

  /// Called when the Rive [Artboard] is initialized.
  final void Function(Artboard)? onInit;

  @override
  State<OpenLifeRiveView> createState() => _OpenLifeRiveViewState();
}

class _OpenLifeRiveViewState extends State<OpenLifeRiveView> {
  static const bool _showFallback = true;
  bool _imageFailed = false;

  @override
  void didUpdateWidget(OpenLifeRiveView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.illustrationPath != widget.illustrationPath) {
      _imageFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // PNG illustration path — try to load, fall back to icon on error.
    if (widget.illustrationPath != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: _imageFailed
            ? Icon(widget.fallbackIcon, size: widget.size * 0.6)
            : Image.asset(
                widget.illustrationPath!,
                fit: widget.fit,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _imageFailed = true);
                    }
                  });
                  return Icon(
                    widget.fallbackIcon,
                    size: widget.size * 0.6,
                  );
                },
              ),
      );
    }

    // TODO(openlife): Remove `_showFallback` early-return when .riv files
    // are bundled. RiveAnimation.asset will handle loading then.
    if (_showFallback) {
      return _buildFallback();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        widget.assetName!,
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
