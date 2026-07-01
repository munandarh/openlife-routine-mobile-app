import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/app.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';

void main() {
  testWidgets('renders Today app shell by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      OpenLifeApp(dependencies: await AppDependencies.bootstrap()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Routines'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Daily Progress'), findsOneWidget);
    expect(find.text('Daily routine'), findsOneWidget);
  });
}
