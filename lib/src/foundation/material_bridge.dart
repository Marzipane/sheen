import 'package:flutter/material.dart';

/// Lets Flutter's `TextField` run under any app.
///
/// sheen's text inputs are built on `TextField` for its editing, selection handles and context menu. `TextField`
/// needs a `Material` ancestor and `MaterialLocalizations`, which `CupertinoApp` and `WidgetsApp` do not provide.
/// This adds a transparent `Material` and, only when the app has none, Material's English localizations (they label
/// the copy/paste menu). It is the only place sheen depends on the Material library. Not exported.
class SheenMaterialBridge extends StatelessWidget {
  /// Wraps [child], a `TextField`, with what it needs.
  const SheenMaterialBridge({super.key, required this.child});

  /// The text field.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget c = Material(type: MaterialType.transparency, child: child);
    if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null) {
      const delegates = <LocalizationsDelegate<Object>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ];
      final locale = Localizations.maybeLocaleOf(context);
      c = locale == null
          ? Localizations(locale: const Locale('en', 'US'), delegates: delegates, child: c)
          : Localizations.override(context: context, delegates: delegates, child: c);
    }
    return c;
  }
}
