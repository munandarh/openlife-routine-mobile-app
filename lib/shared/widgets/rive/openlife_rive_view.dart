import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

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
    this.expand = false,
    this.onInit,
    super.key,
  });

  /// Wrap a `.riv` Rive animation. While the file loads — and if it fails to
  /// load at all — the [fallbackIcon] is shown, so a missing or corrupt asset
  /// degrades instead of throwing.
  ///
  /// No `.riv` files ship in the repository yet; see
  /// `docs/animation-guidelines.md` §4.
  factory OpenLifeRiveView.asset({
    Key? key,
    required String assetName,
    required IconData fallbackIcon,
    String? artboard,
    String? stateMachine,
    BoxFit fit = BoxFit.contain,
    double size = 120,
    void Function(rive.RiveWidgetController)? onInit,
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

  /// Wrap a static PNG illustration that expands to fill its parent instead
  /// of sitting in a fixed square box. Use this for hero areas where the
  /// artwork should bleed all the way to the container edges.
  factory OpenLifeRiveView.illustrationFill({
    Key? key,
    required String illustrationPath,
    required IconData fallbackIcon,
    BoxFit fit = BoxFit.cover,
  }) {
    return OpenLifeRiveView._(
      key: key,
      illustrationPath: illustrationPath,
      fallbackIcon: fallbackIcon,
      fit: fit,
      expand: true,
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

  /// Width and height of the viewport. Ignored when [expand] is true.
  final double size;

  /// When true the illustration fills the parent's constraints instead of
  /// being laid out in a [size] × [size] box.
  final bool expand;

  /// Called once the Rive controller is ready.
  final void Function(rive.RiveWidgetController)? onInit;

  @override
  State<OpenLifeRiveView> createState() => _OpenLifeRiveViewState();
}

class _OpenLifeRiveViewState extends State<OpenLifeRiveView> {
  /// Icon size used when an expanding illustration cannot be loaded.
  static const double _expandFallbackSize = 96;

  bool _imageFailed = false;
  rive.FileLoader? _fileLoader;

  @override
  void initState() {
    super.initState();
    _createFileLoader();
  }

  @override
  void didUpdateWidget(OpenLifeRiveView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.illustrationPath != widget.illustrationPath) {
      _imageFailed = false;
    }
    if (oldWidget.assetName != widget.assetName) {
      _createFileLoader();
    }
  }

  void _createFileLoader() {
    final String? assetName = widget.assetName;
    if (assetName == null) {
      _fileLoader = null;
      return;
    }

    try {
      _fileLoader = rive.FileLoader.fromAsset(
        assetName,
        riveFactory: rive.Factory.flutter,
      );
    } on Object catch (error) {
      // `Factory.flutter` resolves a symbol in the rive_native dynamic
      // library. That library is absent under `flutter test` and can fail to
      // load on an unsupported platform; either way the icon fallback is a
      // better outcome than tearing down the screen.
      debugPrint('Rive unavailable, falling back to icon: $error');
      _fileLoader = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // PNG illustration path — try to load, fall back to icon on error.
    if (widget.illustrationPath != null) {
      final Widget fallback = widget.expand
          ? Center(child: Icon(widget.fallbackIcon, size: _expandFallbackSize))
          : Icon(widget.fallbackIcon, size: widget.size * 0.6);

      final Widget content = _imageFailed
          ? fallback
          : Image.asset(
              widget.illustrationPath!,
              fit: widget.fit,
              width: widget.expand ? double.infinity : null,
              height: widget.expand ? double.infinity : null,
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
                return fallback;
              },
            );

      if (widget.expand) {
        return content;
      }

      return SizedBox(width: widget.size, height: widget.size, child: content);
    }

    final rive.FileLoader? fileLoader = _fileLoader;
    if (fileLoader == null) {
      return _buildFallback();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: rive.RiveWidgetBuilder(
        fileLoader: fileLoader,
        artboardSelector: widget.artboard == null
            ? const rive.ArtboardDefault()
            : rive.ArtboardSelector.byName(widget.artboard!),
        stateMachineSelector: widget.stateMachine == null
            ? const rive.StateMachineDefault()
            : rive.StateMachineSelector.byName(widget.stateMachine!),
        onLoaded: (rive.RiveLoaded loaded) =>
            widget.onInit?.call(loaded.controller),
        builder: (BuildContext context, rive.RiveState state) {
          return switch (state) {
            // A missing or corrupt .riv must not take the screen down with
            // it — the icon is the same fallback the PNG path uses.
            rive.RiveLoading() || rive.RiveFailed() => _buildFallback(),
            rive.RiveLoaded() => rive.RiveWidget(
              controller: state.controller,
              fit: _riveFit(widget.fit),
            ),
          };
        },
      ),
    );
  }

  /// Maps the Flutter [BoxFit] callers already pass to Rive's own fit enum.
  static rive.Fit _riveFit(BoxFit fit) {
    return switch (fit) {
      BoxFit.fill => rive.Fit.fill,
      BoxFit.cover => rive.Fit.cover,
      BoxFit.fitWidth => rive.Fit.fitWidth,
      BoxFit.fitHeight => rive.Fit.fitHeight,
      BoxFit.scaleDown => rive.Fit.scaleDown,
      BoxFit.none => rive.Fit.none,
      BoxFit.contain => rive.Fit.contain,
    };
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
