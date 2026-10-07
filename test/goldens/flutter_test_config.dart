import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens only (this folder): real glyphs from the Roboto that ships in the Flutter SDK cache, so a change in text
/// layout shows in the images. SF Pro is not used: it is not ours to ship, and the system copy is a variable font
/// whose weights Flutter's test engine does not pick.
///
/// Two sets: macOS platform goldens (goldens/macos, real text, for people to look at; text antialiasing differs
/// between macOS versions, so they are checked on a developer's Mac, not in CI) and CI goldens (goldens/ci, text as
/// blocks and no shadows, the same on every host; CI checks these).
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
      // Skia on x86 Linux and on ARM Macs antialiases a few edge pixels differently (at most 0.02 % seen); real
      // changes are far larger
      ciGoldensConfig: const CiGoldensConfig(diffThreshold: 0.0005),
    ),
    run: testMain,
  );
}
