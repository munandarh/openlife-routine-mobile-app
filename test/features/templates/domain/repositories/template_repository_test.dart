import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';
import 'package:openlife_routine/features/templates/domain/repositories/template_repository.dart';

void main() {
  group('TemplateRepository seed data', () {
    late TemplateRepository repository;

    setUp(() {
      repository = TemplateRepository();
    });

    test('getTemplates returns 5 seed templates', () async {
      final List<RoutineTemplate> templates = await repository.getTemplates();
      expect(templates.length, 5);
    });

    test('seed templates have all required fields', () async {
      final List<RoutineTemplate> templates = await repository.getTemplates();

      for (final RoutineTemplate template in templates) {
        expect(template.id, isNotEmpty);
        expect(template.title, isNotEmpty);
        expect(template.description, isNotEmpty);
        expect(template.iconKey, isNotEmpty);
        expect(template.categoryName, isNotEmpty);
        expect(template.routineCount, greaterThan(0));
      }
    });

    test('Morning Routine is the primary template', () async {
      final List<RoutineTemplate> templates = await repository.getTemplates();
      final RoutineTemplate morning = templates.firstWhere(
        (t) => t.id == 'morning',
      );
      expect(morning.isPrimary, true);
    });

    test('each template has correct routine items', () async {
      final List<RoutineTemplate> templates = await repository.getTemplates();

      final RoutineTemplate morning = templates.firstWhere(
        (t) => t.id == 'morning',
      );
      expect(morning.routines.length, 3);
      expect(morning.routines[0].title, 'Wake Up');
      expect(morning.routines[0].reminderTime, '06:30');

      final RoutineTemplate hydration = templates.firstWhere(
        (t) => t.id == 'hydration',
      );
      expect(hydration.routines.length, greaterThanOrEqualTo(1));
      expect(hydration.routines.any((r) => r.category == 'water'), true);

      final RoutineTemplate vitamin = templates.firstWhere(
        (t) => t.id == 'vitamin',
      );
      expect(vitamin.routines.any((r) => r.category == 'vitamin'), true);

      final RoutineTemplate sleep = templates.firstWhere(
        (t) => t.id == 'sleep',
      );
      expect(sleep.routines.any((r) => r.category == 'sleep'), true);

      final RoutineTemplate programmer = templates.firstWhere(
        (t) => t.id == 'programmer_break',
      );
      expect(
        programmer.routines.any((r) => r.category == 'breakTime'),
        true,
      );
    });

    test('no template makes medical claims', () async {
      final List<RoutineTemplate> templates = await repository.getTemplates();

      for (final RoutineTemplate template in templates) {
        final String combined =
            '${template.title} ${template.description}';
        expect(combined.contains('cure'), false,
            reason: '${template.id} must not claim to cure');
        expect(combined.contains('treat'), false,
            reason: '${template.id} must not claim to treat');
        expect(combined.contains('diagnose'), false,
            reason: '${template.id} must not claim to diagnose');
        expect(combined.contains('medical'), false,
            reason: '${template.id} must not claim medical');
      }
    });
  });
}
