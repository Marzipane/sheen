import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen_gallery/catalog.dart';
import 'package:sheen_gallery/main.dart';
import 'package:sheen_gallery/settings.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('home and every page build in ${brightness.name}', (t) async {
      t.view.physicalSize = const Size(1179, 2556);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(SheenGalleryApp(initial: GallerySettings(brightness: brightness)));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('sheen'), findsWidgets);
      for (final p in catalog) {
        await t.tap(find.text(p.title).first);
        await t.pump(const Duration(seconds: 1));
        expect(t.takeException(), isNull, reason: p.id);
        t.state<NavigatorState>(find.byType(Navigator)).maybePop();
        await t.pump(const Duration(seconds: 1));
      }
    });
  }

  testWidgets('right to left at 200 % text, the pages still build', (t) async {
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const SheenGalleryApp(initial: GallerySettings(rtl: true, textScale: 2)));
    await t.pump(const Duration(seconds: 1));
    for (final p in catalog) {
      await t.scrollUntilVisible(find.text(p.title).first, 200, scrollable: find.byType(Scrollable).first);
      await t.tap(find.text(p.title).first);
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull, reason: p.id);
      t.state<NavigatorState>(find.byType(Navigator)).maybePop();
      await t.pump(const Duration(seconds: 1));
    }
  });
}
