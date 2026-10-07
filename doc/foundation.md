# Foundation

The theme and the tokens every widget reads. Put a `SheenScope` above your screens; read the theme with
`context.sheen`.

- `SheenThemeData.light(accent: ...)` and `.dark(...)` build the colours, type and glass from one accent.
- `SheenColors`, `SheenType` and `SheenGlassStyles` hold them; each has `copyWith`.
- `SheenStrings` holds the few words widgets show when you give none; translate them once.
- `SheenTone` gives messages their colour; `SheenIcons` names the built-in glyphs.

![Colours, type and icons](https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/10-foundation.webp)
