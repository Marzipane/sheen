#!/bin/bash
# Captures the pub.dev screenshots from the gallery on an iOS simulator (real blur, the system font).
# Usage: tool/shoot.sh <simulator-udid>   (ONLY="01-glass 05-sheet" retakes just those)
#        Output: doc/screenshots/<name>.webp (and raw PNGs in doc/screenshots/raw/)
set -euo pipefail
SIM=${1:?simulator udid}
APP=dev.sheen.sheenGallery
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=$ROOT/doc/screenshots
mkdir -p "$OUT/raw"
xcrun simctl boot "$SIM" 2>/dev/null || true
xcrun simctl status_bar "$SIM" override --time 9:41 --batteryState charged --batteryLevel 100 --cellularMode active --cellularBars 4 --wifiBars 3 --dataNetwork wifi

shot() { # name, then KEY=VALUE dart-defines
  local name=$1; shift
  if [[ -n "${ONLY:-}" && " $ONLY " != *" $name "* ]]; then return; fi
  local defines=()
  for d in "$@"; do defines+=("--dart-define=$d"); done
  (cd "$ROOT/example" && flutter build ios --simulator --debug "${defines[@]}" >/dev/null)
  xcrun simctl terminate "$SIM" "$APP" 2>/dev/null || true
  xcrun simctl install "$SIM" "$ROOT/example/build/ios/iphonesimulator/Runner.app"
  xcrun simctl launch "$SIM" "$APP" >/dev/null
  sleep 7
  xcrun simctl io "$SIM" screenshot "$OUT/raw/$name.png" >/dev/null 2>&1
  cwebp -quiet -q 84 "$OUT/raw/$name.png" -o "$OUT/$name.webp"
  echo "$name $(du -k "$OUT/$name.webp" | cut -f1) KB"
}

shot 01-glass PAGE=glass
shot 02-accent-dark PAGE=glass DARK=1 ACCENT=pink
shot 03-inputs PAGE=inputs
shot 04-selection PAGE=selection
shot 05-sheet PAGE=sheets OPEN=filters
shot 06-menu PAGE=selection OPEN=menu DARK=1
shot 07-feedback PAGE=feedback
shot 08-content PAGE=content DARK=1
shot 09-travel PAGE=travel
shot 10-foundation PAGE=foundation DARK=1
xcrun simctl status_bar "$SIM" clear
