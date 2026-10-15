import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'people.dart';
import 'strings.dart';

/// Someone (or a group) to pick in a [SheenFriendPicker].
///
/// {@category Social}
@immutable
class SheenFriendChoice<T> {
  /// A choice for [value], shown as [name]; a group shows [members] as a stack.
  const SheenFriendChoice({required this.value, required this.name, this.image, this.members});

  /// What the app gets back.
  final T value;

  /// The person's or the group's name.
  final String name;

  /// Their picture.
  final ImageProvider? image;

  /// For a group: its members' names.
  final List<String>? members;
}

/// A grid of friends and groups to send something to, as a share sheet shows them: tap to pick, tap again to drop;
/// the picked ones get an accent ring.
///
/// ```dart
/// SheenFriendPicker<int>(
///   choices: [for (final f in friends) SheenFriendChoice(value: f.id, name: f.username)],
///   selected: picked,
///   onChanged: (s) => setState(() => picked = s),
/// )
/// ```
///
/// {@category Social}
class SheenFriendPicker<T> extends StatelessWidget {
  /// A picker over [choices].
  const SheenFriendPicker({super.key, required this.choices, required this.selected, required this.onChanged});

  /// Who can be picked.
  final List<SheenFriendChoice<T>> choices;

  /// Who is picked.
  final Set<T> selected;

  /// The new selection.
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenSocialStrings.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final columns = (box.maxWidth / 80).floor().clamp(3, 6);
        final width = box.maxWidth / columns;
        return Wrap(
          runSpacing: SheenSpace.m,
          children: [
            for (final c in choices)
              SizedBox(
                width: width,
                child: SheenPressable(
                  selected: selected.contains(c.value),
                  semanticLabel: selected.contains(c.value) ? '${c.name}, ${s.selected}' : c.name,
                  onTap: () {
                    final next = {...selected};
                    next.contains(c.value) ? next.remove(c.value) : next.add(c.value);
                    onChanged(next);
                  },
                  child: ExcludeSemantics(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected.contains(c.value) ? t.colors.accent : const Color(0x00000000),
                              width: 2.5,
                            ),
                          ),
                          child: c.members != null
                              ? SizedBox.square(
                                  dimension: 54,
                                  child: Center(child: SheenAvatarStack(names: c.members!, size: 30)),
                                )
                              : SheenAvatar(name: c.name, image: c.image, size: 54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: t.type.caption.copyWith(color: t.colors.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
