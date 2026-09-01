/// Build-time constants about the app itself.
///
/// [version] is asserted against `pubspec.yaml` by a unit test so the About
/// screen cannot drift away from the shipped build.
final class AppInfo {
  const AppInfo._();

  static const String version = '1.1.0';
  static const String repositoryUrl =
      'https://github.com/munandarh/openlife-routine-mobile-app';
}
