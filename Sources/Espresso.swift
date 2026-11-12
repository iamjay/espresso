import AppKit
import IOKit.pwr_mgt
import ServiceManagement

/// Holds a "PreventUserIdleDisplaySleep" power assertion — the same kind a
/// video player takes while playing — so the display stays on and the
/// screensaver never kicks in.
final class VideoPlayingLock {
    private var assertionID: IOPMAssertionID = 0
    private(set) var isHeld = false

    @discardableResult
    func acquire() -> Bool {
        guard !isHeld else { return true }
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Espresso: video playing" as CFString,
            &assertionID
        )
        isHeld = (result == kIOReturnSuccess)
        return isHeld
    }

    func release() {
        guard isHeld else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isHeld = false
    }

    deinit { release() }
}

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let lock = VideoPlayingLock()
    private var statusItem: NSStatusItem!
    private let toggleItem = NSMenuItem(title: "", action: #selector(toggle), keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLoginItem), keyEquivalent: "")

    private static let activeKey = "active"

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // menu bar only, no Dock icon
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let menu = NSMenu()
        toggleItem.target = self
        loginItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(loginItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Espresso", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu

        // Default to active on first launch; afterwards remember the last choice.
        UserDefaults.standard.register(defaults: [Self.activeKey: true])
        if UserDefaults.standard.bool(forKey: Self.activeKey) { lock.acquire() }
        refresh()
    }

    func applicationWillTerminate(_ notification: Notification) {
        lock.release()
    }

    @objc private func toggle() {
        if lock.isHeld {
            lock.release()
        } else if !lock.acquire() {
            NSSound.beep()
        }
        UserDefaults.standard.set(lock.isHeld, forKey: Self.activeKey)
        refresh()
    }

    @objc private func toggleLoginItem() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        refresh()
    }

    private func refresh() {
        let active = lock.isHeld
        let symbol = active ? "cup.and.saucer.fill" : "cup.and.saucer"
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: active ? "Espresso: awake" : "Espresso: idle")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.appearsDisabled = !active
        statusItem.button?.toolTip = active ? "Espresso — screensaver blocked" : "Espresso — screensaver allowed"

        toggleItem.title = active ? "Allow Screensaver" : "Block Screensaver"
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }
}
