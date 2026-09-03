import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/storage/app_database.dart'
    show AppDatabase;
import 'package:openlife_routine/features/routines/data/datasources/routine_local_data_source.dart';
import 'package:openlife_routine/features/routines/data/repositories/drift_routine_repository.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';
import 'package:openlife_routine/features/templates/domain/repositories/template_repository.dart';
import 'package:openlife_routine/features/templates/domain/usecases/apply_template_use_case.dart';

void main() {
  late AppDatabase appDatabase;
  late RoutineRepository repository;
  late ApplyTemplateUseCase applyTemplate;

  setUp(() {
    appDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRoutineRepository(RoutineLocalDataSource(appDatabase));
    applyTemplate = ApplyTemplateUseCase(
      repository: repository,
      notificationService: AppNotificationService.noop(),
    );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Future<RoutineTemplate> templateById(String id) async {
    final List<RoutineTemplate> templates = await const TemplateRepository()
        .getTemplates();
    return templates.firstWhere((RoutineTemplate t) => t.id == id);
  }

  test('creates one routine per template item', () async {
    final RoutineTemplate template = await templateById('morning');

    final int created = await applyTemplate(template);

    expect(created, template.routines.length);
    final List<Routine> routines = await repository.watchRoutines().first;
    expect(routines, hasLength(template.routines.length));
  });

  test('gives every created routine a distinct id', () async {
    final RoutineTemplate template = await templateById('hydration');

    await applyTemplate(template);

    final List<Routine> routines = await repository.watchRoutines().first;
    final Set<String> ids = routines.map((Routine r) => r.id).toSet();
    expect(ids, hasLength(routines.length));
  });

  test('copies schedule and category from the template', () async {
    final RoutineTemplate template = await templateById('vitamin');

    await applyTemplate(template);

    final List<Routine> routines = await repository.watchRoutines().first;
    final Routine first = routines.first;
    expect(first.category, RoutineCategory.vitamin);
    expect(first.reminderTime, '08:30');
    expect(first.repeatDays, <int>[1, 2, 3, 4, 5, 6, 7]);
    expect(first.isEnabled, isTrue);
  });

  test('uses the title resolver when one is supplied', () async {
    final RoutineTemplate template = await templateById('vitamin');

    await applyTemplate(
      template,
      titleResolver: (TemplateRoutineItem item) => 'ID:${item.titleKey}',
    );

    final List<Routine> routines = await repository.watchRoutines().first;
    expect(
      routines.map((Routine r) => r.title),
      containsAll(<String>['ID:vitaminD3', 'ID:bComplex']),
    );
  });

  test('falls back to the English title without a resolver', () async {
    final RoutineTemplate template = await templateById('vitamin');

    await applyTemplate(template);

    final List<Routine> routines = await repository.watchRoutines().first;
    expect(
      routines.map((Routine r) => r.title),
      containsAll(<String>['Vitamin D3', 'B Complex']),
    );
  });

  test('applying twice does not collide on ids', () async {
    final RoutineTemplate template = await templateById('sleep');

    await applyTemplate(template);
    await applyTemplate(template);

    final List<Routine> routines = await repository.watchRoutines().first;
    expect(routines, hasLength(template.routines.length * 2));
  });
}
