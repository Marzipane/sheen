# sheen gallery

Every sheen widget in its states, with switches for light and dark, right-to-left text, text size, reduced
transparency and motion, and the accent colour. It is a plain `WidgetsApp`: nothing in it needs Material.

```bash
flutter run                      # any device
flutter run -d chrome --wasm     # the web demo
```

Open one page directly with `--dart-define=PAGE=inputs` (on the web: `?page=inputs`); add `DARK=1`, `RTL=1` or
`ACCENT=pink` the same way.
