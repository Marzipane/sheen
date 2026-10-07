import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The few words sheen widgets show or announce when you give them none: button labels such as Cancel and Done, and
/// screen-reader labels such as "Clear" or "Show password".
///
/// The defaults are English. Translate them once on [SheenScope]:
///
/// ```dart
/// SheenScope(
///   strings: const SheenStrings(cancel: 'Annuler', done: 'OK', search: 'Rechercher'),
///   child: app,
/// )
/// ```
///
/// Every widget that shows text still takes it as a parameter; these are only the fallbacks.
///
/// {@category Foundation}
@immutable
class SheenStrings with Diagnosticable {
  /// Strings with English defaults; pass the ones you translate.
  const SheenStrings({
    this.cancel = 'Cancel',
    this.done = 'Done',
    this.search = 'Search',
    this.clear = 'Clear',
    this.close = 'Close',
    this.back = 'Back',
    this.showPassword = 'Show password',
    this.hidePassword = 'Hide password',
    this.next = 'Next',
    this.previous = 'Previous',
    this.more = 'More',
    this.selected = 'Selected',
  });

  /// The button that dismisses a sheet or dialog without a change.
  final String cancel;

  /// The button that confirms a sheet.
  final String done;

  /// The hint of search fields.
  final String search;

  /// The label of a field's clear button.
  final String clear;

  /// The label of close buttons and of the barrier behind sheets and dialogs.
  final String close;

  /// The label of back buttons.
  final String back;

  /// The label of a password field's eye button while the password is hidden.
  final String showPassword;

  /// The label of a password field's eye button while the password is shown.
  final String hidePassword;

  /// The label of "next" arrows (months, pages).
  final String next;

  /// The label of "previous" arrows (months, pages).
  final String previous;

  /// The label of overflow ("more") buttons.
  final String more;

  /// What a screen reader adds to a selected choice.
  final String selected;

  /// The nearest strings set on a [SheenScope], or the English defaults.
  static SheenStrings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheenStringsScope>()?.strings ?? const SheenStrings();

  /// A copy with the given strings replaced.
  SheenStrings copyWith({
    String? cancel,
    String? done,
    String? search,
    String? clear,
    String? close,
    String? back,
    String? showPassword,
    String? hidePassword,
    String? next,
    String? previous,
    String? more,
    String? selected,
  }) => SheenStrings(
    cancel: cancel ?? this.cancel,
    done: done ?? this.done,
    search: search ?? this.search,
    clear: clear ?? this.clear,
    close: close ?? this.close,
    back: back ?? this.back,
    showPassword: showPassword ?? this.showPassword,
    hidePassword: hidePassword ?? this.hidePassword,
    next: next ?? this.next,
    previous: previous ?? this.previous,
    more: more ?? this.more,
    selected: selected ?? this.selected,
  );

  List<String> get _all => [
    cancel,
    done,
    search,
    clear,
    close,
    back,
    showPassword,
    hidePassword,
    next,
    previous,
    more,
    selected,
  ];

  @override
  bool operator ==(Object other) => other is SheenStrings && listEquals(other._all, _all);

  @override
  int get hashCode => Object.hashAll(_all);
}

/// Provides [SheenStrings] to the widgets below it. [SheenScope] places one; use it directly only to change the
/// strings for part of the tree.
///
/// {@category Foundation}
class SheenStringsScope extends InheritedTheme {
  /// Provides [strings] to [child] and its descendants.
  const SheenStringsScope({super.key, required this.strings, required super.child});

  /// The strings for the subtree.
  final SheenStrings strings;

  @override
  Widget wrap(BuildContext context, Widget child) => SheenStringsScope(strings: strings, child: child);

  @override
  bool updateShouldNotify(SheenStringsScope oldWidget) => oldWidget.strings != strings;
}
