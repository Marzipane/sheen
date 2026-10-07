// The README's quick start, kept compiling and running.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Hello',
    children: [
      SheenGlass(
        padding: const EdgeInsets.all(16),
        child: Text('Frosted glass', style: context.sheen.type.headline),
      ),
      const SizedBox(height: 16),
      SheenPrimaryButton(label: 'Continue', expand: true, onPressed: () {}),
    ],
  );
}

void main() {
  testWidgets('the quick start runs under MaterialApp', (t) async {
    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => SheenScope(child: child!),
        home: const HomePage(),
      ),
    );
    expect(find.text('Frosted glass'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('the theming snippet builds', (t) async {
    await t.pumpWidget(
      SheenScope(
        theme: SheenThemeData.light(accent: const Color(0xFF087F5B)),
        darkTheme: SheenThemeData.dark(accent: const Color(0xFF20C997)),
        strings: const SheenStrings(cancel: 'Annuler', done: 'OK', search: 'Rechercher'),
        reduceTransparency: false,
        child: const SizedBox(),
      ),
    );
    expect(t.takeException(), isNull);
  });
}
