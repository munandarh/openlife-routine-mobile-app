import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Nunito faces into the test binding.
///
/// Without this, `flutter_test` measures every glyph as a 1em square, so any
/// assertion about whether text fits is answered against a font the app does
/// not ship — far wider than Nunito, and wrong in both directions.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FontLoader loader = FontLoader('Nunito');
  for (final String weight in <String>[
    'Regular',
    'SemiBold',
    'Bold',
    'ExtraBold',
  ]) {
    final File file = File('assets/fonts/Nunito-$weight.ttf');
    loader.addFont(
      file.readAsBytes().then((Uint8List bytes) => ByteData.view(bytes.buffer)),
    );
  }
  await loader.load();
}
