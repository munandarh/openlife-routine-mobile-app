import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/local_database_config.dart';

class AppDependencies {
  const AppDependencies({
    required this.databaseConfig,
    required this.notificationConfig,
  });

  final LocalDatabaseConfig databaseConfig;
  final NotificationStackConfig notificationConfig;

  static Future<AppDependencies> bootstrap() async {
    return const AppDependencies(
      databaseConfig: LocalDatabaseConfig.recommended(),
      notificationConfig: NotificationStackConfig.recommended(),
    );
  }
}
