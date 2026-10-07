import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

void main() {
  testWidgets('follows the platform brightness unless one is forced', (t) async {
    t.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(t.platformDispatcher.clearPlatformBrightnessTestValue);
    late SheenThemeData seen;
    Widget probe() => Builder(
      builder: (c) {
        seen = c.sheen;
        return const SizedBox();
      },
    );
    await t.pumpWidget(
      MediaQuery.fromView(
        view: t.view,
        child: SheenScope(child: probe()),
      ),
    );
    expect(seen.isDark, isTrue);
    await t.pumpWidget(
      MediaQuery.fromView(
        view: t.view,
        child: SheenScope(brightness: Brightness.light, child: probe()),
      ),
    );
    expect(seen.isDark, isFalse);
  });

  testWidgets('uses the given light and dark themes and applies reduceTransparency', (t) async {
    late SheenThemeData seen;
    Widget probe() => Builder(
      builder: (c) {
        seen = c.sheen;
        return const SizedBox();
      },
    );
    await t.pumpWidget(
      SheenScope(
        brightness: Brightness.dark,
        darkTheme: SheenThemeData.dark(accent: const Color(0xFFD6336C)),
        child: probe(),
      ),
    );
    expect(seen.colors.accent, const Color(0xFFD6336C));
    await t.pumpWidget(SheenScope(brightness: Brightness.light, reduceTransparency: true, child: probe()));
    expect(seen.isDark, isFalse);
    expect(seen.reduceTransparency, isTrue);
  });

  testWidgets('provides strings, a default text style, a backdrop group and the status bar style', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(
      SheenScope(
        brightness: Brightness.dark,
        strings: const SheenStrings(cancel: 'Annuler'),
        child: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(SheenStrings.of(ctx).cancel, 'Annuler');
    expect(SheenStrings.of(ctx).done, 'Done');
    expect(DefaultTextStyle.of(ctx).style.color, ctx.sheen.colors.text);
    expect(DefaultTextStyle.of(ctx).style.fontSize, ctx.sheen.type.body.fontSize);
    expect(IconTheme.of(ctx).color, ctx.sheen.colors.text);
    expect(BackdropGroup.of(ctx), isNotNull);
    expect(
      t.widget<AnnotatedRegion<SystemUiOverlayStyle>>(find.byType(AnnotatedRegion<SystemUiOverlayStyle>)).value,
      SystemUiOverlayStyle.light,
    );
  });

  testWidgets('SheenStrings.of without a scope gives English', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    );
    expect(SheenStrings.of(ctx).search, 'Search');
    expect(SheenStrings.of(ctx), const SheenStrings());
  });

  test('strings copyWith and ==', () {
    expect(const SheenStrings().copyWith(done: 'Fertig').done, 'Fertig');
    expect(const SheenStrings().copyWith(done: 'Fertig').cancel, 'Cancel');
    expect(const SheenStrings(), const SheenStrings());
  });
}
