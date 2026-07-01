class NotificationStackConfig {
  const NotificationStackConfig.recommended()
    : plugin = 'flutter_local_notifications',
      timezonePackage = 'timezone',
      notes =
          'ponytail: lock notification stack now; actual scheduler arrives in Sprint 5.';

  const NotificationStackConfig({
    required this.plugin,
    required this.timezonePackage,
    required this.notes,
  });

  final String plugin;
  final String timezonePackage;
  final String notes;
}
