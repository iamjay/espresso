# Espresso

A tiny macOS menu bar app that keeps your screensaver from starting and your display from sleeping.

Espresso holds a `PreventUserIdleDisplaySleep` power assertion, the same lock a video player holds during playback. While it's on, macOS treats the Mac as busy and won't start the screensaver or turn off the display when you're idle.

## Features

- **One-click toggle.** A coffee cup in the menu bar: filled means the screensaver is blocked, outlined means it's allowed.
- **Remembers your choice.** Espresso is on the first time you launch it. After that, it starts in whatever state you left it.
- **Launch at Login.** Turn it on from the menu. It uses `SMAppService`, so it shows up under System Settings → General → Login Items.
- **Menu bar only.** No Dock icon and no windows.

## Requirements

- macOS 13 Ventura or later
- Xcode Command Line Tools for `swiftc` and `codesign` (install with `xcode-select --install`)

## Install from a release

1. Download `Espresso-<version>.dmg` from the Releases page.
2. Open it and drag **Espresso** onto **Applications**.
3. Open Espresso from Applications. Because the app is not notarized, macOS blocks it the first time. Go to **System Settings → Privacy & Security**, scroll down to the message about Espresso, and click **Open Anyway**.

If you prefer the terminal, you can clear the quarantine flag instead:

```bash
xattr -dr com.apple.quarantine /Applications/Espresso.app
```

## Build from source

Build the app into `build/Espresso.app`:

```bash
./build.sh
```

Build it and copy it to `/Applications`:

```bash
./build.sh install
```

Then open it:

```bash
open /Applications/Espresso.app
```

Build it and package it as `build/Espresso-<version>.dmg` for distribution:

```bash
./build.sh dmg
```

The build script compiles `Sources/Espresso.swift` as a universal binary (Apple Silicon and Intel), writes the `Info.plist`, and ad-hoc signs the bundle. The version number is set by `VERSION` at the top of `build.sh`. Install it to `/Applications` before you turn on **Launch at Login** so the login item points at a stable location.

## Usage

Click the cup in the menu bar:

| Menu item | What it does |
| --- | --- |
| **Allow Screensaver** / **Block Screensaver** | Releases or takes the power assertion |
| **Launch at Login** | Starts Espresso when you log in (checked when enabled) |
| **Quit Espresso** (⌘Q) | Releases the assertion and quits |

If macOS refuses the assertion, Espresso beeps and stays off.

To check that it's working, look for Espresso in the list of active assertions:

```bash
pmset -g assertions | grep Espresso
```

## Limitations

- Espresso only blocks the *idle* screensaver and display sleep. Locking the screen yourself, hot corners, and closing the lid still work as usual.
- The app is ad-hoc signed, not notarized, so Gatekeeper asks you to approve it the first time you open a downloaded copy (see [Install from a release](#install-from-a-release)).

## Project layout

```
Sources/Espresso.swift   The whole app: power assertion wrapper and menu bar UI
build.sh                 Builds and signs Espresso.app, then optionally installs it or packages a .dmg
```
