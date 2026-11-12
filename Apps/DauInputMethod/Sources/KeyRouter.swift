import AppKit
import Carbon

/// What the controller does with one key-down event, decided from the event fields only.
/// Pure function so it can be unit tested without IMK (DauInputMethodTests).
enum KeyRoute: Equatable {
    /// Reset the engine and let the app handle the key: ⌘/⌃/⌥ shortcuts, arrows, Esc,
    /// navigation and function keys, dead keys, multi-character events (D4, D18).
    case ignore
    /// Delete key: `VietEngine.backspace()` (D32). 0x7F is never fed to `handle`.
    case backspace
    /// Return, Tab, keypad Enter: `VietEngine.endWord()`, then the app handles the key
    /// itself (a chat app must still send the message on Return).
    case endWord
    /// A character produced by the keyboard layout: `VietEngine.handle(_:)`.
    case character(Unicode.Scalar)
}

enum KeyRouter {
    // Virtual key codes (HIToolbox/Events.h, layout independent).
    static let keyReturn: UInt16 = 0x24
    static let keyTab: UInt16 = 0x30
    static let keyDelete: UInt16 = 0x33
    static let keyEscape: UInt16 = 0x35
    static let keyKeypadEnter: UInt16 = 0x4C
    static let keyForwardDelete: UInt16 = 0x75
    static let keyHome: UInt16 = 0x73
    static let keyEnd: UInt16 = 0x77
    static let keyPageUp: UInt16 = 0x74
    static let keyPageDown: UInt16 = 0x79
    static let keyLeft: UInt16 = 0x7B
    static let keyRight: UInt16 = 0x7C
    static let keyDown: UInt16 = 0x7D
    static let keyUp: UInt16 = 0x7E

    /// Modifiers that turn a key into a shortcut or an alternate character: reset only (D4).
    static let shortcutModifiers: NSEvent.ModifierFlags = [.command, .control, .option]

    /// - Parameters:
    ///   - characters: `NSEvent.characters`, read only for key-down events (it throws for
    ///     other event types). nil or empty for dead keys.
    static func route(keyCode: UInt16, modifiers: NSEvent.ModifierFlags, characters: String?) -> KeyRoute {
        if !modifiers.intersection(shortcutModifiers).isEmpty { return .ignore }
        switch keyCode {
        case keyDelete:
            return .backspace
        case keyReturn, keyTab, keyKeypadEnter:
            return .endWord
        case keyEscape, keyForwardDelete, keyHome, keyEnd, keyPageUp, keyPageDown,
             keyLeft, keyRight, keyDown, keyUp:
            return .ignore
        default:
            break
        }
        guard let characters else { return .ignore }
        var scalars = characters.unicodeScalars.makeIterator()
        guard let scalar = scalars.next(), scalars.next() == nil else { return .ignore }
        // Control characters and the private-use range AppKit uses for function keys
        // (NSUpArrowFunctionKey…) reset; the engine would do the same, but routing them
        // here keeps the cursor tracker honest.
        let v = scalar.value
        if v < 0x20 || v == 0x7F || (v >= 0xF700 && v <= 0xF8FF) { return .ignore }
        return .character(scalar)
    }
}

/// D18 (Phòng thủ với IMK): runs everything that touches a controller's typing state
/// (keys, resets, commits, settings reloads) one at a time, never one inside another.
///
/// `DauInputController` passes its engine and composers `inout` while it handles a key,
/// resets or commits, including the client calls made inside (`insertText`,
/// `selectedRange`, `setMarkedText`, which are synchronous). If the client called back
/// into the controller during one of them (`commitComposition`, `deactivateServer`, a
/// notification delivered by a nested run loop), the nested call would touch the same
/// properties while they are borrowed: Swift's exclusivity check traps ("Simultaneous
/// accesses"). This applies to a key and equally to a reset that commits the underlined
/// word (`insertText`). Whether IMK ever calls back like this is not measured; holding
/// such calls back costs a flag.
///
/// `run` and `key` mark the controller busy around their body. A call that arrives while
/// it is busy is kept and runs right after the current body, still marked busy, in the
/// order the calls came; calls those make are kept the same way, so nothing nests and
/// nothing recurses. A key that arrives while busy is not handled (`key` returns nil).
///
/// A reference type: the controller keeps one for its life and the bodies run while no
/// property of this object is borrowed. Unit tested in DauInputMethodTests.
final class KeyReentry {
    /// A body (key, reset, reload) is running.
    private(set) var isBusy = false
    private var deferred: [() -> Void] = []

    /// Runs `body` now, or after the body that is running when busy.
    func run(_ body: @escaping () -> Void) {
        guard !isBusy else {
            deferred.append(body)
            return
        }
        isBusy = true
        body()
        drain()
        isBusy = false
    }

    /// Handles a key with `body` and returns its result; nil when busy (the client sent a
    /// key from inside a client call): the caller lets that key go to the app untouched.
    func key(_ body: () -> Bool) -> Bool? {
        guard !isBusy else { return nil }
        isBusy = true
        let result = body()
        drain()
        isBusy = false
        return result
    }

    /// Runs the calls kept while busy, oldest first, including those they keep in turn.
    private func drain() {
        while !deferred.isEmpty {
            let next = deferred.removeFirst()
            next()
        }
    }
}

/// Whether a `kTISNotifySelectedKeyboardInputSourceChanged` notification ends the word
/// (D4: reset, no restore; `DauInputController.inputSourceDidChange`).
///
/// The notification is a distributed notification: any process can post it, as often as
/// it likes, and it carries nothing that says what changed. Taken alone, a process
/// posting it in a loop would end every word typed. So the controller remembers the
/// input source it saw last (at activation and at each notification) and reads the
/// current one when a notification comes: only a real switch ends the word.
///
/// A real switch away and back (U.S. then Dấu, `TISSelectInputSource` from another
/// process, which IMK does not report) gives two notifications; the first one finds
/// U.S. current, which is not Dấu, and ends the word (D4). Both arriving only after the
/// switch back (two switches within the delivery time of one notification) would find
/// Dấu both times and keep the word; no person switches that fast.
///
/// Pure, unit tested in DauInputMethodTests.
enum InputSourceChange {
    /// - Parameters:
    ///   - previous: the source ID seen last, nil if unknown.
    ///   - current: the source ID now, nil if it could not be read.
    ///   - ownBundleID: this input method's bundle ID; its input modes are
    ///     `<bundle ID>.<mode>` (D24).
    /// - Returns: true when the word must end: the current source is unknown (nothing
    ///   can be told, so as before), not Dấu, or not the one seen last.
    static func endsWord(previous: String?, current: String?, ownBundleID: String?) -> Bool {
        guard let current, let ownBundleID, isOwn(current, bundleID: ownBundleID) else { return true }
        guard let previous else { return true }
        return previous != current
    }

    /// `sourceID` is this input method or one of its modes (`….Dau.vi`, D24).
    static func isOwn(_ sourceID: String, bundleID: String) -> Bool {
        !bundleID.isEmpty && (sourceID == bundleID || sourceID.hasPrefix(bundleID + "."))
    }

    /// The ID of the selected keyboard input source (for Dấu, its input mode), or nil.
    /// One TIS read, at activation and at a change notification, never per key (N3).
    static func currentSourceID() -> String? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { return nil }
        let id = Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
        return id.isEmpty ? nil : id
    }
}

/// Which client session work queued for later belongs to (D43: the fix sent after the key,
/// the bundle read off the main thread). Advanced at every activation, deactivation, close
/// and client change; work whose epoch is no longer current is dropped, so it never reaches
/// another client or another activation.
struct ClientEpoch: Equatable {
    private(set) var value = 0

    mutating func advance() { value &+= 1 }

    func isCurrent(_ epoch: Int) -> Bool { epoch == value }
}
