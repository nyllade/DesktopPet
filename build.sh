#!/bin/sh
set -eu

APP="DesktopPet/DesktopPet.app"
BIN="$APP/Contents/MacOS/DesktopPet"

mkdir -p "$APP/Contents/MacOS"

clang -fobjc-arc \
  -framework Cocoa \
  -framework IOKit \
  DesktopPet/Sources/main.m \
  -o "$BIN"

plutil -lint "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"

echo "Built $APP"
