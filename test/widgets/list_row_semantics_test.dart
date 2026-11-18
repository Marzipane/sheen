import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

// as a screen reader's double tap reaches the node
void tapNode(WidgetTester t, SemanticsNode node) => t.binding.performSemanticsAction(
  SemanticsActionEvent(type: SemanticsAction.tap, viewId: t.view.viewId, nodeId: node.id),
);

void main() {
  testWidgets('each tappable row of a group is its own semantics node with its own label and tap', (t) async {
    final handle = t.ensureSemantics();
    final taps = <String>[];
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SheenListGroup(
            children: [
              SheenListRow(title: 'Change number', onTap: () => taps.add('number')),
              SheenListRow(title: 'Use e-mail instead', onTap: () => taps.add('email')),
            ],
          ),
        ),
      ),
    );
    final number = t.getSemantics(find.text('Change number'));
    final email = t.getSemantics(find.text('Use e-mail instead'));
    expect(number.id, isNot(email.id));
    expect(number.label, 'Change number');
    expect(email.label, 'Use e-mail instead');
    expect(number.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(email.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    tapNode(t, number);
    tapNode(t, email);
    expect(taps, ['number', 'email']);
    handle.dispose();
  });

  // A scrolling page (SheenPage, a ListView) makes each of its children one semantics node, which merges every
  // node under it that is not a container of its own.
  testWidgets('a tappable row next to static rows keeps its own node on a scrolling page', (t) async {
    final handle = t.ensureSemantics();
    var changed = 0;
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          height: 600,
          child: ListView(
            children: [
              SheenListGroup(
                children: [
                  const SheenListRow(title: 'Resend', subtitle: 'In 0:42'),
                  const SheenListRow(title: 'Send by text', subtitle: 'In 0:42'),
                  SheenListRow(title: 'Change number', onTap: () => changed++),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final change = t.getSemantics(find.bySemanticsLabel('Change number'));
    expect(change.label, 'Change number', reason: 'the static rows are not read into the row');
    expect(change.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    final resend = t.getSemantics(find.text('Resend'));
    expect(resend.id, isNot(change.id));
    expect(resend.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);

    tapNode(t, change);
    expect(changed, 1);
    handle.dispose();
  });

  testWidgets('two pressables side by side stay two nodes', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(
      host(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenPressable(onTap: () {}, semanticLabel: 'Back', child: const SizedBox(width: 20, height: 20)),
            SheenPressable(onTap: () {}, semanticLabel: 'Share', child: const SizedBox(width: 20, height: 20)),
          ],
        ),
      ),
    );
    final back = t.getSemantics(find.bySemanticsLabel('Back'));
    final share = t.getSemantics(find.bySemanticsLabel('Share'));
    expect(back.id, isNot(share.id));
    expect(back.label, 'Back');
    expect(share.label, 'Share');
    handle.dispose();
  });
}
