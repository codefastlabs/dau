import Foundation
import DauEngine

/// The client calls in-place mode makes. `IMKTextInput` in the input method (through a
/// timing wrapper), a scripted fake document in the unit tests.
protocol InPlaceClient {
    func selectedRange() -> NSRange
    /// Plain text of `range` in the document (`attributedSubstring(from:)`), or nil if
    /// the client gives none. Called for the reads N3 allows: D20, D11, and the D43
    /// evidence.
    func text(in range: NSRange) -> String?
    func insertText(_ text: String, replacementRange: NSRange)
}

/// In-place mode (method A, D11): the word being typed is replaced in the document with
/// one `insertText(_:replacementRange:)` per key, at the position `selectedRange` gives.
///
/// Calls per key (N3):
/// - key that passes through: none;
/// - key whose result only appends at the cursor: one `insertText` (replacementRange
///   NSNotFound), no `selectedRange`;
/// - key that replaces text before the cursor: one `selectedRange`, one `insertText`;
///   Backspace (D32) that re-places the tone also does, and is still left to the app,
///   whose own Delete removes the last character (see `handle`); when the answer is not
///   where this composer followed the cursor to, one `text(in:)` too, the D11 read on a
///   mismatch (N3), which also tells an app that answers late (`replace`);
/// - D20 "Thêm dấu cho từ đã gõ" (see `addMarks`): on a tone or transform key, or a
///   plain letter (D20, "Chữ cái gõ sát chữ có sẵn"), typed with no word in the
///   engine and an unknown text before the cursor, one `selectedRange` and one `text(in:)` (attributedSubstring), then at most
///   one `insertText` (none when the system already changed the word that way, D20 "Từ
///   hệ thống vừa sửa", `isSystemFix`);
/// - D43: at the one key where the positions are enough to take the client for one that
///   ignores the range, one `text(in:)` more (`confirmRangeIgnore`), at most once per
///   activation.
///
/// Pure value type over `InPlaceClient`, no IMK, unit tested in DauInputMethodTests.
struct InPlaceComposer {
    /// D20 on (`DauSettings.addMarksToTypedWords`, D15 default on). Set from the shared
    /// settings at activation and on change, never read per key from the store.
    var addMarksEnabled = true

    /// D43 (Ô bỏ qua vùng thay chữ): the client takes the text of `insertText` but ignores
    /// `replacementRange` and sends the text to a terminal as typed (Ghostty, xterm.js).
    /// A replacement is then DEL (U+007F) per character to remove, then the new text, at
    /// the cursor: the program in the terminal erases and retypes. No `selectedRange`, no
    /// reads (D11 check, D20) for this client. Set by `detector` for the rest of the
    /// activation (`activate`).
    enum EraseMode: Equatable {
        case off
        /// One `insertText` while the key is handled: right in xterm.js; Ghostty drops IME
        /// text that starts with a control character there.
        ///
        /// D43: never chosen for a client `detector` finds (`eraseMode(for:)`): an xterm.js
        /// terminal shares one IMK client with the editors of its page (VS Code, Cursor,
        /// the Claude app), and a click between them reaches no input method, so DEL
        /// would reach the editor (`SharedViewTests`). Set only by the tests of the
        /// measured page (`XtermPageTests`).
        ///
        /// xterm.js (5.5.0, src/browser/input/CompositionHelper.ts) gets such a key as a
        /// keydown with keyCode 229 and sends its hidden textarea's new value minus the
        /// old one (`_handleAnyTextareaChanges`: `newValue.replace(oldValue, '')`), right
        /// only while the caret is at the end of that textarea (emptied on Return; a
        /// replacement with a range leaves text after the caret). So:
        /// - the key is consumed whenever text is sent (a Delete let through would reach
        ///   the page as a real keydown too, in an order the page decides), and Return or
        ///   Tab send nothing (the real keydown would come before the fix);
        /// - one unit at the cursor that is not the key's own character goes as
        ///   `x DEL x` (`insertAtCursor`): one unit takes Chromium's plain keydown path,
        ///   on which xterm.js sends the key typed, not the text.
        /// docs/research/TerminalAndUnderline.md section 2.
        case inKey
        /// The key goes to the app, then the fix is sent once the app has handled it
        /// (`Outcome.deferredText`, `RangeIgnoreDetector.Send.afterKey`): Ghostty sends
        /// text inserted outside its key handling as is, and sends a key the input method
        /// consumed without text anyway. The fix also erases what the key did.
        case afterKey
    }
    var eraseMode = EraseMode.off
    var eraseByDelete: Bool { eraseMode != .off }

    /// The erase mode for a client `detector` found, or nil to keep replacing in place.
    /// D43: a field told apart as xterm.js (`.inKey`) is replaced in place like any field,
    /// never with DEL: no DEL may reach an editor sharing its IMK client (see
    /// `EraseMode.inKey`).
    func eraseMode(for send: RangeIgnoreDetector.Send) -> EraseMode? {
        switch send {
        case .afterKey: return .afterKey
        case .inKey: return nil
        }
    }
    /// Tells a client that ignores `replacementRange` from the `selectedRange` answers
    /// (D43); sets `eraseMode`.
    private(set) var detector = RangeIgnoreDetector()
    /// Units the current key changed the document by through this composer's
    /// `insertText` calls (the key's own effect, if it goes to the app, is added after).
    private var keyDelta = 0
    /// What the current key does in the app if it goes there: +1 a typed character, -1
    /// Delete; nil for other keys (Return runs the line: never sent before the fix).
    private var keyEffect: Int?
    /// The character of the current key (`EraseMode.inKey`, `insertAtCursor`).
    private var keyScalar: Unicode.Scalar?

    /// What the cursor is known to follow while the engine has no word (D20 needs a word
    /// right before the cursor; reading costs two client calls, so it is skipped when
    /// the answer is already known).
    enum Before: Equatable {
        /// Anything: start of a session, after a reset (click, arrows, shortcuts,
        /// mismatch), after Backspace or Return/Tab left the word.
        case unknown
        /// Not a letter: the last key was a word-ending character typed here, or a D20
        /// read just found no word.
        case noWord
    }

    private(set) var tracker = CursorTracker()
    private(set) var before = Before.unknown
    /// The client gave no text (or no position) for a D20 read: do not ask again until
    /// the next activation (`activate`), N3.
    private(set) var readUnavailable = false
    /// The current word was already checked against the app's text (D11, once per word).
    private var checkedLockedWord = false
    /// Time of the previous key or click on this client (`NSEvent.timestamp`, seconds).
    private var lastEventTime: TimeInterval?
    /// The read `replace` made at the app's answer this key (location, text or nil if it
    /// gave none), reused by the D11 re-sync so a key reads at most once (N3).
    private var lateRead: (location: Int, text: String?)?

    /// D20 "Từ hệ thống vừa sửa": the last word this composer produced, as it was when a
    /// word-ending character typed here ended it. macOS autocorrect may change it right
    /// after that character ("hoc" → "học"); a mark key after one ⌫ over the character
    /// then compares the word read with it (`seedWord`). Kept for exactly the next key,
    /// plus one ⌫ in between: any other key, a reset (click, arrows, shortcuts, source
    /// change) or an activation forgets it. Not set for a word that ends still showing the
    /// letter of a double key (D26) or that D4 restored.
    struct ProducedWord: Equatable {
        var word: [Unicode.Scalar]
        /// One ⌫ (over the word-ending character) came after the word.
        var backspaced = false
    }
    private(set) var produced: ProducedWord?
    /// The produced word the current key may compare with (a key right after the one ⌫).
    private var keyProduced: [Unicode.Scalar]?
    /// A key of the current word undid a mark by a double key (D26): how many characters
    /// the word showed right after it, the last being the key's. While that letter is
    /// shown, the word is not remembered as `produced` when it ends. A ⌫ that deletes it
    /// clears this, as it releases the engine's lock (D26: "carr⌫r" → "cả" ends like any
    /// other word).
    private var undidMarkLetters: Int?
    /// The word `seedWord` read for the current key (to tell a double key on it, D26).
    private var keySeededWord: [Unicode.Scalar]?

    /// UTF-16 units read before the cursor for D20: the longest word the engine tracks
    /// is 7 letters (D33), at most 13 scalars when decomposed (NFD: base + 2 marks on up
    /// to 3 vowels); one more shows whether the word goes on past the read.
    static let readLength = 16

    /// D20 reads only when the previous key or click on this client is at least this old.
    /// Apps that apply keys asynchronously (Chromium, Electron, terminals) answer
    /// `selectedRange`/`attributedSubstring` from a snapshot that can still miss the
    /// previous keys; a word read from such a snapshot could be replaced at the wrong
    /// place. M2 measured this read wrong below 10–20 ms between keys in Chrome, VS Code
    /// and Terminal. Trial 30/10/2026 with no wait (`docs/history/LogM0ToM4.md`, table
    /// "Số đo (M1–M3)", row "D20 không chờ"): no damage in five apps
    /// even at 0 ms, VS Code at 0 ms read a stale snapshot (no word found). 50 ms
    /// keeps a margin over the 20 ms seen in M2; a person going back to a word is slower.
    static let settleInterval: TimeInterval = 0.05

    /// Positions of the last replacement attempt of a key (Debug diagnostics).
    struct Attempt: Equatable {
        var deleteCount: Int
        var selection: NSRange
        var expected: Int?
        /// Where the composer followed the cursor to, across words (`CursorTracker.known`).
        var known: Int?
        var insertedLength: Int
        /// The `replacementRange` sent, or nil when nothing was sent.
        var replacement: NSRange?
    }

    struct Outcome: Equatable {
        /// Whether `handle` returns true (key consumed).
        var consumed = false
        var kind = PerfLog.Kind.pass
        var attempt: Attempt?
        /// D43, `EraseMode.afterKey`: text to insert at the cursor once the app has handled
        /// the key (the controller sends it on the next turn of the main queue).
        var deferredText: String?
        #if DEBUG
        /// Set when this key made a D20 read (Debug perf log).
        var d20: D20Trace?
        /// While a word seeded by a D20 read is being typed (including the key that
        /// seeded it): whether the displayed word differs from what an engine that never
        /// read the text would show (that word's letters after the seeded prefix). nil:
        /// no seeded word, or the key ended it.
        var seedDiffers: Bool?
        #endif
    }

    #if DEBUG
    /// What a D20 read did (Debug perf log only).
    struct D20Trace: Equatable {
        /// What triggered the read: a tone/transform key, or a plain letter (D20, "Chữ cái gõ sát chữ có sẵn").
        enum Trigger: String { case mark, letter }
        var trigger: Trigger
        /// The engine was seeded with the word read and kept it (a plain letter that does
        /// not join the word read is not counted: the word was discarded).
        var seeded: Bool
    }
    /// The word the last `seedWord` seeded.
    private var lastSeededWord: [Unicode.Scalar] = []
    /// An engine that never read the text, fed the keys of the seeded word, and that
    /// word: `Outcome.seedDiffers` compares the real engine with prefix + shadow.
    private var shadow: VietEngine?
    private var shadowPrefix: [Unicode.Scalar] = []
    #endif

    // MARK: - Session events

    /// Forget the word without restoring it (D4) and what precedes the cursor.
    mutating func reset(engine: inout VietEngine) {
        engine.reset()
        tracker.invalidate()
        before = .unknown
        checkedLockedWord = false
        produced = nil
        undidMarkLetters = nil
    }

    /// A click (or any non-key event that moves the cursor) at `time`.
    mutating func noteEvent(at time: TimeInterval?) {
        if let time { lastEventTime = time }
    }

    /// New activation (or another client): the client may give text again, and whether it
    /// ignores `replacementRange` is judged from the start (D43). The only place the
    /// verdict of `detector` is dropped: a click or a reset keeps it.
    mutating func activate() {
        readUnavailable = false
        lastEventTime = nil
        detector.reset()
        eraseMode = .off
        produced = nil
    }

    // MARK: - Keys

    /// One key in in-place mode. `time` is the event's timestamp (nil if unknown: then
    /// D20 does not wait for anything).
    mutating func handle(_ route: KeyRoute, time: TimeInterval?, engine: inout VietEngine,
                         client: some InPlaceClient) -> Outcome {
        handleKeyAndTrace(route, time: time, engine: &engine, client: client)
    }

    private mutating func handleKeyAndTrace(_ route: KeyRoute, time: TimeInterval?, engine: inout VietEngine,
                                            client: some InPlaceClient) -> Outcome {
        #if DEBUG
        // Feed the key to the unseeded shadow before the real engine changes (see seedDiffers).
        if shadow != nil {
            if case .character(let c) = route, engine.isComposing { _ = shadow?.handle(c) } else { shadow = nil }
        }
        var outcome = handleTracked(route, time: time, engine: &engine, client: client)
        if outcome.d20?.seeded == true, let plain = pendingShadow {
            shadow = plain
            shadowPrefix = lastSeededWord
        }
        pendingShadow = nil
        if let shadow, engine.isComposing, engine.lastShown != nil {
            // (D33's pass-through state tracks no letters: nothing to compare.)
            outcome.seedDiffers = engine.shown != shadowPrefix + shadow.shown
        } else {
            self.shadow = nil
        }
        return outcome
        #else
        return handleTracked(route, time: time, engine: &engine, client: client)
        #endif
    }

    /// `handleKey`, then what the key did to the word, for `detector` (D43).
    private mutating func handleTracked(_ route: KeyRoute, time: TimeInterval?, engine: inout VietEngine,
                                        client: some InPlaceClient) -> Outcome {
        keyDelta = 0
        keySeededWord = nil
        var shownBefore: [Unicode.Scalar]?
        if case .character = route, engine.lastShown != nil { shownBefore = engine.shown }
        if case .character = route, !engine.isComposing { undidMarkLetters = nil }  // a new word
        let outcome = handleKey(route, time: time, engine: &engine, client: client)
        // D26: remember that this word was un-toned by a double key, so it is not taken
        // for a word the system changed when it ends (`produced`), until a ⌫ deletes the
        // double key's letter.
        if case .character(let key) = route, engine.lastShown != nil,
           let prior = shownBefore ?? keySeededWord,
           Self.undidMark(before: prior, after: engine.shown, key: key) {
            undidMarkLetters = engine.shown.count
        }
        if case .backspace = route, let letters = undidMarkLetters, engine.shown.count < letters {
            undidMarkLetters = nil
        }
        guard !eraseByDelete else { return outcome }
        switch outcome.kind {
        case .mismatch, .unsupported, .resync, .resyncPass, .seed, .seedPass, .seedNone, .seedKept:
            // The composer started the word over at the app's cursor (D11, D20): the word
            // starts where this key was typed.
            detector.startWord()
        default:
            break
        }
        let own = outcome.consumed ? 0 : (keyEffect ?? 0)
        if !outcome.consumed, keyEffect != nil { detector.keyWentThrough(route) }
        detector.keyHandled(delta: keyDelta.addingSaturated(own), inBurst: tracker.keyInBurst)
        // The word ended, or the cursor may have moved (shortcut, arrow, Return/Tab).
        if outcome.kind == .reset || !engine.isComposing { detector.endWord() }
        return outcome
    }

    #if DEBUG
    private var pendingShadow: VietEngine?
    #endif

    private mutating func handleKey(_ route: KeyRoute, time: TimeInterval?, engine: inout VietEngine,
                                    client: some InPlaceClient) -> Outcome {
        let settled = isSettled(at: time)
        if let time { lastEventTime = time }
        lateRead = nil
        switch route {
        case .character: keyEffect = 1
        case .backspace: keyEffect = -1
        default: keyEffect = nil
        }
        if case .character(let c) = route { keyScalar = c } else { keyScalar = nil }
        // The edits of a key in a burst may all be missing from a late answer (`rebuild`).
        tracker.keyInBurst = !settled
        // D20 "Từ hệ thống vừa sửa": the produced word lasts for this key only (one ⌫
        // over the word-ending character keeps it for one key more, below).
        let lastProduced = produced
        produced = nil
        keyProduced = nil
        if case .character = route, let lastProduced, lastProduced.backspaced {
            keyProduced = lastProduced.word
        }

        switch route {
        case .ignore:
            // D4: shortcuts, arrows, Esc only reset; nothing is restored.
            reset(engine: &engine)
            return Outcome(kind: .reset)

        case .backspace:
            let wasComposing = engine.isComposing
            // The character the app's own Delete removes (see below).
            let lastShown = engine.lastShown
            let wordBefore = engine.isComposing ? engine.shown : nil
            var result = Outcome()
            switch engine.backspace() {
            case .passThrough:
                // The app deletes one character itself: a letter of the word, or with no
                // word, whatever precedes the cursor.
                if wasComposing {
                    tracker.backspacePassedThrough()
                } else {
                    tracker.backspaceOutsideWord()
                }
            case .replace(let deleteCount, let insert):
                // D32 re-places the tone ("hoà" ⌫ → "hò"). Chromium and Electron run
                // their own Delete for this key even when the input method consumes it
                // (the raw key-down goes to the page after the input method's text;
                // docs/history/CompatibilityFixed.md), so a consumed ⌫ lost one letter more there
                // ("h"). So the key is never consumed: every app deletes the last
                // character itself, and the replacement puts that character back at the
                // end ("hoà" → "hòà" → app's Delete → "hò"). Same calls as before (N3).
                // A decomposed (NFD) last character, possible only on a word seeded by
                // D20 and not yet rewritten, may be deleted mark by mark: no guess.
                if let lastShown, lastShown.properties.generalCategory != .nonspacingMark, deleteCount >= 1 {
                    result = replace(deleteCount: deleteCount, insert: insert, appending: lastShown,
                                     selection: nil, client: client, word: wordBefore)
                } else {
                    result.kind = .reset
                }
                // D43 in the key (xterm.js): the fix leaves out the letter Delete would
                // remove and the key is consumed (`EraseMode.inKey`, `erase`).
                result.consumed = result.kind == .erase && eraseMode == .inKey
                if result.kind == .replace || result.kind == .late || result.kind == .lateGuess
                    || result.kind == .erase {
                    tracker.backspacePassedThrough()
                } else {
                    // Let the app's own Delete run; the engine no longer knows the word.
                    reset(engine: &engine)
                }
            }
            if !engine.isComposing {
                // The position stays known: Delete removed a character this composer
                // knows (see `CursorTracker.backspaceOutsideWord`), or it forgot it.
                tracker.endWord()
                before = .unknown
                checkedLockedWord = false
            }
            if !wasComposing, let lastProduced, !lastProduced.backspaced {
                // The one ⌫ over the character that ended the produced word.
                produced = ProducedWord(word: lastProduced.word, backspaced: true)
            }
            return result

        case .endWord:
            // Return, Tab, keypad Enter: restore the word if needed (D4), then let the app
            // handle the key itself (send a message, move focus…).
            var result = Outcome()
            let wordBefore = engine.isComposing ? engine.shown : nil
            if case .replace(let deleteCount, let insert) = engine.endWord() {
                result = replace(deleteCount: deleteCount, insert: insert, selection: nil, client: client,
                                 word: wordBefore)
            }
            // What the app does with the key is unknown (Tab may focus another field).
            reset(engine: &engine)
            result.consumed = false
            return result

        case .character(let scalar):
            if !engine.isComposing, addMarksEnabled, !eraseByDelete, before == .unknown, !readUnavailable, settled {
                let method = engine.options.inputMethod
                if Self.isMarkKey(scalar, method: method) {
                    return addMarks(scalar, letter: false, engine: &engine, client: client)
                }
                // D20, "Chữ cái gõ sát chữ có sẵn": a plain letter reads too, and
                // joins the word read only if the result is still a valid prefix.
                if Self.isLetter(scalar) {
                    return addMarks(scalar, letter: true, engine: &engine, client: client)
                }
            }
            if !eraseByDelete, engine.isSpellingLocked, !checkedLockedWord, !readUnavailable, settled,
               Self.isMarkKey(scalar, method: engine.options.inputMethod),
               let outcome = checkLockedWord(scalar, engine: &engine, client: client) {
                return outcome
            }
            return character(scalar, selection: nil, settled: settled, engine: &engine, client: client)
        }
    }

    private func isSettled(at time: TimeInterval?) -> Bool {
        guard let time, let last = lastEventTime else { return true }
        return time - last >= Self.settleInterval || time < last
    }

    /// Tone and transform keys of the typing method (D20 applies to both): Telex and
    /// Telex đơn giản s f r x j z a e o w d (any case, D34), VNI digits.
    static func isMarkKey(_ scalar: Unicode.Scalar, method: EngineOptions.InputMethod) -> Bool {
        let v = scalar.value
        switch method {
        case .vni:
            return v >= 0x30 && v <= 0x39
        case .telex, .simpleTelex:
            guard v < 0x80 else { return false }
            let lower = (v >= 0x41 && v <= 0x5A) ? v + 0x20 : v
            return "sfrxjzaeowd".unicodeScalars.contains { $0.value == lower }
        }
    }

    /// ASCII letters, any case: the plain letters that also make a D20 read when
    /// they are not mark keys of the typing method.
    static func isLetter(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (v >= 0x41 && v <= 0x5A) || (v >= 0x61 && v <= 0x7A)
    }

    /// The engine's word is still a valid prefix (D30) after a key: not locked by spelling,
    /// and not past the longest syllable (D33 overflow: the engine still composes but
    /// tracks no letters, so `lastShown` is nil).
    static func isValidPrefix(_ engine: VietEngine) -> Bool {
        !engine.isSpellingLocked && engine.lastShown != nil
    }

    /// A character with the engine's word (if any).
    /// `settled`: the previous key or click is old enough to read the client's text
    /// (`settleInterval`); a mismatch may then re-sync from the text (D11).
    private mutating func character(_ scalar: Unicode.Scalar, selection: NSRange?, settled: Bool = false,
                                    engine: inout VietEngine, client: some InPlaceClient) -> Outcome {
        var result: Outcome
        let wordBefore = engine.isComposing ? engine.shown : nil
        // Consonant shortcuts (D21) also change the word at its end; a copy tells them
        // from a D4 restore (`producedWord`).
        let engineBefore: VietEngine? = engine.options.advanced == .consonantShortcuts && wordBefore != nil
            ? engine : nil
        let tracked = engine.lastShown != nil  // not D33's pass-through state
        let action = engine.handle(scalar)
        switch action {
        case .passThrough:
            tracker.passedThrough(String(Character(scalar)))
            result = Outcome()
        case .replace(let deleteCount, let insert):
            result = replace(deleteCount: deleteCount, insert: insert, selection: selection, client: client,
                             word: wordBefore)
            if result.kind == .mismatch, settled, !readUnavailable, let seen = result.attempt?.selection {
                // D11: the text changed behind the engine's back (a click the app did not
                // report, an autocomplete, an app edit). Read the word that is really
                // before the cursor and apply the key to it, as D20 does; same snapshot
                // as the selectedRange just asked, one more call, only on a mismatch
                // (the read `replace` already made to rule out a late answer, if any).
                let earlier = lateRead?.location == seen.location ? lateRead : nil
                reset(engine: &engine)
                // A read that gave nothing usable is not made again (N3).
                if earlier == nil || earlier?.text != nil,
                   let synced = seedWord(scalar, selection: seen, engine: &engine, client: client,
                                         alreadyRead: earlier?.text),
                   synced.kind == .seed || synced.kind == .seedPass {
                    var resynced = synced
                    resynced.kind = synced.kind == .seed ? .resync : .resyncPass
                    resynced.attempt = result.attempt
                    return resynced
                }
                engine.reset()
            }
            if result.kind == .mismatch || result.kind == .unsupported {
                // D11: the app's text is not what the engine thinks. Start over from
                // this key alone, so it still does the most it can on its own.
                reset(engine: &engine)
                switch engine.handle(scalar) {
                case .passThrough:
                    result.consumed = false
                case .replace(0, let insert):
                    insertAtCursor(insert, client: client)
                    result.consumed = true
                case .replace:
                    reset(engine: &engine)
                    result.consumed = false
                }
            }
        }
        if !engine.isComposing {
            // The key ended a word (or was punctuation with no word): it is now right
            // before the cursor. After a failed replacement, nothing is known.
            let failed = result.kind == .mismatch || result.kind == .unsupported
            if failed { tracker.invalidate() } else { tracker.endWord() }
            before = failed ? .unknown : .noWord
            checkedLockedWord = false
            if !failed, tracked, undidMarkLetters == nil, let wordBefore,
               let word = Self.producedWord(wordBefore, ending: scalar, action: action, engineBefore: engineBefore) {
                produced = ProducedWord(word: word)
            }
            undidMarkLetters = nil
        }
        return result
    }

    // MARK: - D20 "Từ hệ thống vừa sửa"

    /// The word left in the app when `key`, a word-ending character, ended `word` with
    /// `action`; nil when the key did not end it with a printable character, or when D4
    /// restored it (the user's keys, not a word to add marks to). `engineBefore`: the
    /// engine before the key when consonant shortcuts (D21) are on, to tell an expansion
    /// (remembered) from a restore.
    static func producedWord(_ word: [Unicode.Scalar], ending key: Unicode.Scalar, action: Action,
                             engineBefore: VietEngine?) -> [Unicode.Scalar]? {
        let v = key.value
        guard v >= 0x20, v != 0x7F, !(v >= 0xF700 && v <= 0xF8FF) else { return nil }
        switch action {
        case .passThrough:
            return word
        case .replace(let deleteCount, let insert):
            guard insert.last == key, deleteCount <= word.count else { return nil }
            // The word changed at its end: a D4 restore, unless the same engine without
            // consonant shortcuts leaves it as it is (then a D21 expansion did it).
            guard var plain = engineBefore else { return nil }
            plain.options.advanced = .off
            guard case .passThrough = plain.endWord() else { return nil }
            return Array(word.dropLast(deleteCount)) + insert.dropLast()
        }
    }

    /// D26 seen from the text: a key that removed a mark (tone, circumflex, breve, horn,
    /// đ) and put its own letter at the end of the word ("cả" + r → "car", "ô" + o → "oo",
    /// "đ" + d → "dd"). No other key does both: a tone change keeps the count, z removes a
    /// tone without adding a letter.
    static func undidMark(before: [Unicode.Scalar], after: [Unicode.Scalar], key: Unicode.Scalar) -> Bool {
        guard let last = after.last,
              String(Character(last)).lowercased() == String(Character(key)).lowercased() else { return false }
        return markCount(after) < markCount(before)
    }

    /// Marks in `word`: combining marks once decomposed, and the stroke of đ.
    static func markCount(_ word: [Unicode.Scalar]) -> Int {
        var count = 0
        for scalar in word {
            if scalar == "đ" || scalar == "Đ" { count += 1; continue }
            for part in String(Character(scalar)).decomposedStringWithCanonicalMapping.unicodeScalars
            where part.properties.generalCategory == .nonspacingMark {
                count += 1
            }
        }
        return count
    }

    /// D20 "Từ hệ thống vừa sửa": `shown`, the word read before the cursor, is what D20
    /// gives on `own` (the word this composer produced) with `key`, ignoring case, and
    /// is not `own` itself: the system changed the word after it was produced, the way
    /// this key would have ("hoc" shown as "học", then j). Engine only, no client call.
    static func isSystemFix(_ shown: [Unicode.Scalar], of own: [Unicode.Scalar], key: Unicode.Scalar,
                            options: EngineOptions) -> Bool {
        let read = string(shown).precomposedStringWithCanonicalMapping
        let mine = string(own)
        guard read != mine else { return false }
        var probe = VietEngine(options: options)
        guard probe.seed(displayed: own), case .replace = probe.handle(key) else { return false }
        return string(probe.shown).lowercased() == read.lowercased()
    }

    private static func string(_ scalars: [Unicode.Scalar]) -> String {
        var view = String.UnicodeScalarView()
        view.append(contentsOf: scalars)
        return String(view)
    }

    // MARK: - D11: a word that stopped being Vietnamese

    /// The engine's word is no longer a valid prefix (D30), so its keys pass through and
    /// nothing asks where the cursor is. That is also what a word looks like when the app
    /// replaced the text without telling the input method (⌘A in Chrome's address bar is
    /// a menu shortcut the input method never sees; a click it does not report): "tốt",
    /// ⌘A, "toots" grew "tốttoo…" and stayed "toots". On the first mark key of such a
    /// word, read the word before the cursor once: if it is not the engine's word, start
    /// over from the real text (as D20 seeds it) and apply the key. nil: the word is what
    /// the engine thinks, handle the key as usual.
    private mutating func checkLockedWord(_ scalar: Unicode.Scalar, engine: inout VietEngine,
                                          client: some InPlaceClient) -> Outcome? {
        checkedLockedWord = true
        let selection = Self.selectedRange(of: client)
        if let mode = detector.observe(selection, inBurst: tracker.keyInBurst),
           let found = confirmRangeIgnore(mode, client: client) {
            // D43: from this key on, the word's keys pass or are erased and typed again.
            eraseMode = found
            return nil
        }
        // A selection here is the app's: an autocomplete after the cursor, or text the user
        // selected with a shortcut the input method never saw (⌘A); the word before it is
        // what counts, the key replaces the selection either way.
        guard selection.location != NSNotFound, selection.length != NSNotFound,
              selection.location >= 0, selection.length >= 0 else { return nil }
        let count = min(selection.location, Self.readLength)
        var read: String?
        let real: [Unicode.Scalar]
        if count == 0 {
            real = []
        } else {
            guard let text = client.text(in: NSRange(location: selection.location - count, length: count)),
                  text.utf16.count == count else {
                readUnavailable = true
                return nil
            }
            read = text
            real = Self.trailingWord(text.precomposedStringWithCanonicalMapping)
        }
        if real == engine.shown {
            if tracker.known == nil, selection.length == 0 { tracker.anchor(at: selection.location) }
            return nil
        }
        // The app may answer from before the last keys of this word (Chrome with a busy
        // page, M6: at "deadline" + d the answer was one key behind "dea"): the word is
        // still the engine's if the text read plus those keys is.
        let shown = engine.shown
        if let read, tracker.rebuild(Array(read.utf16), at: selection, accept: { Self.word(in: $0) == shown }) != nil {
            return nil
        }
        // Not the engine's word: forget it, keep the "checked" mark for the new word only
        // if it stays locked, and seed from the real text.
        reset(engine: &engine)
        if let seeded = seedWord(scalar, selection: selection, engine: &engine, client: client, alreadyRead: read,
                                 allowSelection: true),
           seeded.kind == .seed || seeded.kind == .seedPass {
            var resynced = seeded
            resynced.kind = seeded.kind == .seed ? .resync : .resyncPass
            return resynced
        }
        // Nothing to seed (no word, or one the engine cannot track): the key starts a word.
        engine.reset()
        var outcome = character(scalar, selection: selection, engine: &engine, client: client)
        if outcome.kind == .pass { outcome.kind = .resyncPass }
        return outcome
    }

    // MARK: - D20 "Thêm dấu cho từ đã gõ"

    /// Reads the word right before the cursor, seeds the engine with it as displayed
    /// (`VietEngine.seed`), and lets the engine decide (D20): the key either changes the
    /// word in place (one `insertText`) or goes to the app unchanged. Reads nothing more
    /// than `readLength` UTF-16 units; any odd answer from the client means no seed and
    /// the key is handled as the first key of a new word (D18).
    ///
    /// `letter`: the key is a plain letter, not a mark key (D20 plain letter). Whether the key joins the
    /// word read follows D20 and its three exceptions (`SeedRule`), decided from the text
    /// already read before anything is sent to the client, so a key that does not join
    /// makes the same calls as an unseeded key after the read.
    private mutating func addMarks(_ scalar: Unicode.Scalar, letter: Bool = false, engine: inout VietEngine,
                                   client: some InPlaceClient) -> Outcome {
        #if DEBUG
        // The key alone on an empty engine: what the document would get without a seed.
        var plain = engine
        plain.reset()
        _ = plain.handle(scalar)
        pendingShadow = plain
        lastSeededWord = []
        #endif
        var selection = Self.selectedRange(of: client)
        detector.note(selection)
        var read: String?
        var didRead = false
        if let known = tracker.known, selection.length == 0, selection.location != NSNotFound,
           selection.location >= 0, selection.location != known, !tracker.edits.isEmpty {
            didRead = true
            // The app may answer from before the last Delete (Chrome with a busy page, M6:
            // "Hoc", Space, ⌫, j found no word and gave "Hocj"). Read once at its answer;
            // if that text with the edits it has not applied yet (each one's removed text
            // checked against what it read) ends where this composer followed the cursor
            // to, that is the text before the cursor.
            read = readBefore(selection.location, client: client)
            if let text = read,
               let rebuilt = tracker.rebuild(Array(text.utf16), at: selection,
                                             requireDeletedText: true, accept: { _ in true }) {
                let count = min(known, Self.readLength, rebuilt.count)
                read = String(decoding: rebuilt.suffix(count), as: UTF16.self)
                selection = NSRange(location: known, length: 0)
            }
        }
        if selection.length == 0, selection.location != NSNotFound, selection.location >= 0 {
            tracker.anchor(at: selection.location)
        }
        // A read that gave nothing usable is not made again (N3): no seed, as `seedWord`
        // does for such a read.
        var outcome = didRead && read == nil ? nil
            : seedWord(scalar, selection: selection, engine: &engine, client: client, alreadyRead: read,
                       rule: letter ? .letter : .mark)
        if outcome == nil {
            // Not seeded (or a key that does not join, D20): the key starts a word as
            // usual (never asks selectedRange again: with an empty engine a key never
            // replaces text before the cursor).
            engine.reset()
            outcome = character(scalar, selection: selection, engine: &engine, client: client)
            // The read happened (perf log): pass or insert at the cursor, nothing seeded.
            if outcome?.kind == .pass || outcome?.kind == .insert { outcome?.kind = .seedNone }
        }
        var traced = outcome ?? Outcome()
        #if DEBUG
        let seeded = traced.kind == .seed || traced.kind == .seedPass || traced.kind == .seedKept
        traced.d20 = D20Trace(trigger: letter ? .letter : .mark, seeded: seeded)
        #endif
        return traced
    }

    /// How `seedWord` decides whether the key joins the word read.
    enum SeedRule {
        /// D11: the engine's word is re-synced with the app's text; the key always
        /// applies to the word read.
        case resync
        /// D20, a tone or transform key typed first after a reset.
        case mark
        /// D20, a plain letter typed first after a reset ("Chữ cái gõ sát chữ có sẵn").
        case letter
    }

    /// The seeded path, or nil when nothing could be seeded.
    /// `alreadyRead`: the text of the same range, when the caller read it already (one
    /// read per key, N3). `allowSelection`: a selection after the word is an app's
    /// suggestion (D11), replaced with the word; D20 itself never seeds with a selection
    /// (the user selected text the key will replace).
    ///
    /// `rule` `.mark` or `.letter` (D20): every decision below uses the text already
    /// read, before any `insertText` (N3). nil means the caller handles the key as the
    /// first key of a new word.
    /// - Exception (b): a word that is not Vietnamese takes the key and the rest of the
    ///   word unchanged, whatever its case (camelCase: "foo" + B → "fooB"): one the
    ///   engine cannot seed (longer than 7 letters, D33, or letters it does not know)
    ///   goes to D33's pass-through state (`VietEngine.seedOverflow`); one already locked
    ///   by spelling (D30) stays seeded and locked ("foo" + bar → "foobar").
    /// - Exception (a), on a Vietnamese word: an upper-case key after a lower-case
    ///   letter starts a new word ("#Hà" + N → "#HàN…", "Hà" + O), unless it is a mark
    ///   key that places a tone or transform on the word (a replacement: "hoc" + J →
    ///   "học"). "VI" + E, "V" + i still join.
    /// - A letter on a Vietnamese word joins only if the word stays a valid prefix (D20 plain letter):
    ///   "q" + u → "qu", "tôi" + l starts a new word "l".
    /// - Exception (c): a mark key that is not applied to a Vietnamese word (the key
    ///   passes through and leaves the word locked or past 7 letters) starts a new word:
    ///   "anh" + e → "anhe…" as a new "e", "tôi" + d → new "d". A double key (D26) is
    ///   applied: "cả" + r → "car".
    private mutating func seedWord(_ scalar: Unicode.Scalar, selection: NSRange, engine: inout VietEngine,
                                   client: some InPlaceClient, alreadyRead: String? = nil,
                                   allowSelection: Bool = false, rule: SeedRule = .resync) -> Outcome? {
        if selection.location == NSNotFound || selection.length == NSNotFound {
            readUnavailable = true  // no document access: replacing could not work either
            return nil
        }
        guard selection.location >= 0, selection.length == 0 || allowSelection else { return nil }
        let location = selection.location
        if location == 0 {
            before = .noWord
            return nil
        }
        // `alreadyRead` ends at `location`; it is shorter than `readLength` only when it
        // was rebuilt from a late answer (`addMarks`).
        let count = alreadyRead.map { min($0.utf16.count, location) } ?? min(location, Self.readLength)
        let range = NSRange(location: location - count, length: count)
        if alreadyRead == nil && readUnavailable { return nil }
        guard let text = alreadyRead ?? client.text(in: range) else {
            readUnavailable = true
            return nil
        }
        // A different length means the range split a surrogate pair or the client
        // answered for another range (IMKInputSession.h): do not guess.
        guard text.utf16.count == count else { return nil }
        let word = Self.trailingWord(text)
        if word.isEmpty {
            before = .noWord
            return nil
        }
        let d20 = rule != .resync
        // The word may go on before what was read: too long to be one the engine tracks.
        if word.count == text.unicodeScalars.count && location > count {
            return d20 ? continueForeignWord(word, scalar, location: location, engine: &engine) : nil
        }
        // Every scalar the engine accepts is in the BMP, so its scalar counts are UTF-16
        // counts (deleteCount below); anything else is refused by `seed` anyway.
        guard word.allSatisfy({ $0.utf16.count == 1 }), engine.seed(displayed: word) else {
            return d20 ? continueForeignWord(word, scalar, location: location, engine: &engine) : nil
        }
        keySeededWord = word
        // D20 "Từ hệ thống vừa sửa": the system already made the word what this key
        // makes of the word this composer produced ("hoc" shown as "học", ⌫ j): keep the
        // text; the engine holds the word shown, so the next keys go on from it.
        if rule == .mark, let own = keyProduced,
           Self.isSystemFix(word, of: own, key: scalar, options: engine.options) {
            if engine.isSpellingLocked { checkedLockedWord = true }
            #if DEBUG
            lastSeededWord = word
            #endif
            return Outcome(consumed: true, kind: .seedKept)
        }

        let lockedBefore = engine.isSpellingLocked
        let action = engine.handle(scalar)
        // D20 (a): no upper-case letter inside a Vietnamese syllable; (b) wins on a word
        // locked before the key. A mark key that changed the word (a replacement that
        // deletes something) added no letter and keeps it.
        if d20, !lockedBefore, Self.startsNewWord(scalar, after: word) {
            var addsLetter = true
            if rule == .mark, case .replace(let deleteCount, _) = action, deleteCount > 0 { addsLetter = false }
            if addsLetter {
                engine.reset()
                return nil
            }
        }
        switch rule {
        case .resync:
            break
        case .letter:
            // D20 plain letter: "tôi" + l, "sắc" + m: the letter starts a new word. D20 (b): a word
            // locked before the key is not Vietnamese, the letter belongs to it.
            if !lockedBefore, !Self.isValidPrefix(engine) {
                engine.reset()
                return nil
            }
        case .mark:
            // D20 (c): "anh" + e, "tôi" + d: the key was not applied (passed through)
            // and the word stopped being Vietnamese: the key starts a new word.
            if !lockedBefore, !Self.isValidPrefix(engine), case .passThrough = action {
                engine.reset()
                return nil
            }
        }
        // The engine's word is the app's text: a word locked by spelling needs no D11
        // check against that text (`checkLockedWord`, one read per word).
        if engine.isSpellingLocked { checkedLockedWord = true }
        #if DEBUG
        lastSeededWord = word
        #endif
        switch action {
        case .passThrough:
            // D20 does not apply ("viet" + j → "vietj"): the app types the key. The
            // engine keeps the word, so the next keys continue it (D4 baseline = seed).
            tracker.didReplace(NSRange(location: location, length: 0), text: String(Character(scalar)), atCaret: true)
            return Outcome(consumed: false, kind: .seedPass)
        case .replace(let deleteCount, let insert):
            guard deleteCount <= word.count else {
                reset(engine: &engine)
                return Outcome(consumed: false, kind: .mismatch)
            }
            var result = replace(deleteCount: deleteCount, insert: insert, selection: selection, client: client)
            // `.insert`: the key only adds to the word read ("d" + w → "dư"), already
            // written at the cursor; handling the key again would write it twice.
            if result.kind == .replace || result.kind == .insert {
                result.kind = .seed
            } else {
                reset(engine: &engine)
                result.consumed = false
            }
            if !engine.isComposing { tracker.invalidate() }
            return result
        }
    }

    /// D20 exception (a): the key is an upper-case letter and the word read ends with a
    /// lower-case one ("#Hà" + N). Upper case after upper case ("VI" + E) or lower case
    /// after upper case ("V" + i) may still join. The caller applies it only to a
    /// Vietnamese word, and not to a mark key that changes the word (`seedWord`).
    static func startsNewWord(_ key: Unicode.Scalar, after word: [Unicode.Scalar]) -> Bool {
        guard Character(key).isUppercase else { return false }
        var view = String.UnicodeScalarView()
        view.append(contentsOf: word)
        // The last character, not scalar: decomposed text (NFD) ends with a mark.
        return String(view).last?.isLowercase == true
    }

    /// D20 exception (b) for a word `seed` cannot take: if it is all letters (not
    /// Vietnamese: longer than 7 letters, D33, or letters the engine does not know), the
    /// key and the rest of the word pass through unchanged (D33's state,
    /// `VietEngine.seedOverflow`) until the word ends. nil: not letters ("abc123"), the
    /// key starts a new word as before.
    private mutating func continueForeignWord(_ word: [Unicode.Scalar], _ scalar: Unicode.Scalar, location: Int,
                                              engine: inout VietEngine) -> Outcome? {
        guard word.allSatisfy({ CharacterSet.letters.contains($0) }) else {
            engine.reset()
            return nil
        }
        var view = String.UnicodeScalarView()
        view.append(contentsOf: word)
        // Characters, as the app's Delete removes them: ⌫ over the whole word ends the
        // state (D33). Fewer than the real word when the read is cut (16 UTF-16 units):
        // the state then ends early and the next key reads again.
        engine.seedOverflow(shown: String(view).count)
        guard case .passThrough = engine.handle(scalar) else {
            engine.reset()
            return nil
        }
        #if DEBUG
        lastSeededWord = word
        #endif
        tracker.didReplace(NSRange(location: location, length: 0), text: String(Character(scalar)), atCaret: true)
        return Outcome(consumed: false, kind: .seedPass)
    }

    /// The letters (with combining marks, digits) at the end of `text`.
    static func trailingWord(_ text: String) -> [Unicode.Scalar] {
        var word: [Unicode.Scalar] = []
        for scalar in text.unicodeScalars.reversed() {
            guard CharacterSet.alphanumerics.contains(scalar) else { break }
            word.append(scalar)
        }
        word.reverse()
        return word
    }

    // MARK: - Client calls

    /// The client's `selectedRange`, the only way in-place mode asks for it: an answer
    /// outside `ClientRange.limit` (negative, huge) is NSNotFound from here on (D18), so
    /// no position past the limit reaches any arithmetic below or in `CursorTracker`.
    static func selectedRange(of client: some InPlaceClient) -> NSRange {
        ClientRange.sanitized(client.selectedRange())
    }

    /// Applies `.replace` with exactly one `insertText` call (N3). D11: ask the
    /// client for `selectedRange` when text before the cursor must be replaced, unless
    /// this key already asked (`selection`).
    /// `appending`: one more scalar after `insert` (Backspace, see `handle`).
    ///
    /// `word`: the engine's word before this key, when the key may be checked against an
    /// app that answers late. If `selectedRange` is not where this composer followed the
    /// cursor to (`CursorTracker.known`), the app may not have applied the latest edits
    /// yet (Chrome with a busy page, M6: the first replacement of a word took "ba" for
    /// "an" in "bạn" and gave "ạnn"; Chrome, VS Code, Firefox with keys in a burst, M3).
    /// One read at the app's answer (the D11 read on a mismatch, N3), whatever the time
    /// since the previous key: if that text plus the edits it has not applied is `word`
    /// (`CursorTracker.rebuild`), the key replaces at the followed position; the app
    /// applies the replacement after those edits, as it applies everything in order.
    /// Otherwise the answer stands: a mismatch inside a word (D11, re-read only after
    /// `settleInterval`), or the start of a word, where the app may have edited the text
    /// (autocorrect, smart dashes).
    private mutating func replace(deleteCount: Int, insert: TextBuffer, appending extra: Unicode.Scalar? = nil,
                                  selection known: NSRange?, client: some InPlaceClient,
                                  word: [Unicode.Scalar]? = nil) -> Outcome {
        var result = Outcome(consumed: true)
        if deleteCount == 0 {
            result.kind = .insert
            insertAtCursor(insert, client: client)
            return result
        }
        if eraseByDelete {
            return erase(deleteCount: deleteCount, insert: insert, appending: extra, client: client)
        }
        // Engine letters are BMP scalars, so deleteCount scalars == deleteCount UTF-16
        // units, also for a word seeded from decomposed (NFD) text (D20).
        let selection = known ?? Self.selectedRange(of: client)
        if known == nil, let mode = detector.observe(selection, inBurst: tracker.keyInBurst),
           let found = confirmRangeIgnore(mode, client: client) {
            // D43: this client ignores the range; this key is the first one erased.
            eraseMode = found
            return erase(deleteCount: deleteCount, insert: insert, appending: extra, client: client)
        }
        var text = insert.description
        if let extra { text.unicodeScalars.append(extra) }
        var attempt = Attempt(deleteCount: deleteCount, selection: selection, expected: tracker.expected,
                              known: tracker.known, insertedLength: text.utf16.count)
        if let word, !readUnavailable, let followed = tracker.known, followed >= deleteCount,
           selection.length == 0, selection.location != NSNotFound, selection.location >= 0,
           selection.location != followed {
            let read = readBefore(selection.location, client: client)
            lateRead = (selection.location, read)
            if let read {
                let units = Array(read.utf16)
                if let rebuilt = tracker.rebuild(units, at: selection, accept: { Self.word(in: $0) == word }),
                   rebuilt.count >= deleteCount {
                    return replaceAtFollowed(followed, deleteCount: deleteCount, text: text, kind: .late,
                                             attempt: attempt, client: client)
                }
                // First replacement of a word, the answer a little behind, and the text read
                // neither proves a late answer nor holds the whole word before the answer
                // (which an app that edited the text before the word would show: it has
                // every key, at other offsets). Every such answer in the 1d run was a late
                // one; taking it as the position replaced the letter before the word and
                // also moved `known` back, which hid the next late answer ("kóo").
                let behind = followed - selection.location
                if tracker.expected == nil, behind >= 1, behind <= CursorTracker.lateLimit,
                   Self.word(in: units) != word {
                    return replaceAtFollowed(followed, deleteCount: deleteCount, text: text, kind: .lateGuess,
                                             attempt: attempt, client: client)
                }
            }
        }
        switch tracker.plan(selection: selection, deleteCount: deleteCount) {
        case .replace(let range):
            attempt.replacement = range
            client.insertText(text, replacementRange: range)
            keyDelta = keyDelta.addingSaturated(text.utf16.count - range.length)
            // A selection after the cursor (an app's suggestion) is not text this composer typed.
            detector.edited(removing: deleteCount, inserting: text.utf16)
            tracker.didReplace(range, text: text)
            result.kind = .replace
        case .unsupported:
            result.kind = .unsupported
            result.consumed = false
        case .mismatch:
            result.kind = .mismatch
            result.consumed = false
        }
        result.attempt = attempt
        return result
    }

    /// Replaces the last `deleteCount` units before `followed` (`CursorTracker.known`)
    /// with `text`: the app applies it after the keys it has not applied yet, as it
    /// applies everything in order, so the range then ends at its caret. The range always
    /// ends at `followed`, also when the end of the word does not change: VS Code
    /// (EditContext) and Firefox move the caret to the end of the replaced range, so a
    /// range ending before the caret would put the next key inside the word.
    private mutating func replaceAtFollowed(_ followed: Int, deleteCount: Int, text: String,
                                           kind: PerfLog.Kind, attempt: Attempt,
                                           client: some InPlaceClient) -> Outcome {
        let range = NSRange(location: followed - deleteCount, length: deleteCount)
        client.insertText(text, replacementRange: range)
        keyDelta = keyDelta.addingSaturated(text.utf16.count - deleteCount)
        detector.edited(removing: deleteCount, inserting: text.utf16)
        tracker.didReplace(range, text: text)
        var result = Outcome(consumed: true, kind: kind)
        result.attempt = attempt
        result.attempt?.replacement = range
        return result
    }

    /// One read of up to `readLength` UTF-16 units before `location` (D11, D20). nil: the
    /// client gave no text (then no read again until activation, N3) or text of another
    /// length (D18).
    private mutating func readBefore(_ location: Int, client: some InPlaceClient) -> String? {
        let count = min(location, Self.readLength)
        guard count > 0 else { return "" }
        guard let text = client.text(in: NSRange(location: location - count, length: count)) else {
            readUnavailable = true
            return nil
        }
        return text.utf16.count == count ? text : nil
    }

    /// The word at the end of `units` (text before the cursor), as `trailingWord` sees it
    /// in precomposed form (how `checkLockedWord` compares text with the engine).
    static func word(in units: [UInt16]) -> [Unicode.Scalar] {
        trailingWord(String(decoding: units, as: UTF16.self).precomposedStringWithCanonicalMapping)
    }

    /// D43, positive evidence: the positions say the client ignores the range (`send`, a
    /// candidate of `RangeIgnoreDetector.observe`). One read of the text this composer
    /// typed (`RangeIgnoreDetector.evidence`, the N3 exception of D43; none when the
    /// client already gave no text, `readUnavailable`) decides, for the rest of the
    /// activation: the client's own text back is a text field that reports a wrong
    /// position (`refute`, replaced in place as before); no text, or other text, is a
    /// field that ignores the range (`confirm`). Returns the erase mode from this key on,
    /// or nil to keep replacing in place (also for a confirmed `.inKey`, `eraseMode(for:)`).
    private mutating func confirmRangeIgnore(_ send: RangeIgnoreDetector.Send,
                                             client: some InPlaceClient) -> EraseMode? {
        if !readUnavailable, let (range, typed) = detector.evidence {
            if let text = client.text(in: range) {
                if RangeIgnoreDetector.isOwnText(text, typed: typed) {
                    detector.refute()
                    return nil
                }
            } else {
                readUnavailable = true  // N3: a client that gave no text is not asked again
            }
        }
        detector.confirm(send)
        return eraseMode(for: send)
    }

    /// Inserts at the current selection without asking where it is (deleteCount 0).
    /// `EraseMode.inKey`: one unit that is not the key's own character goes as that unit,
    /// DEL, that unit (see `EraseMode.inKey`).
    private mutating func insertAtCursor(_ insert: TextBuffer, client: some InPlaceClient) {
        let text = insert.description
        var sent = text
        if eraseMode == .inKey, text.utf16.count == 1, let key = keyScalar, text.unicodeScalars.first != key {
            sent = text + "\u{7F}" + text
        }
        client.insertText(sent, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        keyDelta = keyDelta.addingSaturated(text.utf16.count)
        detector.edited(removing: 0, inserting: text.utf16)
        tracker.didInsertAtCursor(text)
    }

    /// D43: replaces `deleteCount` characters before the cursor with `insert` (and
    /// `extra`) by DEL characters and the new text, at the cursor; never asks where the
    /// cursor is. `EraseMode.afterKey`: the key goes to the app and the fix follows it
    /// (`Outcome.deferredText`), also erasing what the key did; a key whose effect is not
    /// known (Return, Tab: they run the line) is fixed in the key, which Ghostty drops
    /// (D43, "Hệ quả đã chấp nhận"). `EraseMode.inKey`: Delete is consumed, so `extra` (the
    /// letter it would remove) is left out; Return and Tab send nothing.
    private func erase(deleteCount: Int, insert: TextBuffer, appending extra: Unicode.Scalar?,
                       client: some InPlaceClient) -> Outcome {
        var result = Outcome(consumed: true, kind: .erase)
        if eraseMode == .afterKey, let keyEffect, deleteCount + keyEffect >= 0 {
            result.deferredText = String(repeating: "\u{7F}", count: deleteCount + keyEffect) + insert.description
            result.consumed = false
            return result
        }
        if eraseMode == .inKey, keyEffect == nil {
            // xterm.js would run the real Return or Tab before the fix.
            result.consumed = false
            return result
        }
        var text = String(repeating: "\u{7F}", count: deleteCount) + insert.description
        if let extra, eraseMode != .inKey { text.unicodeScalars.append(extra) }
        client.insertText(text, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        return result
    }
}
