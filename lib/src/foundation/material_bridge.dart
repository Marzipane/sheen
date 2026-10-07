import 'package:flutter/material.dart';

/// Lets Flutter's Material widgets run under any app.
///
/// sheen's text inputs are built on `TextField` for its editing, selection handles and context menu, and a sheet's
/// content may hold the app's own Material widgets (a `TextField`, a `Slider`). They need a `Material` ancestor and
/// `MaterialLocalizations`, which `CupertinoApp` and `WidgetsApp` do not provide and sheen's sheet route does not
/// either. This adds a transparent `Material` and, only when the app has none, Material's English localizations (they
/// label the copy/paste menu). It is the only place sheen depends on the Material library. Not exported.
class SheenMaterialBridge extends StatelessWidget {
  /// Wraps [child] (a `TextField`, or a sheet's content) with what it needs.
  const SheenMaterialBridge({super.key, required this.child});

  /// The text field.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Material sets its own text style; the one from above comes back under it, so nothing below changes
    final inherited = DefaultTextStyle.of(context);
    Widget c = Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: inherited.style,
        textAlign: inherited.textAlign,
        softWrap: inherited.softWrap,
        overflow: inherited.overflow,
        maxLines: inherited.maxLines,
        textWidthBasis: inherited.textWidthBasis,
        textHeightBehavior: inherited.textHeightBehavior,
        child: child,
      ),
    );
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
