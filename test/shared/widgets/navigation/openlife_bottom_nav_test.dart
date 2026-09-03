import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_bottom_nav.dart';

import '../../../support/app_fonts.dart';
import '../../../support/localized_app.dart';

/// The selected tab is the only one carrying a label. With four equal shares
/// it truncated to "To…" on a normal phone — an ellipsis is not an overflow,
/// so the layout tests never saw it.
void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpNav(
    WidgetTester tester, {
    required double width,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = Size(width * 3, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      localizedApp(
        // The nav uses InkWell, which needs a Material ancestor; on a real
        // screen the shell's Scaffold provides it.
        const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: OpenLifeBottomNav(currentRoute: OpenLifeRoute.today),
            ),
          ),
        ),
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectNotTruncated(WidgetTester tester, String label) {
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.text(label),
    );
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: '"$label" is ellipsised in the nav pill',
    );
  }

  testWidgets('the selected label fits on a narrow phone', (
    WidgetTester tester,
  ) async {
    await pumpNav(tester, width: 320);

    expect(find.text('Today'), findsOneWidget);
    expectNotTruncated(tester, 'Today');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the selected label fits in Indonesian too', (
    WidgetTester tester,
  ) async {
    // "Hari Ini" is longer than "Today" and is the real worst case.
    await pumpNav(tester, width: 320, locale: const Locale('id'));

    expectNotTruncated(tester, 'Hari Ini');
    expect(tester.takeException(), isNull);
  });

  testWidgets('unselected tabs are icon-only but still 44px tall', (
    WidgetTester tester,
  ) async {
    await pumpNav(tester, width: 390);

    expect(find.text('Routines'), findsNothing);
    for (final Element element in find.byType(SizedBox).evaluate()) {
      final SizedBox box = element.widget as SizedBox;
      if (box.height == 44) {
        return;
      }
    }
    fail('no 44px target found for the icon-only tabs');
  });
}
