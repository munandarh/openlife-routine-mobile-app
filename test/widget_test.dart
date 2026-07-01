import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/app.dart';

void main() {
  testWidgets('renders Today app shell by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OpenLifeApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Routines'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sprint 0 app shell'), findsOneWidget);
  });
}
