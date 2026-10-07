# Glass

`SheenGlass` draws frosted glass in Flutter: a backdrop blur with saturation, a body gradient, a rim, edge lines, a
highlight and a shadow. Regular glass sits on bars and controls, clear glass over photos, prominent glass (the accent)
on the one confirming action.

All glass under a `SheenScope` shares one backdrop copy, so many glass widgets cost little more than one. High
contrast and `SheenThemeData.reduceTransparency` make glass opaque.

![Glass over a photo](https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/01-glass.webp)
