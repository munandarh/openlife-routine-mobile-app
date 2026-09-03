import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';

import '../../../support/app_fonts.dart';
import '../../../support/localized_app.dart';

/// The header drifted twice: two widgets with different insets (20 vs 24), and
/// five screens that nested it inside a list which already had 24px of padding,
/// so those headers sat 48px in and a row lower than the rest.
///
/// These pin the two things that made it visible: where the first button
/// starts, and how tall the row is.
void main() {
  setUpAll(loadAppFonts);

  Future<Rect> headerRect(
    WidgetTester tester,
    Widget header, {
    Locale locale = const Locale('en'),
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width * 3, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      localizedApp(
        Scaffold(body: Column(children: <Widget>[header])),
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();

    // The first circular button on the row, whichever shape is in use.
    return tester.getRect(find.byType(InkWell).first);
  }

  testWidgets('both shapes start their first button at the same inset', (
    WidgetTester tester,
  ) async {
    final Rect tab = await headerRect(tester, const OpenLifeAppBar.tab());
    await tester.pumpWidget(const SizedBox.shrink());
    final Rect page = await headerRect(
      tester,
      const OpenLifeAppBar.page(title: 'Detail'),
    );

    expect(tab.left, OpenLifeAppBar.horizontalInset);
    expect(page.left, OpenLifeAppBar.horizontalInset);
    expect(tab.top, page.top);
  });

  testWidgets('both shapes are the same height', (WidgetTester tester) async {
    await headerRect(tester, const OpenLifeAppBar.tab());
    final double tabHeight = tester.getSize(find.byType(OpenLifeAppBar)).height;

    await tester.pumpWidget(const SizedBox.shrink());
    await headerRect(tester, const OpenLifeAppBar.page(title: 'Detail'));
    final double pageHeight = tester
        .getSize(find.byType(OpenLifeAppBar))
        .height;

    expect(tabHeight, pageHeight);
  });

  testWidgets('the tab shape survives the longest label at 320dp', (
    WidgetTester tester,
  ) async {
    await headerRect(
      tester,
      OpenLifeAppBar.tab(onAddRoutine: () {}),
      locale: const Locale('id'),
      width: 320,
    );

    expect(tester.takeException(), isNull);
    // The circular buttons keep their full target; only the pill gives way.
    for (final Element element in find.byType(SizedBox).evaluate()) {
      final SizedBox box = element.widget as SizedBox;
      if (box.width == OpenLifeAppBar.buttonSize) {
        expect(box.height, OpenLifeAppBar.buttonSize);
      }
    }
  });
}
