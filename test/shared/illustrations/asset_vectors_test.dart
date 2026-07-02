import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/illustrations/asset_vectors.dart';

void main() {
  group('AssetVectors', () {
    test('all asset paths start with assets/vector/ and end with .png', () {
      for (final AssetVectorEntry entry in AssetVectors.entries) {
        expect(entry.path, startsWith('assets/vector/'),
            reason: '${entry.name} must be in assets/vector/');
        expect(entry.path, endsWith('.png'),
            reason: '${entry.name} must be a PNG');
      }
    });

    test('all asset paths are non-empty', () {
      for (final AssetVectorEntry entry in AssetVectors.entries) {
        expect(entry.path, isNotEmpty);
      }
    });

    test('contains all expected illustration names', () {
      final List<String> names =
          AssetVectors.entries.map((e) => e.name).toList();

      expect(names, contains('onboardingBuildBetterDays'));
      expect(names, contains('onboardingSmartRoutines'));
      expect(names, contains('onboardingPrivateByDefault'));
      expect(names, contains('onboardingStarterTemplate'));
      expect(names, contains('todayNotificationBell'));
      expect(names, contains('todaySleepRoutine'));
      expect(names, contains('todayWaterHydration'));
      expect(names, contains('todayVitaminRoutine'));
      expect(names, contains('todayDailyCelebration'));
      expect(names, contains('todayInsightsWorkspace'));
    });

    test('entry count matches MVP illustration set (10)', () {
      expect(AssetVectors.entries.length, 10);
    });

    test('byName returns the matching entry', () {
      final AssetVectorEntry entry =
          AssetVectors.byName('todayNotificationBell');
      expect(entry.path, 'assets/vector/today_notification_bell.png');
    });

    test('byName throws on unknown name', () {
      expect(
        () => AssetVectors.byName('notAnAsset'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
