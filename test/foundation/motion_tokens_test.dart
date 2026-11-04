import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../../tool/motion_tokens.dart';

/// tool/motion.json is what sheen-web copies into tokens.json; its CI compares the two. After changing a motion value:
/// UPDATE_MOTION=1 flutter test test/foundation/motion_tokens_test.dart
void main() {
  const path = 'tool/motion.json';

  test('tool/motion.json matches SheenMotion', () {
    final current = '${const JsonEncoder.withIndent('  ').convert(motionTokens())}\n';
    if (Platform.environment['UPDATE_MOTION'] == '1') File(path).writeAsStringSync(current);
    expect(File(path).readAsStringSync(), current);
  });

  test('the settle times are the ones the springs really take', () {
    expect(SheenMotion.settleOf(SheenMotion.press), SheenMotion.pressSettle);
    expect(SheenMotion.settleOf(SheenMotion.snappy), SheenMotion.snappySettle);
  });

  test('each spring goes from 0 to 1 in linear()', () {
    final springs = motionTokens()['springs']! as Map<String, Object>;
    for (final spring in springs.values.cast<Map<String, Object>>()) {
      expect(spring['linear'], allOf(startsWith('linear(0, '), endsWith(', 1)')));
    }
  });
}
