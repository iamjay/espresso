#!/bin/zsh
# Builds Espresso.app into ./build. Run `./build.sh install` to also copy it to /Applications.
set -euo pipefail
cd "${0:A:h}"

APP=build/Espresso.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

swiftc -O -parse-as-library \
  -target "$(uname -m)-apple-macos13.0" \
  -o "$APP/Contents/MacOS/Espresso" \
  Sources/Espresso.swift

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Espresso</string>
  <key>CFBundleDisplayName</key><string>Espresso</string>
  <key>CFBundleIdentifier</key><string>local.espresso</string>
  <key>CFBundleExecutable</key><string>Espresso</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $APP"

if [[ "${1:-}" == "install" ]]; then
  rm -rf /Applications/Espresso.app
  cp -R "$APP" /Applications/
  echo "Installed to /Applications/Espresso.app"
fi
