import 'package:flutter/widgets.dart';

final _letter = RegExp(r'\p{L}', unicode: true);

/// The direction [text] reads in, from its first letter: right to left for Hebrew and Arabic scripts, left to right for
/// any other; null when it has no letter (the app's direction then applies).
///
/// For names as someone wrote them: an English hotel or cruise title in an Arabic app keeps its order ("9-day Greek
/// Isles", not "day Greek Isles-9") and is cut at its own end.
///
/// {@category Foundation}
TextDirection? sheenTextDirectionOf(String? text) {
  for (final c in (text ?? '').runes) {
    if ((c >= 0x0590 && c <= 0x08FF) || (c >= 0xFB1D && c <= 0xFDFF) || (c >= 0xFE70 && c <= 0xFEFF)) {
      return TextDirection.rtl;
    }
    if (_letter.hasMatch(String.fromCharCode(c))) return TextDirection.ltr;
  }
  return null;
}
