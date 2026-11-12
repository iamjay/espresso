#!/bin/zsh
# Builds a universal (Apple Silicon + Intel) Espresso.app into ./build.
#   ./build.sh           build only
#   ./build.sh install   also copy it to /Applications
#   ./build.sh dmg       also package it as build/Espresso-<version>.dmg
set -euo pipefail
cd "${0:A:h}"

VERSION=1.0
APP=build/Espresso.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" build/obj

for arch in arm64 x86_64; do
  swiftc -O -parse-as-library \
    -target "$arch-apple-macos13.0" \
    -o "build/obj/Espresso-$arch" \
    Sources/Espresso.swift
done
lipo -create -output "$APP/Contents/MacOS/Espresso" build/obj/Espresso-arm64 build/obj/Espresso-x86_64

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Espresso</string>
  <key>CFBundleDisplayName</key><string>Espresso</string>
  <key>CFBundleIdentifier</key><string>local.espresso</string>
  <key>CFBundleExecutable</key><string>Espresso</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $APP"

case "${1:-}" in
  install)
    rm -rf /Applications/Espresso.app
    cp -R "$APP" /Applications/
    echo "Installed to /Applications/Espresso.app"
    ;;
  dmg)
    DMG="build/Espresso-$VERSION.dmg"
    STAGING=build/dmg
    rm -rf "$STAGING" "$DMG"
    mkdir -p "$STAGING"
    ditto "$APP" "$STAGING/Espresso.app"
    ln -s /Applications "$STAGING/Applications"
    hdiutil create -volname Espresso -srcfolder "$STAGING" -fs HFS+ -format UDZO -ov "$DMG" >/dev/null
    rm -rf "$STAGING"
    echo "Packaged $DMG"
    ;;
esac
