import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/services/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticService', () {
    late HapticService service;

    setUp(() {
      service = HapticService();
    });

    test('lightImpact calls HapticFeedback.lightImpact', () {
      final List<String> calls = <String>[];
      service = HapticService(lightImpactFn: () => calls.add('lightImpact'));

      service.lightImpact();
      expect(calls, contains('lightImpact'));
    });

    test('mediumImpact calls HapticFeedback.mediumImpact', () {
      final List<String> calls = <String>[];
      service = HapticService(mediumImpactFn: () => calls.add('mediumImpact'));

      service.mediumImpact();
      expect(calls, contains('mediumImpact'));
    });

    test('selectionClick calls HapticFeedback.selectionClick', () {
      final List<String> calls = <String>[];
      service = HapticService(
        selectionClickFn: () => calls.add('selectionClick'),
      );

      service.selectionClick();
      expect(calls, contains('selectionClick'));
    });

    test('default constructor uses real HapticFeedback', () {
      // Should not throw — verifies the real HapticFeedback can be invoked
      // in test environment (it's a no-op in tests).
      final HapticService real = HapticService();
      expect(() => real.lightImpact(), returnsNormally);
      expect(() => real.mediumImpact(), returnsNormally);
      expect(() => real.selectionClick(), returnsNormally);
    });
  });
}
