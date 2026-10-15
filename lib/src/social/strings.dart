import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The words the social widgets show or announce when you give them none.
///
/// The defaults are English. Translate them once with a [SheenSocialScope] above your app.
///
/// {@category Social}
@immutable
class SheenSocialStrings with Diagnosticable {
  /// Strings with English defaults; pass the ones you translate.
  const SheenSocialStrings({
    this.online = 'Online',
    this.listening = 'Listening',
    this.message = 'Message',
    this.send = 'Send',
    this.attach = 'Share music',
    this.typing = 'Typing',
    this.accept = 'Accept',
    this.decline = 'Decline',
    this.join = 'Join',
    this.leave = 'Leave',
    this.play = 'Play',
    this.react = 'React',
    this.selected = 'Selected',
  });

  /// The presence dot.
  final String online;

  /// The playing badge.
  final String listening;

  /// The composer's placeholder.
  final String message;

  /// The composer's send button.
  final String send;

  /// The composer's attach button.
  final String attach;

  /// What a screen reader says for the typing dots.
  final String typing;

  /// Accepting a friend request.
  final String accept;

  /// Declining a friend request.
  final String decline;

  /// Joining a listen-together session.
  final String join;

  /// Leaving a listen-together session.
  final String leave;

  /// The play button on a shared card.
  final String play;

  /// The reaction bar.
  final String react;

  /// A picked friend.
  final String selected;

  /// The strings of the nearest [SheenSocialScope], or the English defaults.
  static SheenSocialStrings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheenSocialScope>()?.strings ?? const SheenSocialStrings();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('message', message))
      ..add(StringProperty('send', send));
  }
}

/// Provides [SheenSocialStrings] to the social widgets below it.
///
/// {@category Social}
class SheenSocialScope extends InheritedWidget {
  /// A scope with [strings].
  const SheenSocialScope({super.key, required this.strings, required super.child});

  /// The words social widgets use below this scope.
  final SheenSocialStrings strings;

  @override
  bool updateShouldNotify(SheenSocialScope oldWidget) => strings != oldWidget.strings;
}
