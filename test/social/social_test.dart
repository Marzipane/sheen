import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/music.dart';
import 'package:sheen/social.dart';

import '../helpers.dart';

Future<void> settle(WidgetTester t) => t.pump(const Duration(milliseconds: 400));

void main() {
  testWidgets('SheenChatRow shows the last message, time and unread count, and opens', (t) async {
    var opened = 0;
    await t.pumpWidget(
      host(
        SizedBox(
          width: 380,
          child: SheenChatRow(
            leading: const SheenPresenceAvatar(name: 'danil', presence: SheenPresence.online),
            title: 'danil',
            subtitle: 'Shared “Habibi”',
            time: '9:38',
            unread: 120,
            onTap: () => opened++,
          ),
        ),
      ),
    );
    expect(find.text('Shared “Habibi”'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Online'), findsOneWidget);
    await t.tap(find.text('danil'));
    await settle(t);
    expect(opened, 1);
  });

  testWidgets('SheenRequestCard accepts and declines', (t) async {
    final calls = <String>[];
    await t.pumpWidget(
      host(
        SizedBox(
          width: 380,
          child: SheenRequestCard(
            name: 'karim',
            message: 'wants to be friends',
            onAccept: () => calls.add('yes'),
            onDecline: () => calls.add('no'),
          ),
        ),
      ),
    );
    await t.tap(find.bySemanticsLabel('Accept'));
    await settle(t);
    await t.tap(find.bySemanticsLabel('Decline'));
    await settle(t);
    expect(calls, ['yes', 'no']);
  });

  testWidgets('a bubble of mine sits at the end, theirs at the start; a long press holds', (t) async {
    var held = 0;
    await t.pumpWidget(
      host(
        SizedBox(
          width: 380,
          height: 300,
          child: Column(
            children: [
              const SheenChatBubble(text: 'theirs'),
              SheenChatBubble(text: 'mine', mine: true, footer: 'Seen', onHold: () => held++),
            ],
          ),
        ),
      ),
    );
    expect(t.getTopLeft(find.text('theirs')).dx, lessThan(60));
    expect(t.getTopRight(find.text('mine')).dx, greaterThan(320));
    expect(find.text('Seen'), findsOneWidget);
    await t.longPress(find.text('mine'));
    expect(held, 1);
  });

  testWidgets('reactions show counts and report taps; the bar reports a pick', (t) async {
    SheenReactionCount? tapped;
    String? picked;
    await t.pumpWidget(
      host(
        Column(
          children: [
            SheenReactions(
              reactions: const [
                SheenReactionCount(emoji: '🔥', count: 2, mine: true),
                SheenReactionCount(emoji: '❤️', count: 1),
              ],
              onTap: (r) => tapped = r,
            ),
            SheenReactionBar(chosen: '🔥', onPick: (e) => picked = e),
          ],
        ),
      ),
    );
    expect(find.text('2'), findsOneWidget);
    await t.tap(find.text('❤️').first);
    await settle(t);
    expect(tapped?.emoji, '❤️');
    await t.tap(find.text('😂'));
    await settle(t);
    expect(picked, '😂');
  });

  testWidgets('the composer sends trimmed text and is disabled while empty', (t) async {
    final sent = <String>[];
    var attached = 0;
    final c = TextEditingController();
    await t.pumpWidget(
      host(
        SizedBox(
          width: 380,
          child: SheenComposer(controller: c, onSend: sent.add, onAttach: () => attached++),
        ),
      ),
    );
    await t.tap(find.bySemanticsLabel('Send'));
    await settle(t);
    expect(sent, isEmpty);
    await t.enterText(find.byType(EditableText), '  hello  ');
    await t.pump();
    await t.tap(find.bySemanticsLabel('Send'));
    await settle(t);
    expect(sent, ['hello']);
    await t.tap(find.bySemanticsLabel('Share music'));
    await settle(t);
    expect(attached, 1);
  });

  testWidgets('the friend picker toggles choices', (t) async {
    var picked = <int>{};
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) => SizedBox(
            width: 380,
            child: SheenFriendPicker<int>(
              choices: const [
                SheenFriendChoice(value: 1, name: 'danil'),
                SheenFriendChoice(value: 2, name: 'Road trip', members: ['mariam', 'oleh']),
              ],
              selected: picked,
              onChanged: (s) => set(() => picked = s),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Road trip'));
    await settle(t);
    expect(picked, {2});
    await t.tap(find.text('danil'));
    await settle(t);
    await t.tap(find.text('Road trip'));
    await settle(t);
    expect(picked, {1});
    expect(find.bySemanticsLabel('danil, Selected'), findsOneWidget);
  });

  testWidgets('a share card plays and runs its actions; a compact one opens', (t) async {
    final calls = <String>[];
    await t.pumpWidget(
      host(
        Column(
          children: [
            SheenShareCard(
              kind: 'Song · 3:12',
              title: 'Habibi',
              subtitle: 'Sabi',
              note: 'this one',
              onPlay: () => calls.add('play'),
              actions: [SheenShareAction(label: 'Like', onTap: () => calls.add('like'))],
            ),
            SheenShareCard(kind: 'Artist', title: 'Fairuz', compact: true, round: true, onTap: () => calls.add('open')),
          ],
        ),
      ),
    );
    expect(find.text('SONG · 3:12'), findsOneWidget);
    expect(find.text('this one'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Play'));
    await settle(t);
    await t.tap(find.text('Like'));
    await settle(t);
    await t.tap(find.text('Fairuz'));
    await settle(t);
    expect(calls, ['play', 'like', 'open']);
  });

  testWidgets('the listen-together banner joins, then leaves', (t) async {
    final calls = <String>[];
    Widget banner(bool joined) => host(
      SizedBox(
        width: 380,
        child: SheenListenTogetherBanner(
          title: 'danil is listening',
          subtitle: 'Habibi — Sabi',
          people: const ['danil'],
          joined: joined,
          onJoin: () => calls.add('join'),
          onLeave: () => calls.add('leave'),
        ),
      ),
    );
    await t.pumpWidget(banner(false));
    await t.tap(find.text('Join'));
    await settle(t);
    await t.pumpWidget(banner(true));
    await t.tap(find.text('Leave'));
    await settle(t);
    expect(calls, ['join', 'leave']);
  });

  testWidgets('presence marks: playing bars, and typing dots stand still under Reduce Motion', (t) async {
    await t.pumpWidget(
      host(
        const Column(
          children: [
            SheenPresenceAvatar(name: 'mariam', presence: SheenPresence.playing),
            SheenTypingIndicator(),
            SheenPresenceStrip(
              items: [SheenPresenceItem(name: 'oleh', song: 'Kifak Inta — Fairuz')],
            ),
          ],
        ),
        reduceMotion: true,
      ),
    );
    expect(find.bySemanticsLabel('Listening'), findsWidgets);
    expect(find.bySemanticsLabel('Typing'), findsOneWidget);
    expect(find.text('Kifak Inta — Fairuz'), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
    expect(t.binding.hasScheduledFrame, isFalse);
    await t.pumpWidget(host(const SheenTypingIndicator()));
    await t.pump(const Duration(seconds: 1));
    expect(t.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('dark theme and large text lay out without overflow', (t) async {
    await t.pumpWidget(
      host(
        SizedBox(
          width: 320,
          child: Column(
            children: [
              const SheenChatRow(
                leading: SheenAvatarStack(names: ['a', 'b', 'c', 'd']),
                title: 'A very long group name that goes on',
                subtitle: 'and a long last message too',
                time: 'Yesterday',
                unread: 3,
              ),
              SheenRequestCard(
                name: 'someone_with_a_long_name',
                message: 'wants to be friends',
                onAccept: () {},
                onDecline: () {},
              ),
            ],
          ),
        ),
        brightness: Brightness.dark,
        textScale: 1.6,
      ),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('a share card whose song plays says so: pause, moving bars, accent title', (t) async {
    var taps = 0;
    Widget card({required bool current, required bool playing}) =>
        host(SheenShareCard(kind: 'Song', title: 'Habibi', current: current, playing: playing, onPlay: () => taps++));
    await t.pumpWidget(card(current: false, playing: false));
    expect(find.bySemanticsLabel('Play'), findsOneWidget);
    expect(find.byType(SheenPlayingBars), findsNothing);
    await t.pumpWidget(card(current: true, playing: true));
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
    expect(find.byType(SheenPlayingBars), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Pause'));
    await settle(t);
    expect(taps, 1);
    await t.pumpWidget(card(current: true, playing: false));
    expect(find.bySemanticsLabel('Play'), findsOneWidget);
  });
}
