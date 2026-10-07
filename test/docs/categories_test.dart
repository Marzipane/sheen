// Every public type and function of the library is filed under a dartdoc category, so the API docs group it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _decl = RegExp(
  r'^(?:abstract |final |sealed |base )*(?:class|enum|mixin|extension|typedef) (\w+)|^(?:Future|Widget|void|String|bool|double|int|List|Map|Color)\S* (\w+)(?:<[^>]*>)?\(',
);

void main() {
  test('every public declaration has a {@category}', () {
    final missing = <String>[];
    for (final f in Directory(
      'lib/src',
    ).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      if (f.path.endsWith('material_bridge.dart') || f.path.contains('/icons/icon_data.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final m = _decl.firstMatch(lines[i]);
        if (m == null || lines[i].startsWith(' ') || lines[i].startsWith('//') || lines[i].startsWith('import')) {
          continue;
        }
        final name = m.group(1) ?? m.group(2)!;
        if (name.startsWith('_') || !lines[i].contains(name)) continue;
        if (f.path.contains('/glass/painters.dart') || f.path.contains('/glass/color_matrix.dart')) continue;
        var j = i - 1;
        var doc = '';
        while (j >= 0 && lines[j].startsWith('@')) {
          j--;
        }
        while (j >= 0 && lines[j].startsWith('///')) {
          doc = '${lines[j]}\n$doc';
          j--;
        }
        if (!doc.contains('{@category')) missing.add('${f.path}: $name');
      }
    }
    expect(missing, isEmpty);
  });
}
