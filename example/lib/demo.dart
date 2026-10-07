import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// One widget on a gallery page: a label above it, an optional note below.
class Demo extends StatelessWidget {
  const Demo({super.key, required this.title, required this.child, this.note});

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [SheenSectionLabel(title), child, if (note != null) SheenSectionNote(note!)],
    ),
  );
}

/// Children laid out in a wrapping row with even gaps.
class Gap extends StatelessWidget {
  const Gap({super.key, required this.children, this.spacing = 10});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: spacing, runSpacing: spacing, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

/// A tap target that opens something, for the sheet and dialog demos.
class OpenButton extends StatelessWidget {
  const OpenButton(this.label, {super.key, required this.onPressed, this.icon});

  final String label;
  final String? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SheenSecondaryButton(label: label, icon: icon, onPressed: onPressed);
}
