// Writes llms.txt (https://llmstxt.org): the package in one page, with a link to the API page of every public name,
// grouped by category. It reads the API docs, so run dartdoc first:
//
//   dart doc --output tool/out/api && dart run tool/gen_llms.dart
import 'dart:convert';
import 'dart:io';

const _api = 'https://pub.dev/documentation/sheen/latest';

void main() {
  final names = jsonDecode(File('tool/out/api/categories.json').readAsStringSync()) as List<dynamic>;
  final index = jsonDecode(File('tool/out/api/index.json').readAsStringSync()) as List<dynamic>;
  final descByHref = {
    for (final e in index.cast<Map<String, dynamic>>())
      if (e['desc'] != null) e['href'] as String: (e['desc'] as String).replaceAll(RegExp(r'\s+'), ' ').trim(),
  };
  final order = RegExp(r'categoryOrder: \[(.*)\]').firstMatch(File('dartdoc_options.yaml').readAsStringSync())!;
  final categories = order.group(1)!.split(',').map((c) => c.trim()).toList();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final description = RegExp(
    r'description: >-\n((?:  .*\n)+)',
  ).firstMatch(pubspec)!.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim();

  final out = StringBuffer()
    ..writeln('# sheen')
    ..writeln()
    ..writeln('> $description')
    ..writeln()
    ..writeln(
      'Import `package:sheen/sheen.dart`, and `package:sheen/travel.dart` for the booking widgets. Put a `SheenScope` '
      'above your screens (in `MaterialApp.builder`, or around any app) and read the theme with `context.sheen`. '
      'Every widget builds on `package:flutter/widgets.dart`, so `MaterialApp`, `CupertinoApp` and `WidgetsApp` all '
      'work. Widgets that show words take them as parameters; the few defaults come from `SheenStrings`. Icon-only '
      'buttons require a `semanticLabel`.',
    )
    ..writeln()
    ..writeln('## Docs')
    ..writeln()
    ..writeln('- [README](https://pub.dev/packages/sheen): install, quick start, theming and the widget list')
    ..writeln(
      '- [Example](https://pub.dev/packages/sheen/example): a small app with a page, a sheet, an alert and a toast',
    )
    ..writeln('- [API reference]($_api/): every public name with its documentation');
  for (final category in categories) {
    out
      ..writeln()
      ..writeln('## $category')
      ..writeln();
    final page = File('doc/${category.toLowerCase()}.md').readAsStringSync();
    final intro = page.split('\n\n').skip(1).firstWhere((p) => !p.startsWith('`import') && !p.startsWith('!['));
    out
      ..writeln(intro.replaceAll('\n', ' ').trim())
      ..writeln();
    final entries =
        names.cast<Map<String, dynamic>>().where((e) => (e['categories'] as List).contains(category)).toList()
          ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    for (final e in entries) {
      final href = e['href'] as String;
      final desc = descByHref[href];
      out.writeln('- [${e['name']}]($_api/$href)${desc == null || desc.isEmpty ? '' : ': $desc'}');
    }
  }
  File('llms.txt').writeAsStringSync(out.toString());
  stdout.writeln('llms.txt: ${names.length} names in ${categories.length} categories');
}
