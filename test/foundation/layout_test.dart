import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

void main() {
  test('a phone keeps its 16 pt sides; a wider window centres the content at the readable width', () {
    expect(SheenLayout.inset(402), 16);
    expect(SheenLayout.inset(375), 16);
    // iPad Air 11-inch portrait: (820 - 720) / 2
    expect(SheenLayout.inset(820), 50);
    // landscape: the grid's wider column
    expect(SheenLayout.inset(1180, max: SheenLayout.wide), 50);
    expect(SheenLayout.inset(1180), 230);
    // never under the given minimum
    expect(SheenLayout.inset(760, min: 20), 20);
  });

  test('results go two across from a tablet\'s width; cities three, then four', () {
    expect(SheenLayout.columns(402), 1);
    expect(SheenLayout.columns(699), 1);
    expect(SheenLayout.columns(700), 2);
    expect(SheenLayout.columns(1180), 2);
    expect(SheenLayout.tiles(402), 2);
    expect(SheenLayout.tiles(820), 3);
    expect(SheenLayout.tiles(1180), 4);
  });

  test('the wide layouts from tablet width (not Split View); side panes from a tablet in landscape', () {
    expect(SheenLayout.isWide(699), isFalse);
    expect(SheenLayout.isWide(700), isTrue);
    expect(SheenLayout.isWide(820), isTrue);
    expect(SheenLayout.hasSidePane(820), isFalse);
    expect(SheenLayout.hasSidePane(1000), isTrue);
    expect(SheenLayout.hasSidePane(1180), isTrue);
  });
}
