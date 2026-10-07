import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A full-screen page with an iOS-style large title.
///
/// The title scrolls with the content; once it has scrolled away, a small title fades in at the top. A glass back
/// button (or a close button, for a page presented rather than pushed) and an optional [trailing] control float over a
/// [SheenScrollEdge]; an optional [bottom] bar, usually one primary action, stays above the home indicator. On wide
/// windows the content is centred at a readable width ([SheenLayout.readable]).
///
/// ```dart
/// SheenPage(
///   title: 'Settings',
///   children: [
///     const SheenSectionLabel('Account'),
///     SheenListGroup(children: [SheenListRow(title: 'Email', value: 'ada@example.com', onTap: editEmail)]),
///   ],
/// )
/// ```
///
/// It needs no `Scaffold`; put it in any route.
///
/// {@category Layout}
class SheenPage extends StatefulWidget {
  /// A page titled [title] showing [children] in a scroll view.
  const SheenPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.close = false,
    this.trailing,
    this.bottom,
    this.onBack,
    this.backLabel,
    this.controller,
  });

  /// The large title.
  final String title;

  /// A line under the large title.
  final String? subtitle;

  /// The content, below the title.
  final List<Widget> children;

  /// Shows a close button instead of back: the page was presented, not pushed in a flow.
  final bool close;

  /// A control at the top end, such as a [SheenIconButton].
  final Widget? trailing;

  /// A bar at the bottom, such as a [SheenPrimaryButton] with `expand: true`.
  final Widget? bottom;

  /// Called by the back or close button; pops the route when null. The button shows only when this is set or the
  /// route can be popped.
  final VoidCallback? onBack;

  /// The back or close button's label for screen readers; [SheenStrings.back] or [SheenStrings.close] when null.
  final String? backLabel;

  /// The scroll controller of the content.
  final ScrollController? controller;

  @override
  State<SheenPage> createState() => _SheenPageState();
}

class _SheenPageState extends State<SheenPage> {
  /// How far the content scrolls before the small title shows: about the large title's height.
  static const double _collapseAt = 44;

  ScrollController? _own;
  bool _collapsed = false;

  ScrollController get _controller => widget.controller ?? (_own ??= ScrollController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(SheenPage old) {
    super.didUpdateWidget(old);
    final before = old.controller ?? _own;
    if (before != _controller) {
      before?.removeListener(_onScroll);
      _controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _own?.dispose();
    super.dispose();
  }

  void _onScroll() {
    final c = _controller;
    final collapsed = c.hasClients && c.offset > _collapseAt;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final strings = SheenStrings.of(context);
    final pad = MediaQuery.paddingOf(context);
    final inset = context.contentInset;
    final w = widget;
    final canGoBack = w.onBack != null || (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);
    return ColoredBox(
      color: t.colors.background,
      child: Stack(
        children: [
          ListView(
            controller: _controller,
            padding: EdgeInsets.fromLTRB(inset, pad.top + 64, inset, pad.bottom + (w.bottom == null ? 32 : 112)),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(w.title, style: t.type.largeTitle.copyWith(color: t.colors.text)),
                    ),
                    if (w.subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(w.subtitle!, style: t.type.subhead.copyWith(color: t.colors.textSecondary)),
                      ),
                  ],
                ),
              ),
              ...w.children,
            ],
          ),
          SheenScrollEdge.top(height: pad.top + 64),
          Positioned(
            top: pad.top + 7,
            left: inset + 52,
            right: inset + 52,
            height: 44,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Center(
                  child: AnimatedOpacity(
                    key: const ValueKey('sheen-page-title'),
                    opacity: _collapsed ? 1 : 0,
                    duration: _collapsed ? SheenMotion.fadeIn : SheenMotion.fadeOut,
                    child: Text(
                      w.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.type.headline.copyWith(color: t.colors.text),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (canGoBack)
            PositionedDirectional(
              start: inset,
              top: pad.top + 7,
              child: SheenIconButton(
                icon: w.close ? SheenIcons.close : SheenIcons.back,
                semanticLabel: w.backLabel ?? (w.close ? strings.close : strings.back),
                stroke: 2.3,
                onTap: w.onBack ?? () => Navigator.of(context).maybePop(),
              ),
            ),
          if (w.trailing != null) PositionedDirectional(end: inset, top: pad.top + 7, child: w.trailing!),
          if (w.bottom != null) ...[
            SheenScrollEdge.bottom(height: pad.bottom + 100),
            PositionedDirectional(start: inset, end: inset, bottom: pad.bottom + 16, child: w.bottom!),
          ],
        ],
      ),
    );
  }
}

/// A small upper-case label over a group of rows, such as "PERSONAL DETAILS"; a header for screen readers.
///
/// {@category Layout}
class SheenSectionLabel extends StatelessWidget {
  /// A label showing [text] in capitals.
  const SheenSectionLabel(this.text, {super.key, this.top = 20});

  /// The label; it is shown in capitals.
  final String text;

  /// The space above the label.
  final double top;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(4, top, 4, 8),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: t.type.footnote.copyWith(
            color: t.colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}

/// A note under a group of rows: one or two lines in the secondary text colour.
///
/// {@category Layout}
class SheenSectionNote extends StatelessWidget {
  /// A note showing [text].
  const SheenSectionNote(this.text, {super.key});

  /// The note.
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 0),
      child: Text(text, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
    );
  }
}
