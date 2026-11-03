import 'package:flutter/services.dart';

/// Loads the bundled Inter font so layout tests measure real glyphs instead
/// of the default test font.
Future<void> loadInterFont() async {
  final loader = FontLoader('Inter');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/inter/Inter-$weight.ttf'));
  }
  await loader.load();
}
