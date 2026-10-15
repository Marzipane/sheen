import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/social.dart';

import '../helpers.dart';

void main() {
  testWidgets('a loading song shows a spinner in the mini player, the transport and its share card', (t) async {
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 380,
          child: Column(
            children: [
              SheenMiniPlayer(title: 'Habibi', playing: true, loading: true),
              SheenTransportControls(playing: true, loading: true),
              SheenShareCard(kind: 'Song', title: 'Habibi', current: true, playing: true, loading: true, onPlay: _noop),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(SheenSpinner), findsNWidgets(3));
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 380,
          child: Column(
            children: [
              SheenMiniPlayer(title: 'Habibi', playing: true),
              SheenTransportControls(playing: true),
              SheenShareCard(kind: 'Song', title: 'Habibi', current: true, playing: true, onPlay: _noop),
            ],
          ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 100)); // the transport fades the spinner out
    }
    expect(find.byType(SheenSpinner), findsNothing);
  });

  testWidgets('a page without a back button shows its leading control at the top start', (t) async {
    var taps = 0;
    await t.pumpWidget(
      host(
        SheenPage(
          title: 'Home',
          leading: SheenIconButton(icon: SheenIcons.chat, semanticLabel: 'Friends', onTap: () => taps++),
          children: const [SizedBox(height: 10)],
        ),
      ),
    );
    expect(t.getTopLeft(find.bySemanticsLabel('Friends')).dx, lessThan(100)); // the start, not the end
    await t.tap(find.bySemanticsLabel('Friends'));
    await t.pump(const Duration(milliseconds: 400));
    expect(taps, 1);
  });
}

void _noop() {}
