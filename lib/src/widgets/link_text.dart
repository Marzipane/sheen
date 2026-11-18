import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A link inside a [SheenLinkText]: the words people tap and what a tap does.
///
/// {@category Layout}
class SheenLink {
  /// A link reading [text] that calls [onTap].
  const SheenLink(this.text, {required this.onTap, this.semanticLabel});

  /// The words shown in the paragraph.
  final String text;

  /// Called when the link is tapped.
  final VoidCallback onTap;

  /// What a screen reader says for the link, such as "Privacy policy, opens in the browser"; [text] when null.
  final String? semanticLabel;
}

/// A paragraph in the secondary text colour with links inside it, such as "Details are in the Privacy policy."
///
/// [text] marks each link with its key in braces, and [links] gives the link for each key, so a translation can put
/// the links where its grammar needs them:
/// ```dart
/// SheenLinkText(
///   'Details are in the {privacy}.',
///   links: {'privacy': SheenLink('Privacy policy', onTap: openPrivacy)},
/// )
/// ```
/// The links are in the accent text colour. Each one takes taps in a box at least [SheenSpace.hit] wide and tall
/// around its words, without moving the lines apart; the paragraph keeps room above its first line and below its last
/// so that box fits on those lines too. A screen reader hears each link as a link of its own.
///
/// {@category Layout}
class SheenLinkText extends StatefulWidget {
  /// A paragraph reading [text], with the [links] its braces name.
  const SheenLinkText(this.text, {super.key, required this.links});

  /// The paragraph, with `{key}` where each link goes.
  final String text;

  /// The link for each key in [text].
  final Map<String, SheenLink> links;

  @override
  State<SheenLinkText> createState() => _SheenLinkTextState();
}

class _SheenLinkTextState extends State<SheenLinkText> {
  // the recognizers only serve a screen reader's tap; a finger's tap goes through _LinkHitArea
  final Map<String, TapGestureRecognizer> _recognizers = {};

  static final _placeholder = RegExp(r'\{(\w+)\}');

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizer(String key, SheenLink link) =>
      (_recognizers[key] ??= TapGestureRecognizer())..onTap = link.onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final linkStyle = TextStyle(color: t.colors.accentText);
    final spans = <InlineSpan>[];
    final ranges = <(int, int, SheenLink)>[];
    var offset = 0;
    var plain = 0;
    for (final match in _placeholder.allMatches(widget.text)) {
      final before = widget.text.substring(plain, match.start);
      spans.add(TextSpan(text: before));
      offset += before.length;
      final key = match.group(1)!;
      final link = widget.links[key];
      assert(link != null, 'SheenLinkText: no link for {$key}');
      if (link == null) {
        spans.add(TextSpan(text: match.group(0)));
        offset += match.group(0)!.length;
      } else {
        spans.add(
          TextSpan(
            text: link.text,
            style: linkStyle,
            recognizer: _recognizer(key, link),
            semanticsLabel: link.semanticLabel,
          ),
        );
        ranges.add((offset, offset + link.text.length, link));
        offset += link.text.length;
      }
      plain = match.end;
    }
    spans.add(TextSpan(text: widget.text.substring(plain)));
    final style = t.type.footnote.copyWith(color: t.colors.textSecondary);
    final line = TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final room = math.max(0.0, (SheenSpace.hit - line.height) / 2);
    line.dispose();
    return _LinkHitArea(
      links: ranges,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: room),
        child: Text.rich(TextSpan(children: spans), style: style),
      ),
    );
  }
}

/// Takes a tap anywhere in the [SheenSpace.hit]-sized box around a link's words and opens the nearest link.
class _LinkHitArea extends SingleChildRenderObjectWidget {
  const _LinkHitArea({required this.links, required super.child});

  final List<(int, int, SheenLink)> links;

  @override
  _RenderLinkHitArea createRenderObject(BuildContext context) => _RenderLinkHitArea(links);

  @override
  void updateRenderObject(BuildContext context, _RenderLinkHitArea renderObject) => renderObject.links = links;
}

class _RenderLinkHitArea extends RenderProxyBox {
  _RenderLinkHitArea(this.links);

  List<(int, int, SheenLink)> links;

  late final TapGestureRecognizer _tap = TapGestureRecognizer()..onTap = () => _pressed?.onTap();
  SheenLink? _pressed;

  RenderParagraph? get _paragraph {
    RenderParagraph? found;
    void visit(RenderObject child) {
      if (found != null) return;
      if (child is RenderParagraph) {
        found = child;
      } else {
        child.visitChildren(visit);
      }
    }

    visitChildren(visit);
    return found;
  }

  /// The link whose hit box holds [position], the one with its words nearest when boxes overlap.
  SheenLink? _linkAt(Offset position) {
    final paragraph = _paragraph;
    if (paragraph == null || !hasSize) return null;
    final toParagraph = paragraph.getTransformTo(this);
    SheenLink? best;
    var bestDistance = double.infinity;
    for (final (start, end, link) in links) {
      for (final box in paragraph.getBoxesForSelection(TextSelection(baseOffset: start, extentOffset: end))) {
        final words = MatrixUtils.transformRect(toParagraph, box.toRect());
        final area = Rect.fromCenter(
          center: words.center,
          width: math.max(words.width, SheenSpace.hit),
          height: math.max(words.height, SheenSpace.hit),
        );
        if (!area.contains(position)) continue;
        final distance = (words.center - position).distanceSquared;
        if (distance < bestDistance) {
          bestDistance = distance;
          best = link;
        }
      }
    }
    return best;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position) && _linkAt(position) != null) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return super.hitTest(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      final link = _linkAt(entry.localPosition);
      if (link == null) return;
      _pressed = link;
      _tap.addPointer(event);
    }
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }
}
