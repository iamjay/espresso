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

## Build and install

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

The build script compiles `Sources/Espresso.swift` for your Mac's architecture, writes the `Info.plist`, and ad-hoc signs the bundle. Install it to `/Applications` before you turn on **Launch at Login** so the login item points at a stable location.

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
- The app is ad-hoc signed, not notarized. It's meant to be built and run on your own Mac.

## Project layout

```
Sources/Espresso.swift   The whole app: power assertion wrapper and menu bar UI
build.sh                 Builds, signs and optionally installs Espresso.app
```
