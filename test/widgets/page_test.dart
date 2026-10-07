import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  Widget pushed(Widget page) => host(
    Builder(
      builder: (c) => GestureDetector(
        onTap: () => Navigator.of(c).push(PageRouteBuilder<void>(pageBuilder: (_, _, _) => page)),
        child: const Text('open'),
      ),
    ),
  );

  testWidgets('a page shows its large title and content; back pops it', (t) async {
    await t.pumpWidget(pushed(const SheenPage(title: 'Settings', subtitle: 'Your account', children: [Text('Row')])));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Your account'), findsOneWidget);
    expect(find.text('Row'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Back'));
    await t.pumpAndSettle();
    expect(find.text('Row'), findsNothing);
  });

  testWidgets('a presented page has a close button instead', (t) async {
    await t.pumpWidget(pushed(const SheenPage(title: 'Terms', close: true, children: [Text('Row')])));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsNothing);
  });

  testWidgets('scrolled past its large title, the title shows small in the toolbar', (t) async {
    await t.pumpWidget(
      host(
        SheenPage(
          title: 'Settings',
          children: [for (var i = 0; i < 40; i++) SizedBox(height: 50, child: Text('row $i'))],
        ),
      ),
    );
    double small() => t.widget<AnimatedOpacity>(find.byKey(const ValueKey('sheen-page-title'))).opacity;
    expect(small(), 0);
    await t.drag(find.text('row 3'), const Offset(0, -200));
    await t.pumpAndSettle();
    expect(small(), 1);
  });

  testWidgets('the bottom bar stays above the content', (t) async {
    await t.pumpWidget(
      host(
        SheenPage(
          title: 'Checkout',
          bottom: SheenPrimaryButton(label: 'Pay', expand: true, onPressed: () {}),
          children: const [Text('Row')],
        ),
      ),
    );
    final screen = t.view.physicalSize / t.view.devicePixelRatio;
    expect(t.getRect(find.byType(SheenPrimaryButton)).bottom, lessThanOrEqualTo(screen.height - 16));
  });

  testWidgets('a field low on a page with a bottom bar scrolls clear of the bar when the keyboard comes', (t) async {
    t.view.physicalSize = const Size(1206, 2622);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final email = TextEditingController();
    addTearDown(email.dispose);
    await t.pumpWidget(
      host(
        // as an app's Scaffold does: the page above the keyboard
        Builder(
          builder: (c) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
            child: SheenPage(
              title: 'Guests',
              bottom: SheenPrimaryButton(label: 'Continue', expand: true, onPressed: () {}),
              children: [
                const SizedBox(height: 560),
                SheenTextField(label: 'Email', controller: email),
              ],
            ),
          ),
        ),
      ),
    );
    await t.tap(find.byType(EditableText));
    t.view.viewInsets = const FakeViewPadding(bottom: 336 * 3);
    await t.pumpAndSettle();
    final field = t.getRect(find.byType(EditableText));
    final bar = t.getRect(find.byType(SheenPrimaryButton));
    expect(field.bottom, lessThanOrEqualTo(bar.top), reason: 'the focused field is not under the bar');
  });

  testWidgets('a section label is an upper-case header; a note follows a group', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(
      host(const Column(children: [SheenSectionLabel('Personal details'), SheenSectionNote('Kept private.')])),
    );
    expect(find.text('PERSONAL DETAILS'), findsOneWidget);
    expect(t.getSemantics(find.text('PERSONAL DETAILS')).flagsCollection.isHeader, isTrue);
    expect(find.text('Kept private.'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a password field hides its text until asked, and says which way the button goes', (t) async {
    final c = TextEditingController(text: 'secret');
    await t.pumpWidget(host(SheenPasswordField(label: 'Password', controller: c)));
    EditableText field() => t.widget<EditableText>(find.byType(EditableText));
    expect(field().obscureText, isTrue);
    await t.tap(find.bySemanticsLabel('Show password'));
    await t.pump();
    expect(field().obscureText, isFalse);
    expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
    expect(field().autofillHints, contains(AutofillHints.password));
  });
}
