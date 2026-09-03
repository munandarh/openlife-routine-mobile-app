import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';

/// A bundled PNG illustration, with an icon to fall back on.
///
/// This replaced a Rive-backed widget. Rive shipped a 7.7 MB native library
/// per ABI — 23 MB of the universal APK — and rendered nothing: no `.riv` file
/// was ever bundled, so every call site already fell through to the PNG path
/// this widget now is.
///
/// The fallback is not decoration: an asset can fail to decode on a low-memory
/// device, and a missing illustration should leave a small icon rather than a
/// hole where the empty state's explanation used to be.
class AppIllustration extends StatelessWidget {
  /// Sized square, for empty states and onboarding heroes.
  const AppIllustration({
    required this.assetPath,
    required this.fallbackIcon,
    this.size = 140,
    super.key,
  }) : _fills = false;

  /// Fills its parent, cropping to cover — for the onboarding hero card.
  const AppIllustration.fill({
    required this.assetPath,
    required this.fallbackIcon,
    super.key,
  }) : size = null,
       _fills = true;

  final String assetPath;
  final IconData fallbackIcon;
  final double? size;
  final bool _fills;

  @override
  Widget build(BuildContext context) {
    if (_fills) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            _Fallback(icon: fallbackIcon, size: 96),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            _Fallback(icon: fallbackIcon, size: size ?? 140),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size * 0.45,
        height: size * 0.45,
        decoration: BoxDecoration(
          color: context.palette.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        ),
        child: Icon(icon, size: size * 0.22, color: context.palette.primaryInk),
      ),
    );
  }
}
