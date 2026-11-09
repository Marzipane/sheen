## 0.6.10

- `SheenCheck`: a check box with its label beside it, for an agreement or an opt-in in a form. The box fills with the
  accent when ticked and its tick mirrors right to left. A tap anywhere on the row asks for the other value. An optional
  `detail` line goes under the label, and an `error` shows in the danger colour with the box outlined in it while
  empty. A screen reader hears one checkbox with the label, detail, error and state. The row is at least `SheenSpace.hit`
  tall, and without `onChanged` it is disabled.
- `SheenRadius.check` and `SheenControlSize` (`check`, `checkOutline`, `checkMark`): the check box's sizes as tokens.

## 0.6.9

- `SheenColors.fillTonal`: the fill of tonal controls, `surfaceMuted` in light and white at 8 % in dark.
  `SheenSecondaryButton` and the second action of `SheenAlert` use it instead of a colour of their own. Optional in the
  `SheenColors` constructor: a palette that sets none follows its `surfaceMuted`, also after `copyWith`, so existing
  palettes look and behave as in 0.6.8.
- `SheenButtonInset.secondary` and `.floating`: the padding of the capsule buttons as tokens. The gaps next to their
  icons, and between `SheenTextField.leading` and the text, use `SheenSpace.s`. Nothing moves: the values are the same.
- A `SheenPrimaryButton` with a `subLabel` no longer joins the two lines with a comma for screen readers. The second
  line stays readable on its own, so the platform reads the label and then the second line, once each, in any language.
  Its spinner and icon stay hidden from screen readers, as in 0.6.8.

## 0.6.8

- `SheenPage` keeps clear of the keyboard itself, as a `Scaffold` does: its `bottom` bar sits right on the keyboard
  while it is up, and a focused field scrolls clear of both. Before, a page with no `Scaffold` above it left the bar
  under the keyboard, so a number pad (which has no return key) hid the only way on. A `Scaffold` above the page that
  already avoided the keyboard leaves it nothing to do.
- A screen reader says a button's label once. `SheenPrimaryButton`, `SheenSecondaryButton`, `SheenFloatingButton`,
  `SheenTextLink` and the actions of `SheenAlert` read their visible text a second time in 0.6.7 ("Send code, Send
  code"). A primary button with a `subLabel` reads both lines, once each.

## 0.6.7

- `SheenPage.title` is optional. A page without one, such as a welcome screen whose content is its own heading, starts
  its content at the top, shows no small title in the bar and gives screen readers no empty header. A `subtitle` or a
  `barTitle` still shows without it. The field is now a `String?`, so code that reads `page.title` gets a nullable
  value; every page that passes a title looks and behaves as before.

## 0.6.6

- `SheenTextField.leading`: a fixed piece at the start of the field, before the text, such as a country code or a
  currency. It sits at the start edge, so it moves to the right in a right-to-left language.

## 0.6.5

- `SheenTabItem.selectedIcon`: the selected tab shows it filled and the others show `icon` as an outline, on the full,
  minimized and top bars and on the lifted lens. `icon` has to be a plain stroke name: a `.fill` name stays solid.
- `SheenPage.barTitle`: a short name in a glass capsule in the top bar, always shown and read by screen readers, for a
  page whose large title asks a question.
- `SheenIcons.home`: the outline of `SheenIcons.homeFill`.
- A sheet's title and subtitle wrap instead of cutting off, at any text size, so a long one moves the
  sheet's content down. The header takes half the sheet at most and its text scrolls, so the content and the buttons stay on a short
  sheet.

## 0.6.4

- `SheenTabBar` with `searchVariant: prominent` keeps its glyph readable while `searchActive` is on: in 0.6.3 accent ink
  on accent glass nearly vanished. The active state now shows a ring in the label colour, because the lens barely shows
  on accent glass.
- `SheenTopTabBar.searchIcon` and `searchVariant`, as on `SheenTabBar`.
- Tab glyphs with no filled form show their outline by themselves, on both bars. `SheenTabItem.filled` from 0.6.3 is
  deprecated: it is not needed for those glyphs, and `filled: false` still keeps the outline of a stroke name with both forms, such as `SheenIcons.heart`.
- Corrected from 0.6.3: `SheenStatusScreen.details` takes any widget that sizes itself, list rows included. A widget that
  needs a bounded height, such as `Expanded` or a `ListView`, does not fit there.

## 0.6.3

- `SheenTabBar.searchIcon` and `searchVariant`: the circle beside the tabs can be another action, such as a prominent
  plus, on the full and the minimized bar. The defaults stay a search circle on regular glass.
- `SheenTabItem.filled` (deprecated in 0.6.4): false draws a tab's glyph as an outline.
- `SheenStatusScreen` no longer measures its content, so `details` can hold list rows. The layout is the same: the content a little above the middle, the actions at the bottom, and a scroll when it is too tall.
- `llms.txt` is current again.

## 0.6.2

- `SheenChapterList` shows how long each chapter is on the right ("30 min", "1 h 5 min") and where it starts under
  the title ("From 1:30:00"): a start time alone on the right read as a length ("0:00:00" looked like an empty
  chapter). The new `length` (of the audio the chapters belong to) gives the last chapter its length.
- `formatSheenLength`, and the strings `chapterFrom`, `minutes` and `hoursMinutes` in `SheenMusicStrings`.

## 0.6.1

- `SheenMiniPlayer.onSkipForward` (and `skipForward`): a "forward 30" button in place of next, for long audio.
- `SheenSpeedPicker` lays its speeds out as one row of equal buttons; in a list (which gives its children the full
  width) each speed took a whole line.
- `currentSheenChapter` returns -1 when the position is before the first chapter, so a `SheenChapterList` of another
  part of a book marks no chapter as playing.

## 0.6.0

- **Long audio (audiobooks, podcasts)** in `package:sheen/music.dart`:
  - `SheenTransportControls.onSkipBack` / `onSkipForward` put "back 15" and "forward 30" buttons (`skipBack`,
    `skipForward` set how far) in place of previous and next; `leading` and `trailing` take the places of shuffle and
    repeat, for a speed or sleep timer button. Existing players are unchanged.
  - `SheenSkipButton`: the circular arrow with the seconds inside; media controls keep their direction in right to left.
  - `SheenSeekBar.marks` draws a tick where each chapter starts; `SheenSeekBar.rate` makes the time left follow the
    playback speed.
  - `SheenSpeedPicker` and `formatSheenSpeed` (`1.25×`).
  - `SheenChapter`, `currentSheenChapter` and `SheenChapterList`: the chapter playing in the accent colour, the ones
    heard dimmed, a tap picks one.
  - `SheenResumeCard`: "Continue listening" with the cover, what is left, progress and play.
  - `SheenTag` / `SheenTagRow`: small facts under a row ("Whole book · Ukrainian").
  - `SheenArtwork(book: true)`: a 3:4 book cover with a spine shadow.
  - `SheenMusicStrings`: `skipBack`, `skipForward`, `speed`, `chapters`, `continueListening`.
- Icons: `book`, `bookmark`, `chapters`, `skipBack`, `skipForward`.
- AUTHORS: sheen is made and owned by Danil Martsinkovskii and Roman Chernogorov.

## 0.5.1

- **Loading is shown:** `SheenMiniPlayer`, `SheenTransportControls` and `SheenShareCard` take `loading`; a spinner
  takes the play button's place while the song loads (a tap still pauses).
- `SheenPage.leading`: a control at the top start of a page without a back button (a tab's first page).
- `SheenShareCard` shows when its song is the one playing: `current` puts the title in the accent with small
  playing bars, and with `playing` the button shows pause (and says Pause to screen readers).
- **Reactions the way people expect from Instagram:** `SheenChatBubble.onDoubleTap` (a heart pops over the message),
  `onReact` (a small heart button beside every message, so reacting is discoverable; a long press does the same), and
  `showSheenReactionBar`, which opens the emoji row right above the message (or under it near the top).

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
