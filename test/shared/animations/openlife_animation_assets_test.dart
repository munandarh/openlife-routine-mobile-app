import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/animations/openlife_animation_assets.dart';

void main() {
  group('OpenLifeAnimationAssets', () {
    test('all rive asset paths are non-empty strings', () {
      for (final OpenLifeAnimationEntry entry
          in OpenLifeAnimationAssets.entries) {
        expect(
          entry.rivePath,
          isNotEmpty,
          reason: '${entry.name} rivePath must not be empty',
        );
      }
    });

    test('all entries have valid fallback IconData', () {
      for (final OpenLifeAnimationEntry entry
          in OpenLifeAnimationAssets.entries) {
        expect(
          entry.fallbackIcon,
          isA<IconData>(),
          reason: '${entry.name} fallback must be IconData',
        );
      }
    });

    test('contains all expected animation types', () {
      final List<String> names = OpenLifeAnimationAssets.entries
          .map((e) => e.name)
          .toList();

      expect(names, contains('onboardingBuildBetterDays'));
      expect(names, contains('onboardingPrivateByDefault'));
      expect(names, contains('emptyNoRoutines'));
      expect(names, contains('routineDoneCheck'));
      expect(names, contains('dailyCompleteCelebration'));
      expect(names, contains('reminderActiveBell'));
    });

    test('onboardingBuildBetterDays has correct fallback', () {
      final OpenLifeAnimationEntry entry = OpenLifeAnimationAssets.byName(
        'onboardingBuildBetterDays',
      );
      expect(entry.rivePath, 'assets/rive/onboarding_build_better_days.riv');
      expect(entry.fallbackIcon, Icons.checklist_rtl_outlined);
    });

    test('emptyNoRoutines has correct fallback', () {
      final OpenLifeAnimationEntry entry = OpenLifeAnimationAssets.byName(
        'emptyNoRoutines',
      );
      expect(entry.rivePath, 'assets/rive/empty_no_routines.riv');
      expect(entry.fallbackIcon, Icons.event_note_outlined);
    });

    test('byName throws on unknown name', () {
      expect(
        () => OpenLifeAnimationAssets.byName('nonExistent'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
