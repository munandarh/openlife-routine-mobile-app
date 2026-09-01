import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/features/routines/domain/entities/routine.dart';
import 'package:openlife_routine/features/routines/domain/repositories/routine_repository.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';

/// Materialises a [RoutineTemplate] into real routines and schedules their
/// reminders.
///
/// Both the Templates screen and the onboarding starter step go through this so
/// a template is applied the same way in either place, and so neither has to
/// spin up a throwaway BLoC to fire N create events.
class ApplyTemplateUseCase {
  const ApplyTemplateUseCase({
    required RoutineRepository repository,
    required AppNotificationService notificationService,
  }) : _repository = repository,
       _notificationService = notificationService;

  final RoutineRepository _repository;
  final AppNotificationService _notificationService;

  /// Creates every routine in [template] and returns how many were created.
  ///
  /// [titleResolver] supplies the localized name for each item; pass null to
  /// keep the template's English fallback.
  Future<int> call(
    RoutineTemplate template, {
    String Function(TemplateRoutineItem item)? titleResolver,
  }) async {
    final DateTime now = DateTime.now();
    int created = 0;

    for (final TemplateRoutineItem item in template.routines) {
      final RoutineCategory category = RoutineCategory.values.firstWhere(
        (RoutineCategory c) => c.name == item.category,
        orElse: () => RoutineCategory.custom,
      );

      // Ids are derived from the clock, so the loop index keeps a multi-routine
      // template from colliding with itself within the same microsecond.
      final Routine routine = Routine(
        id: '${now.microsecondsSinceEpoch}-${template.id}-$created',
        title: titleResolver?.call(item) ?? item.title,
        category: category,
        reminderTime: item.reminderTime,
        repeatDays: item.repeatDays,
        isEnabled: true,
        snoozeMinutes: item.snoozeMinutes,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.createRoutine(routine);
      await _notificationService.scheduleRoutine(routine);
      created += 1;
    }

    return created;
  }
}
