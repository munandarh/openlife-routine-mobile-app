import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/app.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/notifications/notification_stack_config.dart';
import 'package:openlife_routine/core/storage/local_database_config.dart';
import 'package:openlife_routine/features/onboarding/domain/repositories/onboarding_repository.dart';

void main() {
  testWidgets('first launch shows onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      OpenLifeApp(
        dependencies: AppDependencies(
          databaseConfig: const LocalDatabaseConfig.recommended(),
          notificationConfig: const NotificationStackConfig.recommended(),
          onboardingRepository: _FakeOnboardingRepository(),
          hasCompletedOnboarding: false,
          preferredLanguageCode: 'en',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('OpenLife Routine'), findsOneWidget);
    expect(find.text('Build better days'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('returning user opens Today shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      OpenLifeApp(
        dependencies: AppDependencies(
          databaseConfig: const LocalDatabaseConfig.recommended(),
          notificationConfig: const NotificationStackConfig.recommended(),
          onboardingRepository: _FakeOnboardingRepository(),
          hasCompletedOnboarding: true,
          preferredLanguageCode: 'en',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily Progress'), findsOneWidget);
    expect(find.text('Daily routine'), findsOneWidget);
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<String> getPreferredLanguageCode() async => 'en';

  @override
  Future<bool> hasCompletedOnboarding() async => false;

  @override
  Future<void> setPreferredLanguageCode(String languageCode) async {}

  @override
  Future<void> skipOnboarding() async {}
}
