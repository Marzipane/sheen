## 0.5.0

- New `package:sheen/social.dart`: chat and sharing widgets. `SheenPresenceAvatar` (online dot, playing bars),
  `SheenAvatarStack`, `SheenChatRow`, `SheenUnreadCount`, `SheenRequestCard`, `SheenPresenceStrip`,
  `SheenChatBubble`, `SheenReactions`, `SheenReactionBar`, `SheenTypingIndicator`, `SheenShareCard`,
  `SheenComposer`, `SheenFriendPicker`, `SheenListenTogetherBanner`, with `SheenSocialStrings` / `SheenSocialScope`.
- Filled glyphs `SheenIcons.chatFill` and `SheenIcons.peopleFill`, for a Friends or Messages tab.

## 0.4.3

- No change in behaviour: `SheenReorderList` keeps a callback that newer Flutter deprecates (its replacement does not
  exist in the oldest Flutter sheen supports), with the analyzer told why, so the package scores in full again.

## 0.4.2

- **Sheets from nested navigators:** `showSheenSheet` and `showSheenChoiceSheet` take `useRootNavigator`, as
  `showSheenCustomSheet` does, so a sheet opened inside a tab with its own back stack covers the whole app, tab bar
  included.
- **Icons:** `SheenIcons.musicFill`, `waveform`, `waveformFill`, `library` and `libraryFill`, for the tabs of a music
  app.

## 0.4.1

- Formatting only (`dart format` at 120 columns, as CI checks); no change to the API or to how anything draws.

## 0.4.0

- **Music library:** `import 'package:sheen/music.dart'` for the parts of a music player. `SheenArtwork` (a cover with a
  placeholder), `SheenArtworkGlow` (the cover blurred behind the glass; a flat tint with Reduce Transparency),
  `SheenMiniPlayer` (tap or drag up to open, swipe to change song), `SheenSeekBar` (previews while dragging, reports on
  release, 10-second steps for screen readers) with `formatSheenDuration`, `SheenTransportControls` with
  `SheenRepeatMode`, `SheenTrackRow` with `SheenTrackSave` (save, saving with a ring, saved), `SheenArtworkTile` and
  `SheenShelf`, `SheenLyricsView` with `SheenLyricsLine`, `SheenReorderList`, `SheenBandSlider`, `SheenPlayingBars`,
  and `SheenMusicStrings` / `SheenMusicScope` for the words. In the gallery under Music and in `doc/music.md`.
- **Icons:** `SheenIcons.playFill`, `pauseFill`, `nextFill`, `previousFill`, `shuffle`, `repeat`, `repeatOne`, `lyrics`,
  `queue`, `airplay`, `moon`, `thumbDown`, `versions`, `onDevice`, `music` and `grip`. Media controls do not mirror in
  right-to-left text.

## 0.3.6

- **Struck prices in rows:** `SheenKeyValue(was:)` and `SheenListRow(wasValue:)` strike the usual value under the
  value on a deal, as a hotel room shows it.

## 0.3.5

- **Trip card:** the title takes up to two lines (cruise names are long); `heightFor` counts both.

## 0.3.4

- **Trip card:** the tag (a cruise line, "Guaranteed") moves to the photo's foot, bottom start, where a long name has
  the whole width; the top start is the deal badge's alone, as on `SheenPremiumCard`.

## 0.3.3

- **Trip deals as hotel deals:** `SheenTripCard`'s `deal` badge sits top start, as on `SheenPremiumCard`, with the
  tag after it; `wasLabel` says the struck price to a screen reader ("was AED 3,159").

## 0.3.2

- **Deals on trips:** `SheenTripCard` takes `deal` (a badge on the photo, top end, such as "−5%"), `wasPrice` (the
  usual price struck through under the price) and `dealNote` ("until 31 Oct"), as `SheenPremiumCard` does.
  `SheenTripCard.heightFor(scaler, note: true)` makes room for the deal's line in a row with a card on a deal.

## 0.3.1

- **Right to left:** `sheenTextDirectionOf(text)`, the direction a text reads in from its first letter.
  `SheenTripCard` draws its title and eyebrow in their own direction, so an English title in an Arabic app reads
  "9-day Greek Isles" and is cut at its end; `SheenKeyValueCard` does the same for each label and value ("965 ft").
- **Fix:** `SheenTripCard` keeps each line at the height `heightFor` counts whatever font draws it; Arabic text no
  longer overflowed the card by a pixel.

## 0.3.0

- **Tours and cruises:** `SheenTripCard` (a carousel card the size of `SheenPremiumCard`, with a tag, an eyebrow,
  facts and a price from), `SheenTripTag`, `SheenItinerary` with `SheenItineraryStop` (days or ports on a line of
  numbered dots; quiet stops for days at sea) and `SheenTripIcon`. In the gallery under Travel → Tours & cruises and in
  `doc/travel.md`.
- **Icons:** `SheenIcons.ship`.

## 0.2.5

- **pub.dev:** ten screenshots, the most pub.dev shows (0.2.4 listed eleven and lost the screenshots check). The
  foundation screenshot stays in `doc/foundation.md`.

## 0.2.4

- **Docs:** deals in the gallery (Travel → On a deal), a new screenshot on pub.dev and in the README, a deals section
  in `doc/travel.md` with code, and `SheenDealBadge`/`SheenWasPrice` in the widget list. No change in behaviour.

## 0.2.3

- **Hotel card on a deal:** the struck total moves from the name's line to the line under the total, beside the
  headline. On a phone the name had been cut to a few letters ("Palace Dow…").

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
