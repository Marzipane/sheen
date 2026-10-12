## 0.2.2

- `lib/src/travel/cards.dart` formatted with `dart format`, so the package gets its full pub.dev points again. No
  change in behaviour.

## 0.2.1

- **Premium card on a deal:** the struck total moves from the price line to the deal's line under it, before the note
  ("~~AED 1,210.21~~  Ends 12 Oct"). The price line keeps its nights label whole; before, the struck total pushed it
  out ("1 ni…"). Give the row `heightFor(scaler, note: true)` when a card has `wasTotal` or `dealNote`.

## 0.2.0

- **Deals:** `SheenDealBadge` is a red capsule for a deal's words, such as "−15%". The fill is deeper in dark themes, so
  the white words keep their contrast. `SheenWasPrice` is the price before a deal, struck through.
- `SheenHotelCard` and `SheenPremiumCard` take `deal` (the badge on the photo), `wasTotal` (struck next to the total),
  `wasLabel` (how a screen reader says it, such as "was AED 1,422") and `dealNote` (a line such as "Ends Sun 18 Oct").
  `SheenPremiumCard.heightFor` takes `note: true` for a row whose cards have that line. `SheenPriceBlock` takes
  `wasTotal`. Without them, every card looks and reads as before.

## 0.1.4

- **Score line on narrow cards:** on a `SheenHotelCard` the board ("Room only") moves under the score and its words when
  both do not fit on one line. Before, the two halved the line, so on phones about 400 points wide the words were cut
  ("Wonderful · 87% rec…"). With room for both, the board stays at the end of the score's line as before.

## 0.1.3

- **Scores for screen readers:** `SheenHotelCard` and `SheenPremiumCard` take a `scoreLabel`, the way a screen reader
  says the score, such as "Guest score 4.4 out of 5". The badge still shows the number alone. Without a `scoreLabel`
  the card reads the score as before.

## 0.1.2

- **Fields over a bottom bar:** a `SheenTextField` or `SheenPasswordField` that takes focus low on a `SheenPage` with a
  bottom bar now scrolls clear of the bar when the keyboard comes up; before, it stopped under the bar. The new
  `SheenBottomBarSpace` says how much of a scroll view a floating bar covers. `SheenPage` provides one for its own bar;
  wrap your scroll view in one when you float a bar over it yourself.

## 0.1.1

Fixes found while moving the first app onto sheen.

- **Sheets** give their content a transparent `Material`, as Flutter's bottom sheet does. An app's own Material widgets
  in a sheet (a `TextField`, a `Slider`) no longer fail with "No Material widget found". The text style from above the
  sheet stays, so sheen's type still wins over Material's.
- **Toasts** set their own text style. A toast shown from a context outside a `SheenScope` (an overlay above the app's
  pages) no longer draws its text in Flutter's error style, the yellow underline.
- **Type** pins the leading distribution (even, as Material 3) in every style, as it already pinned letter spacing and
  line height. Text now sits in the same place under a Material ancestor and without one; before, text in a sheet
  sat about 1 pt lower than the same text on a page. Goldens are updated for this sub-pixel shift.

## 0.1.0

First release.

- **Foundation:** `SheenScope`, a theme built from one accent (`SheenThemeData.light` / `.dark`), colour, type, glass
  and lens tokens, spacing, radii and layout widths, `SheenStrings` for the few built-in words, `SheenTone`, and 82
  icons (`SheenIcon`, `SheenIcons`).
- **Glass:** `SheenGlass` in regular, clear and prominent kinds with one shared backdrop per scope, and `SheenLens`.
  High contrast and `reduceTransparency` make glass opaque.
- **Motion:** springs (`SheenMotion`), `SheenPressable`, `SheenEntrance`, `SheenPhotoHero` and `SheenRollingDigits`;
  Reduce Motion turns movement into fades.
- **Buttons, navigation, inputs, selection, sheets, feedback, content and layout:** 80+ widgets, among them the
  floating tab bar, toolbars, an action bar, text, password, search and one-time-code fields, a date-range picker, a
  range histogram, choice sheets, a glass menu, sheets with two heights, alerts, toasts, skeletons, empty states,
  status screens, accordions, a card swiper and `SheenPage` with a large title.
- **Travel** (`package:sheen/travel.dart`): hotel, featured and city cards, price blocks, cancellation lines, score
  badges and map price pins, as widgets and as bitmaps for native map markers.
- A gallery app in `example/` and a [live demo](https://marzipane.github.io/sheen/).
