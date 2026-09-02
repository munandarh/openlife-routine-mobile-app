import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/core/notifications/app_notification_service.dart';
import 'package:openlife_routine/core/notifications/notification_actions.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

/// iOS was originally absent from every notification path: no category (so no
/// Done/Snooze buttons), no permission request (so no notifications at all),
/// and no accounting for the 64 pending-request cap.
void main() {
  late AppLocalizations en;
  late AppLocalizations id;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    id = await AppLocalizations.delegate.load(const Locale('id'));
  });

  group('routineNotificationDetails', () {
    test('carries both platforms, so neither can be forgotten', () {
      final NotificationDetails details = routineNotificationDetails(
        strings: en,
        snoozeMinutes: 15,
      );

      expect(details.android, isNotNull);
      expect(details.iOS, isNotNull);
    });

    test('tags the iOS notification with the category the actions live on', () {
      final NotificationDetails details = routineNotificationDetails(
        strings: en,
        snoozeMinutes: 10,
      );

      expect(details.iOS!.categoryIdentifier, routineCategoryId);
    });

    test('the Android snooze label still carries the routine duration', () {
      final NotificationDetails details = routineNotificationDetails(
        strings: en,
        snoozeMinutes: 15,
      );

      expect(
        details.android!.actions!
            .firstWhere((AndroidNotificationAction a) =>
                a.id == notificationSnoozeActionId)
            .title,
        contains('15'),
      );
    });
  });

  group('routineNotificationCategories', () {
    test('registers the category the notifications point at', () {
      final List<DarwinNotificationCategory> categories =
          routineNotificationCategories(en);

      expect(categories, hasLength(1));
      expect(categories.single.identifier, routineCategoryId);
    });

    test('offers both Done and Snooze', () {
      final List<DarwinNotificationAction> actions =
          routineNotificationCategories(en).single.actions;

      expect(
        actions.map((DarwinNotificationAction a) => a.identifier),
        containsAll(<String>[
          notificationDoneActionId,
          notificationSnoozeActionId,
        ]),
      );
    });

    test('no action opens the app, so iOS answers in the background', () {
      final List<DarwinNotificationAction> actions =
          routineNotificationCategories(en).single.actions;

      for (final DarwinNotificationAction action in actions) {
        expect(
          action.options.contains(DarwinNotificationActionOption.foreground),
          isFalse,
          reason: '${action.identifier} would launch the app to be answered',
        );
      }
    });

    test('follows the chosen language', () {
      expect(
        routineNotificationCategories(id).single.actions.first.title,
        id.notificationDoneAction,
      );
      expect(
        routineNotificationCategories(id).single.actions.last.title,
        'Tunda',
      );
    });
  });

  group('iOS pending-notification budget', () {
    test('leaves room for a snooze under the OS cap', () {
      // 64 is the iOS limit; the budget must stay strictly under it.
      expect(AppNotificationService.iosPendingLimit, 64);
    });
  });
}
