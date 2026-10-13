import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

void main() {
  test('a text reads in the direction of its first letter; none when it has no letter', () {
    expect(sheenTextDirectionOf('9-day Greek Isles'), TextDirection.ltr);
    expect(sheenTextDirectionOf('«Atlantis»'), TextDirection.ltr);
    expect(sheenTextDirectionOf('٣ ليالٍ في دبي'), TextDirection.rtl);
    expect(sheenTextDirectionOf('שלום'), TextDirection.rtl);
    expect(sheenTextDirectionOf('Готель'), TextDirection.ltr);
    expect(sheenTextDirectionOf('2027 · 18,930'), isNull);
    expect(sheenTextDirectionOf(null), isNull);
  });
}
