import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/src/icons/icon_data.dart';

Widget box(Widget child, {TextDirection dir = TextDirection.ltr}) => Directionality(
  textDirection: dir,
  child: Center(child: child),
);

void main() {
  testWidgets('every built-in name builds', (t) async {
    for (final n in SheenIcons.all) {
      await t.pumpWidget(box(SheenIcon(n)));
      expect(find.byType(SvgPicture), findsOneWidget, reason: n);
    }
  });

  test('every SheenIcons name has a glyph, and every glyph has a name', () {
    expect(SheenIcons.all.length, sheenStrokeIcons.length + sheenFilledIcons.length);
    for (final n in SheenIcons.all) {
      expect(SheenIcon(n).svg(), contains('<'), reason: n);
    }
  });

  test('a filled glyph is addressed as name.fill or with filled: true', () {
    expect(const SheenIcon(SheenIcons.heartFill).svg(), const SheenIcon('heart', filled: true).svg());
    expect(const SheenIcon(SheenIcons.heartFill).svg(), contains('fill="#000"'));
    expect(const SheenIcon(SheenIcons.heart).svg(), contains('stroke="#000"'));
  });

  testWidgets('size is honoured', (t) async {
    await t.pumpWidget(box(const SheenIcon(SheenIcons.search, size: 25)));
    expect(t.getSize(find.byType(SheenIcon)), const Size(25, 25));
  });

  testWidgets('back, chevron and forward arrows flip in right to left; search does not', (t) async {
    await t.pumpWidget(box(const SheenIcon(SheenIcons.back), dir: TextDirection.rtl));
    expect(find.byType(Transform), findsOneWidget);
    await t.pumpWidget(box(const SheenIcon(SheenIcons.chevron), dir: TextDirection.rtl));
    expect(find.byType(Transform), findsOneWidget);
    await t.pumpWidget(box(const SheenIcon(SheenIcons.search), dir: TextDirection.rtl));
    expect(find.byType(Transform), findsNothing);
    await t.pumpWidget(box(const SheenIcon(SheenIcons.back)));
    expect(find.byType(Transform), findsNothing);
  });

  testWidgets('a label makes the icon an image for screen readers; otherwise it is hidden', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(box(const SheenIcon(SheenIcons.heartFill, semanticLabel: 'Save')));
    expect(find.bySemanticsLabel('Save'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the colour defaults to the ambient icon colour', (t) async {
    await t.pumpWidget(
      box(
        const IconTheme(
          data: IconThemeData(color: Color(0xFF123456)),
          child: SheenIcon(SheenIcons.star),
        ),
      ),
    );
    final pic = t.widget<SvgPicture>(find.byType(SvgPicture));
    expect(pic.colorFilter, const ColorFilter.mode(Color(0xFF123456), BlendMode.srcIn));
  });

  test('music glyphs exist', () {
    for (final n in [
      SheenIcons.playFill,
      SheenIcons.pauseFill,
      SheenIcons.nextFill,
      SheenIcons.previousFill,
      SheenIcons.shuffle,
      SheenIcons.repeat,
      SheenIcons.repeatOne,
      SheenIcons.lyrics,
      SheenIcons.queue,
      SheenIcons.airplay,
      SheenIcons.moon,
      SheenIcons.thumbDown,
      SheenIcons.versions,
      SheenIcons.onDevice,
      SheenIcons.music,
      SheenIcons.grip,
    ]) {
      expect(SheenIcon(n).svg(), contains('<'), reason: n);
    }
  });

  testWidgets('media controls do not mirror in right to left (as the Apple HIG asks)', (t) async {
    for (final n in [SheenIcons.playFill, SheenIcons.nextFill, SheenIcons.previousFill, SheenIcons.shuffle]) {
      await t.pumpWidget(box(SheenIcon(n), dir: TextDirection.rtl));
      expect(find.byType(Transform), findsNothing, reason: n);
    }
  });

  test('an unknown name fails loudly in debug', () {
    expect(() => const SheenIcon('no-such-icon').svg(), throwsA(isA<AssertionError>()));
  });
}
