import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens only (this folder): real glyphs from the Roboto that ships in the Flutter SDK cache, so a change in text
/// layout shows in the images. SF Pro is not used: it is not ours to ship, and the system copy is a variable font
/// whose weights Flutter's test engine does not pick. Images are macOS platform goldens; no obscured CI set.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('FLUTTER_ROOT is not set; run the goldens with `flutter test`.');
  final loader = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('$root/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Roboto'),
      platformGoldensConfig: PlatformGoldensConfig(platforms: {HostPlatform.macOS}),
      ciGoldensConfig: const CiGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
