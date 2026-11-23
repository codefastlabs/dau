import Foundation
import DauEngine

/// The client calls in-place mode makes: `IMKTextInput` in the input method (through a
/// timing wrapper), a scripted fake document in the unit tests.
protocol InPlaceClient {
    func selectedRange() -> NSRange
    /// Plain text of `range` (`attributedSubstring(from:)`), or nil if the client gives none.
    func text(in range: NSRange) -> String?
    func insertText(_ text: String, replacementRange: NSRange)
    /// Waits `seconds` before the next call: the input method sleeps, a fake moves its clock.
    func pause(_ seconds: TimeInterval)
    /// Seconds on a clock that runs while the input method waits (`backspaceWaitLimit`).
    /// No default: a fake that kept the real clock would really sleep in a test.
    var waitClock: TimeInterval { get }
}

/// In-place mode (D11): the word being typed is replaced in the document with one
/// `insertText(_:replacementRange:)` per key, at the position `selectedRange` gives.
///
/// Which key asks the client what is set by N3 and tabled in `docs/Architecture.md`,
/// "Vị trí thay chữ". A field that ignores `replacementRange` gets the same calls as any
/// field (D43).
struct InPlaceComposer {
    /// D20 on (`DauSettings.addMarksToTypedWords`). Set from the shared settings at
    /// activation and on change, never read per key from the store.
    var addMarksEnabled = true

    #if DEBUG
    /// Tests only: leave unchanged characters to the app instead of `typeCharacter`, the
    /// control for WebKitQueueTests.
    var passesCharactersThrough = false
    /// Tests only: never wait for a ⌫, to compare with.
    var skipsBackspaceWait = false
    #endif

    /// What precedes the caret while the engine has no word; a D20 read costs two client
    /// calls, so it is skipped when the answer is already known.
    enum Before: Equatable {
        /// Anything: start of a session, after a reset, after Backspace or Return/Tab.
        case unknown
        /// Not a letter: the last key was a word-ending character typed here, or a D20 read
        /// just found no word.
        case noWord
    }

    private(set) var tracker = CursorTracker()
    private(set) var before = Before.unknown
    /// Reads in a row that got no position or no text (D20, "Phạm vi").
    private var failedReads = 0
    /// Failed reads in a row after which nothing is read until the next `activate` (N3).
    /// One is not enough: an app may fail once and give text again.
    static let failedReadLimit = 2
    var readUnavailable: Bool { failedReads >= Self.failedReadLimit }

    private mutating func readFailed() { failedReads += 1 }
    private mutating func readGaveText() { failedReads = 0 }

    /// The current word was already checked against the app's text (D11, once per word).
    private var checkedLockedWord = false
    /// Time of the previous key or click on this client (`NSEvent.timestamp`, seconds).
    private var lastEventTime: TimeInterval?
    /// The read `replace` made at the app's answer this key, reused by the D11 re-sync so a
    /// key reads at most once (N3). `text` is nil when the client gave none.
    private var lateRead: (location: Int, text: String?)?

    /// A key less than this after a ⌫ may wait for the app to apply it (N3 "Ngoại lệ sau ⌫
    /// chưa áp"). Not tuned by measurement: it only bounds which keys after a ⌫ are armed,
    /// and only an answer still before the ⌫ makes a key wait.
    static let backspaceWaitWindow: TimeInterval = 0.3
    /// The longest a key waits, its asks included: the p99 bound of D42. A timed
    /// workaround, as IMK has no API that tells whether a key is still queued in the app
    /// (`docs/research/IMKCapabilities.md` 4.1; numbers in `docs/research/LateAnswerFixes.md`
    /// 5.4).
    static let backspaceWaitLimit: TimeInterval = 0.02
    /// Pause between two asks while waiting: short next to the time Safari takes to apply
    /// the ⌫ after the first answer. Not tuned by measurement.
    static let backspaceWaitStep: TimeInterval = 0.002

    /// The previous key was a ⌫ the app deletes itself, and the tracker holds the UTF-16
    /// units it deletes at the followed caret.
    private var unitsDeletedByLastKey: Int?
    /// Set for the current key's first `selectedRange` (`askSelection`): the caret once the
    /// ⌫ is applied, and before.
    private var armedBackspaceWait: (appliedCaret: Int, pendingCaret: Int)?

    /// What waiting for a ⌫ did on this key (Debug perf log, tests).
    struct BackspaceWait: Equatable {
        /// `selectedRange` asks after the first.
        var asks: Int
        /// Seconds from the first pause to the end of the last ask (`waitClock`).
        var waited: TimeInterval
        /// The app answered with the ⌫ applied; false: the limit ran out, or it answered some
        /// other position, taken as is.
        var applied: Bool
    }
    private var keyWait: BackspaceWait?

    /// The last word this composer produced, as it was when a word-ending character typed
    /// here ended it (D20 "Từ hệ thống vừa sửa"). Lives for the next key, plus one ⌫ in
    /// between; not set for a word that D4 restored or that ends still showing the letter of
    /// a double key (D26).
    struct ProducedWord: Equatable {
        var word: [Unicode.Scalar]
        /// One ⌫ (over the word-ending character) came after the word.
        var backspaced = false
    }
    private(set) var produced: ProducedWord?
    /// The produced word the current key may compare with (a key right after the one ⌫).
    private var keyProduced: [Unicode.Scalar]?
    /// A key of the current word undid a mark by a double key (D26): the length of the word
    /// right after it, the last letter being the key's. While that letter is shown, the word
    /// is not remembered as `produced`; a ⌫ that deletes it releases the engine's lock and
    /// clears this.
    private var undidMarkLetters: Int?
    /// The word `seedWord` read for the current key (to tell a double key on it, D26).
    private var keySeededWord: [Unicode.Scalar]?

    /// UTF-16 units read before the caret: the longest word the engine tracks (D33) is at
    /// most 13 scalars decomposed, and one more shows whether the word goes on past the read.
    static let readLength = 16

    /// A key less than this after the previous key or click came in a burst. The D11 reads
    /// that re-sync from the app's text wait for it, as apps that apply keys asynchronously
    /// answer from a snapshot that may still miss the previous keys (`docs/Compatibility.md`
    /// 6.2; D11 "Dựng lại khi lệch"). The D20 read and the late-answer proof do not wait.
    static let settleInterval: TimeInterval = 0.05

    /// Positions of the last replacement attempt of a key (Debug diagnostics).
    struct Attempt: Equatable {
        var deleteCount: Int
        var selection: NSRange
        var predictedCaret: Int?
        var followedCaret: Int?
        var insertedLength: Int
        /// The `replacementRange` sent, or nil when nothing was sent.
        var replacement: NSRange?
        /// The late-answer proof, numbers only (D8): units read before the answer, sizes of
        /// the tracker's typed text and edits, edits in burst, length `rebuild` gave, and
        /// whether the text read ends with the engine's word (1/0). -1: not reached.
        var proofRead = -1
        var proofTail = -1
        var proofEdits = -1
        var proofBurst = -1
        var proofRebuilt = -1
        var proofWordAtAnswer = -1
    }

    struct Outcome: Equatable {
        /// Whether `handle` returns true (key consumed).
        var consumed = false
        var kind = PerfLog.Kind.pass
        var attempt: Attempt?
        /// Set when this key waited for the ⌫ before it (Debug perf log, tests).
        var backspaceWait: BackspaceWait?
        #if DEBUG
        /// Set when this key made a D20 read (Debug perf log).
        var d20: D20Trace?
        /// While a word seeded by a D20 read is being typed: whether the word shown differs
        /// from what an engine that never read the text would show. nil: no seeded word, or
        /// the key ended it.
        var seedDiffers: Bool?
        #endif
    }

    #if DEBUG
    /// What a D20 read did (Debug perf log only).
    struct D20Trace: Equatable {
        /// What triggered the read (D20, "Chữ cái gõ sát chữ có sẵn" for a letter).
        enum Trigger: String { case mark, letter }
        var trigger: Trigger
        /// The engine was seeded with the word read and kept it.
        var seeded: Bool
    }
    /// The word the last `seedWord` seeded.
    private var lastSeededWord: [Unicode.Scalar] = []
    /// An engine that never read the text, fed the keys of the seeded word:
    /// `Outcome.seedDiffers` compares the real engine with `shadowPrefix` + its word.
    private var shadow: VietEngine?
    private var shadowPrefix: [Unicode.Scalar] = []
    private var pendingShadow: VietEngine?
    #endif

    // MARK: - Session events

    /// Forget the word without restoring it (D4) and what precedes the caret.
    mutating func reset(engine: inout VietEngine) {
        engine.reset()
        tracker.invalidate()
        before = .unknown
        checkedLockedWord = false
        produced = nil
        undidMarkLetters = nil
        unitsDeletedByLastKey = nil
    }

    /// A click (or any non-key event that moves the caret) at `time`.
    mutating func noteEvent(at time: TimeInterval?) {
        if let time { lastEventTime = time }
        unitsDeletedByLastKey = nil  // the click came between the ⌫ and the next key
    }

    /// New activation (or another client): the client may give text again.
    mutating func activate() {
        failedReads = 0
        lastEventTime = nil
        produced = nil
        unitsDeletedByLastKey = nil
    }

    // MARK: - Keys

    /// One key in in-place mode. `time` is the event's timestamp (nil if unknown).
    mutating func handle(_ route: KeyRoute, time: TimeInterval?, engine: inout VietEngine,
                         client: some InPlaceClient) -> Outcome {
        #if DEBUG
        // Feed the key to the unseeded shadow before the real engine changes.
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
            outcome.seedDiffers = engine.shown != shadowPrefix + shadow.shown
        } else {
            self.shadow = nil
        }
        outcome.backspaceWait = keyWait
        return outcome
        #else
        var outcome = handleTracked(route, time: time, engine: &engine, client: client)
        outcome.backspaceWait = keyWait
        return outcome
        #endif
    }

    /// `handleKey`, then whether the key undid a mark by a double key (`undidMarkLetters`).
    private mutating func handleTracked(_ route: KeyRoute, time: TimeInterval?, engine: inout VietEngine,
                                        client: some InPlaceClient) -> Outcome {
        keySeededWord = nil
        var shownBefore: [Unicode.Scalar]?
        if case .character = route, engine.lastShown != nil { shownBefore = engine.shown }
        if case .character = route, !engine.isComposing { undidMarkLetters = nil }  // a new word
        let outcome = handleKey(route, time: time, engine: &engine, client: client)
        if case .character(let key) = route, engine.lastShown != nil,
           let prior = shownBefore ?? keySeededWord,
           Self.undidMark(before: prior, after: engine.shown, key: key) {
            undidMarkLetters = engine.shown.count
        }
        if case .backspace = route, let letters = undidMarkLetters, engine.shown.count < letters {
            undidMarkLetters = nil
        }
        return outcome
    }

    private mutating func handleKey(_ route: KeyRoute, time: TimeInterval?, engine: inout VietEngine,
                                    client: some InPlaceClient) -> Outcome {
        let settled = isSettled(at: time)
        let sinceLast: TimeInterval? = time.flatMap { t in lastEventTime.map { t - $0 } }
        if let time { lastEventTime = time }
        lateRead = nil
        tracker.lateness.keyInBurst = !settled
        armBackspaceWait(sinceLast: sinceLast)
        let lastProduced = takeProducedWord(for: route)

        switch route {
        case .ignore:
            // D4: shortcuts, arrows, Esc only reset; nothing is restored.
            reset(engine: &engine)
            return Outcome(kind: .reset)
        case .backspace:
            return handleBackspace(lastProduced: lastProduced, engine: &engine, client: client)
        case .endWord:
            return handleEndWord(engine: &engine, client: client)
        case .character(let scalar):
            return handleCharacter(scalar, settled: settled, engine: &engine, client: client)
        }
    }

    /// Arms the wait of N3 "Ngoại lệ sau ⌫ chưa áp" when this key came less than
    /// `backspaceWaitWindow` after a ⌫ whose deleted text the tracker still holds at the
    /// followed caret. The key's first `selectedRange` disarms it.
    private mutating func armBackspaceWait(sinceLast: TimeInterval?) {
        keyWait = nil
        armedBackspaceWait = nil
        #if DEBUG
        if skipsBackspaceWait { unitsDeletedByLastKey = nil }
        #endif
        if let deleted = unitsDeletedByLastKey, let sinceLast, sinceLast >= 0, sinceLast < Self.backspaceWaitWindow,
           let caret = tracker.followed.caret,
           tracker.followed.unitsDeletedAtCaret == deleted {
            armedBackspaceWait = (caret, caret.addingSaturated(deleted))
        }
        unitsDeletedByLastKey = nil
    }

    /// Hands the produced word to this key, its last one; a character right after the one ⌫
    /// over the word-ending character may compare with it (`keyProduced`). Returns the word
    /// as it was before this key.
    private mutating func takeProducedWord(for route: KeyRoute) -> ProducedWord? {
        let lastProduced = produced
        produced = nil
        keyProduced = nil
        if case .character = route, let lastProduced, lastProduced.backspaced {
            keyProduced = lastProduced.word
        }
        return lastProduced
    }

    /// ⌫ is never consumed (D32): the app's own Delete removes the last character.
    private mutating func handleBackspace(lastProduced: ProducedWord?, engine: inout VietEngine,
                                          client: some InPlaceClient) -> Outcome {
        let wasComposing = engine.isComposing
        let recordedBefore = tracker.followed.editsRecorded
        let lastShown = engine.lastShown
        let wordBefore = engine.isComposing ? engine.shown : nil
        var result = Outcome()
        switch engine.backspace() {
        case .passThrough:
            if wasComposing {
                tracker.backspacePassedThrough()
            } else {
                tracker.backspaceOutsideWord()
            }
        case .replace(let deleteCount, let insert):
            result = replaceBeforeDelete(deleteCount: deleteCount, insert: insert, lastShown: lastShown,
                                         word: wordBefore, engine: &engine, client: client)
        }
        if !engine.isComposing {
            tracker.endWord()
            before = .unknown
            checkedLockedWord = false
        }
        if !wasComposing, let lastProduced, !lastProduced.backspaced {
            // The one ⌫ over the character that ended the produced word.
            produced = ProducedWord(word: lastProduced.word, backspaced: true)
        }
        if tracker.followed.editsRecorded != recordedBefore, let deleted = tracker.followed.unitsDeletedAtCaret {
            unitsDeletedByLastKey = deleted
        }
        return result
    }

    /// D32 re-places the tone ("hoà" ⌫ → "hò"): the replacement puts the last character back
    /// at the end ("hòà") and the app's own Delete removes it, as Chromium runs its Delete
    /// even for a consumed ⌫ (`docs/Architecture.md`, "Backspace thay tại chỗ"). A decomposed
    /// last character may be deleted mark by mark: no guess, reset.
    private mutating func replaceBeforeDelete(deleteCount: Int, insert: TextBuffer, lastShown: Unicode.Scalar?,
                                              word: [Unicode.Scalar]?, engine: inout VietEngine,
                                              client: some InPlaceClient) -> Outcome {
        var result = Outcome()
        if let lastShown, lastShown.properties.generalCategory != .nonspacingMark, deleteCount >= 1 {
            result = replace(deleteCount: deleteCount, insert: insert, appending: lastShown,
                             selection: nil, client: client, word: word)
        } else {
            result.kind = .reset
        }
        result.consumed = false
        if result.kind == .replace || result.kind == .late || result.kind == .lateGuess {
            tracker.backspacePassedThrough()
        } else {
            reset(engine: &engine)
        }
        return result
    }

    /// Return, Tab, keypad Enter: restore the word if needed (D4), then let the app handle
    /// the key, whose effect is unknown (Tab may focus another field).
    private mutating func handleEndWord(engine: inout VietEngine, client: some InPlaceClient) -> Outcome {
        var result = Outcome()
        let wordBefore = engine.isComposing ? engine.shown : nil
        if case .replace(let deleteCount, let insert) = engine.endWord() {
            result = replace(deleteCount: deleteCount, insert: insert, selection: nil, client: client,
                             word: wordBefore)
        }
        reset(engine: &engine)
        result.consumed = false
        return result
    }

    private mutating func handleCharacter(_ scalar: Unicode.Scalar, settled: Bool, engine: inout VietEngine,
                                          client: some InPlaceClient) -> Outcome {
        // D20 reads at any pace, keys in a burst included (D20, "Phạm vi").
        if !engine.isComposing, addMarksEnabled, before == .unknown, !readUnavailable {
            if Self.isMarkKey(scalar, method: engine.options.inputMethod) {
                return addMarks(scalar, letter: false, engine: &engine, client: client)
            }
            if Self.isLetter(scalar) {
                return addMarks(scalar, letter: true, engine: &engine, client: client)
            }
        }
        if engine.isSpellingLocked, !checkedLockedWord, !readUnavailable, settled,
           Self.isMarkKey(scalar, method: engine.options.inputMethod),
           let outcome = checkLockedWord(scalar, engine: &engine, client: client) {
            return outcome
        }
        return character(scalar, selection: nil, settled: settled, engine: &engine, client: client)
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

    /// ASCII letters, any case.
    static func isLetter(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (v >= 0x41 && v <= 0x5A) || (v >= 0x61 && v <= 0x7A)
    }

    /// The engine's word is still a valid prefix (D30): not locked by spelling, and not past
    /// the longest syllable (D33: the engine tracks no letters, `lastShown` is nil).
    static func isValidPrefix(_ engine: VietEngine) -> Bool {
        !engine.isSpellingLocked && engine.lastShown != nil
    }

    /// A character with the engine's word (if any). `settled`: the previous key or click is
    /// old enough for a mismatch to re-sync from the app's text (D11).
    private mutating func character(_ scalar: Unicode.Scalar, selection: NSRange?, settled: Bool = false,
                                    engine: inout VietEngine, client: some InPlaceClient) -> Outcome {
        var result: Outcome
        let wordBefore = engine.isComposing ? engine.shown : nil
        // Consonant shortcuts (D21) also change the word at its end; a copy tells them from a
        // D4 restore (`producedWord`).
        let engineBefore: VietEngine? = engine.options.advanced == .consonantShortcuts && wordBefore != nil
            ? engine : nil
        let tracked = engine.lastShown != nil  // not D33's pass-through state
        let action = engine.handle(scalar)
        switch action {
        case .passThrough:
            result = Outcome(consumed: typeCharacter(scalar, client: client))
            tracker.typedAtCaret(String(Character(scalar)))
        case .replace(let deleteCount, let insert):
            result = replace(deleteCount: deleteCount, insert: insert, selection: selection, client: client,
                             word: wordBefore)
            if result.kind == .mismatch, settled, !readUnavailable, let seen = result.attempt?.selection,
               let resynced = resync(scalar, at: seen, attempt: result.attempt, engine: &engine, client: client) {
                return resynced
            }
            if result.kind == .mismatch || result.kind == .unsupported {
                result.consumed = typeAlone(scalar, engine: &engine, client: client)
            }
        }
        if !engine.isComposing {
            noteWordEnded(by: scalar, action: action, result: result, word: wordBefore, tracked: tracked,
                          engineBefore: engineBefore)
        }
        return result
    }

    /// D11 "Dựng lại khi lệch": the text changed behind the engine's back. Seeds the engine
    /// with the word really before the caret, reusing the read `replace` made at the same
    /// answer (N3), and applies the key to it. nil: nothing to re-sync with; the engine is
    /// reset.
    private mutating func resync(_ scalar: Unicode.Scalar, at seen: NSRange, attempt: Attempt?,
                                 engine: inout VietEngine, client: some InPlaceClient) -> Outcome? {
        let earlier = lateRead?.location == seen.location ? lateRead : nil
        reset(engine: &engine)
        // A read that gave nothing usable is not made again for this key.
        if earlier == nil || earlier?.text != nil,
           var resynced = Self.asResync(seedWord(scalar, selection: seen, engine: &engine, client: client,
                                                 alreadyRead: earlier?.text)) {
            resynced.attempt = attempt
            return resynced
        }
        engine.reset()
        return nil
    }

    /// A seeded outcome relabelled as a D11 re-sync; nil when nothing was seeded.
    private static func asResync(_ seeded: Outcome?) -> Outcome? {
        guard var outcome = seeded, outcome.kind == .seed || outcome.kind == .seedPass else { return nil }
        outcome.kind = outcome.kind == .seed ? .resync : .resyncPass
        return outcome
    }

    /// D11: the app's text is not what the engine thinks and nothing was sent for this key,
    /// so the key starts over alone. The caret is forgotten, so the tracker records nothing.
    /// Returns whether the key is consumed.
    private mutating func typeAlone(_ scalar: Unicode.Scalar, engine: inout VietEngine,
                                    client: some InPlaceClient) -> Bool {
        reset(engine: &engine)
        switch engine.handle(scalar) {
        case .passThrough:
            return typeCharacter(scalar, client: client)
        case .replace(0, let insert):
            insertAtCursor(insert, client: client)
            return true
        case .replace:
            reset(engine: &engine)
            return typeCharacter(scalar, client: client)
        }
    }

    /// The key ended a word (or was punctuation with no word): it is now right before the
    /// caret, unless the replacement failed and nothing is known.
    private mutating func noteWordEnded(by scalar: Unicode.Scalar, action: Action, result: Outcome,
                                        word wordBefore: [Unicode.Scalar]?, tracked: Bool,
                                        engineBefore: VietEngine?) {
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

    // MARK: - D20 "Từ hệ thống vừa sửa"

    /// The word left in the app when `key`, a word-ending character, ended `word` with
    /// `action`; nil when the key is not printable or D4 restored the word. `engineBefore`:
    /// the engine before the key when consonant shortcuts (D21) are on, to tell an expansion
    /// from a restore.
    static func producedWord(_ word: [Unicode.Scalar], ending key: Unicode.Scalar, action: Action,
                             engineBefore: VietEngine?) -> [Unicode.Scalar]? {
        let v = key.value
        guard v >= 0x20, v != 0x7F, !(v >= 0xF700 && v <= 0xF8FF) else { return nil }
        switch action {
        case .passThrough:
            return word
        case .replace(let deleteCount, let insert):
            guard insert.last == key, deleteCount <= word.count else { return nil }
            // A D4 restore, unless the same engine without consonant shortcuts leaves the
            // word as it is (then a D21 expansion changed it).
            guard var plain = engineBefore else { return nil }
            plain.options.advanced = .off
            guard case .passThrough = plain.endWord() else { return nil }
            return Array(word.dropLast(deleteCount)) + insert.dropLast()
        }
    }

    /// D26 seen from the text: the key removed a mark and put its own letter at the end
    /// ("cả" + r → "car"). No other key does both.
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

    /// `shown`, the word read before the caret, is what `key` makes of `own` (the word this
    /// composer produced), ignoring case, and is not `own` itself: the system already changed
    /// the word the way this key would. Engine only, no client call.
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

    // MARK: - D11 "Từ đã hết hợp lệ"

    /// On the first mark key of a word past valid (D30), reads the word before the caret once:
    /// if it is not the engine's word, starts over from the real text and applies the key.
    /// Such a word's keys go in at the caret and ask nothing, so a text the app replaced
    /// without telling the input method (⌘A in Chrome's address bar never reaches it) would
    /// otherwise go unnoticed. nil: the word is the engine's, handle the key as usual.
    private mutating func checkLockedWord(_ scalar: Unicode.Scalar, engine: inout VietEngine,
                                          client: some InPlaceClient) -> Outcome? {
        checkedLockedWord = true
        let selection = askSelection(client: client)
        // A selection here is the app's (an autocomplete, text selected with a shortcut the
        // input method never saw): the word before it counts, the key replaces it either way.
        guard selection.location != NSNotFound, selection.length != NSNotFound,
              selection.location >= 0, selection.length >= 0 else { return nil }
        let read: String?
        if selection.location == 0 {
            read = nil
        } else {
            guard let text = readBefore(selection.location, client: client) else { return nil }
            read = text
        }
        let real = read.map { Self.trailingWord($0.precomposedStringWithCanonicalMapping) } ?? []
        if real == engine.shown {
            if tracker.followed.caret == nil, selection.length == 0 { tracker.anchor(at: selection.location) }
            return nil
        }
        // The app may answer from before the last keys of this word.
        let shown = engine.shown
        if let read, tracker.rebuild(Array(read.utf16), at: selection, accept: { Self.word(in: $0) == shown }) != nil {
            return nil
        }
        reset(engine: &engine)
        if let resynced = Self.asResync(seedWord(scalar, selection: selection, engine: &engine, client: client,
                                                 alreadyRead: read, allowSelection: true)) {
            return resynced
        }
        // Nothing to seed (no word, or one the engine cannot track): the key starts a word.
        engine.reset()
        var outcome = character(scalar, selection: selection, engine: &engine, client: client)
        if outcome.kind == .pass { outcome.kind = .resyncPass }
        return outcome
    }

    // MARK: - D20 "Thêm dấu cho từ đã gõ"

    /// The answer a D20 read starts from, after the late-answer proof (`answerForRead`).
    private struct ReadAnswer {
        var selection: NSRange
        /// The text before `selection`, when read.
        var read: String?
        var didRead = false
        /// Behind the followed caret, not proved late, and in a burst: neither anchored at
        /// nor seeded from.
        var staleInBurst = false

        /// A read that gave nothing usable is not made again for this key (N3).
        var allowsSeed: Bool { !(didRead && read == nil || staleInBurst) }
    }

    /// Reads the word right before the caret, seeds the engine with it as displayed, and
    /// lets the engine decide (D20): the key either changes the word in place or goes in
    /// unchanged at the caret. Any odd answer from the client means no seed (D18).
    ///
    /// `letter`: the key is a plain letter, not a mark key. Whether it joins the word read
    /// is decided from the text read before anything is sent (`seedWord`), so a key that
    /// does not join makes the same calls as an unseeded key after the read.
    private mutating func addMarks(_ scalar: Unicode.Scalar, letter: Bool = false, engine: inout VietEngine,
                                   client: some InPlaceClient) -> Outcome {
        #if DEBUG
        prepareShadow(for: scalar, engine: engine)
        #endif
        let answer = answerForRead(askSelection(client: client), client: client)
        let selection = answer.selection
        if !answer.staleInBurst, selection.length == 0, selection.location != NSNotFound, selection.location >= 0 {
            tracker.anchor(at: selection.location)
        }
        var outcome = answer.allowsSeed
            ? seedWord(scalar, selection: selection, engine: &engine, client: client, alreadyRead: answer.read,
                       rule: letter ? .letter : .mark)
            : nil
        if var failed = outcome, failed.kind == .mismatch || failed.kind == .unsupported {
            // The seeded word could not be replaced (nothing was sent; engine and caret were
            // reset): the key goes in as typed (N3).
            failed.consumed = typeCharacter(scalar, client: client)
            outcome = failed
        }
        if outcome == nil {
            // Not seeded: the key starts a word as usual. With an empty engine it never
            // replaces text, so it asks nothing more.
            engine.reset()
            outcome = character(scalar, selection: selection, engine: &engine, client: client)
            if outcome?.kind == .pass || outcome?.kind == .insert { outcome?.kind = .seedNone }
        }
        var traced = outcome ?? Outcome()
        #if DEBUG
        let seeded = traced.kind == .seed || traced.kind == .seedPass || traced.kind == .seedKept
        traced.d20 = D20Trace(trigger: letter ? .letter : .mark, seeded: seeded)
        #endif
        return traced
    }

    /// When `selection` is not the followed caret, the app may answer from before the last
    /// Delete: one read at its answer, and if that text plus the edits it lacks (each one's
    /// removed text checked) ends at the followed caret, the read is that text there
    /// (D11 "App trả lời chậm").
    private mutating func answerForRead(_ selection: NSRange, client: some InPlaceClient) -> ReadAnswer {
        var answer = ReadAnswer(selection: selection)
        guard let caret = tracker.followed.caret, selection.length == 0, selection.location != NSNotFound,
              selection.location >= 0, selection.location != caret, !tracker.followed.edits.isEmpty else {
            return answer
        }
        answer.didRead = true
        answer.read = readBefore(selection.location, client: client)
        if let text = answer.read,
           let rebuilt = tracker.rebuild(Array(text.utf16), at: selection,
                                         requireDeletedText: true, accept: { _ in true }) {
            let count = min(caret, Self.readLength, rebuilt.count)
            answer.read = String(decoding: rebuilt.suffix(count), as: UTF16.self)
            answer.selection = NSRange(location: caret, length: 0)
        } else if selection.location < caret, tracker.lateness.keyInBurst {
            // Not proved, yet keys in a burst leave no time for a click IMK does not report:
            // the app is further behind than `rebuild` replays. Anchoring at the answer would
            // move the followed caret back to a stale one, and the next word's first
            // replacement would land in this word (`docs/research/LateAnswerFixes.md` 3.3).
            answer.staleInBurst = true
        }
        return answer
    }

    #if DEBUG
    /// The key alone on an empty engine: what the document would get without a seed.
    private mutating func prepareShadow(for scalar: Unicode.Scalar, engine: VietEngine) {
        var plain = engine
        plain.reset()
        _ = plain.handle(scalar)
        pendingShadow = plain
        lastSeededWord = []
    }
    #endif

    /// How `seedWord` decides whether the key joins the word read.
    enum SeedRule {
        /// D11 re-sync: the key always applies to the word read.
        case resync
        /// D20, a tone or transform key typed first after a reset.
        case mark
        /// D20, a plain letter typed first after a reset ("Chữ cái gõ sát chữ có sẵn").
        case letter
    }

    /// Seeds the engine with the word before `selection` and applies the key; nil when
    /// nothing was seeded and the caller handles the key as the first of a new word.
    /// `alreadyRead`: the text of the same range, when the caller read it (one read per key,
    /// N3). `allowSelection`: a selection after the word is an app's suggestion (D11); D20
    /// itself never seeds with a selection.
    private mutating func seedWord(_ scalar: Unicode.Scalar, selection: NSRange, engine: inout VietEngine,
                                   client: some InPlaceClient, alreadyRead: String? = nil,
                                   allowSelection: Bool = false, rule: SeedRule = .resync) -> Outcome? {
        if selection.location == NSNotFound || selection.length == NSNotFound {
            readFailed()  // no position: no read, the key starts a word
            return nil
        }
        guard selection.location >= 0, selection.length == 0 || allowSelection else { return nil }
        let location = selection.location
        if location == 0 {
            before = .noWord
            return nil
        }
        guard let text = textForSeed(before: location, alreadyRead: alreadyRead, client: client) else { return nil }
        let word = Self.trailingWord(text)
        if word.isEmpty {
            before = .noWord
            return nil
        }
        let d20 = rule != .resync
        // The word may go on before what was read: too long to be one the engine tracks.
        if word.count == text.unicodeScalars.count && location > text.utf16.count {
            return d20 ? continueForeignWord(word, scalar, location: location, engine: &engine, client: client) : nil
        }
        // Every scalar the engine accepts is in the BMP, so scalar counts are UTF-16 counts.
        guard word.allSatisfy({ $0.utf16.count == 1 }), engine.seed(displayed: word) else {
            return d20 ? continueForeignWord(word, scalar, location: location, engine: &engine, client: client) : nil
        }
        keySeededWord = word
        // D20 "Từ hệ thống vừa sửa": keep the text; the engine goes on from the word shown.
        if rule == .mark, let own = keyProduced,
           Self.isSystemFix(word, of: own, key: scalar, options: engine.options) {
            noteSeeded(word, engine: engine)
            return Outcome(consumed: true, kind: .seedKept)
        }
        let lockedBefore = engine.isSpellingLocked
        let action = engine.handle(scalar)
        guard Self.keyJoins(scalar, word: word, action: action, rule: rule, lockedBefore: lockedBefore,
                            validPrefix: Self.isValidPrefix(engine)) else {
            engine.reset()
            return nil
        }
        noteSeeded(word, engine: engine)
        return applySeededKey(scalar, action: action, word: word, selection: selection, engine: &engine,
                              client: client)
    }

    /// The text `seedWord` reads before `location`: `alreadyRead` when the caller has it,
    /// else one read. nil: nothing usable.
    private mutating func textForSeed(before location: Int, alreadyRead: String?,
                                      client: some InPlaceClient) -> String? {
        if let alreadyRead {
            // Shorter than `readLength` when rebuilt from a late answer (`answerForRead`).
            return alreadyRead.utf16.count <= location ? alreadyRead : nil
        }
        guard !readUnavailable else { return nil }
        return readBefore(location, client: client)
    }

    /// Sends what the engine made of the key on the seeded `word` before `selection`.
    private mutating func applySeededKey(_ scalar: Unicode.Scalar, action: Action, word: [Unicode.Scalar],
                                         selection: NSRange, engine: inout VietEngine,
                                         client: some InPlaceClient) -> Outcome {
        switch action {
        case .passThrough:
            // D20 does not apply ("viet" + j → "vietj"); the engine keeps the word, so the
            // next keys continue it (the seed is the D4 baseline).
            return typeIntoSeededWord(scalar, location: selection.location, client: client)
        case .replace(let deleteCount, let insert):
            guard deleteCount <= word.count else {
                reset(engine: &engine)
                return Outcome(consumed: false, kind: .mismatch)
            }
            var result = replace(deleteCount: deleteCount, insert: insert, selection: selection, client: client)
            // `.insert`: the key only added to the word read, already written at the caret.
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

    /// Whether the key, applied with `action` to the seeded `word`, belongs to it: D20 and
    /// its exceptions (a) and (c), D20 "Chữ cái gõ sát chữ có sẵn" for a letter. A word
    /// locked by spelling before the key is not Vietnamese and takes every key (exception
    /// (b), which wins over (a)); a re-sync always joins. `validPrefix`: the word after the
    /// key (`isValidPrefix`).
    private static func keyJoins(_ key: Unicode.Scalar, word: [Unicode.Scalar], action: Action, rule: SeedRule,
                                 lockedBefore: Bool, validPrefix: Bool) -> Bool {
        guard rule != .resync, !lockedBefore else { return true }
        if startsNewWord(key, after: word) {
            // A mark key that changed the word added no letter.
            guard rule == .mark, case .replace(let deleteCount, _) = action, deleteCount > 0 else { return false }
        }
        if validPrefix { return true }
        switch rule {
        case .resync:
            return true
        case .letter:
            return false
        case .mark:
            // (c): a mark key that was not applied starts a new word; a double key (D26) was.
            if case .passThrough = action { return false }
            return true
        }
    }

    /// The engine's word is the app's text: a word locked by spelling needs no D11 check
    /// against it (`checkLockedWord`).
    private mutating func noteSeeded(_ word: [Unicode.Scalar], engine: VietEngine) {
        if engine.isSpellingLocked { checkedLockedWord = true }
        #if DEBUG
        lastSeededWord = word
        #endif
    }

    /// The key goes into the seeded word unchanged, typed at the caret (N3).
    private mutating func typeIntoSeededWord(_ scalar: Unicode.Scalar, location: Int,
                                             client: some InPlaceClient) -> Outcome {
        let consumed = typeCharacter(scalar, client: client)
        tracker.didReplace(NSRange(location: location, length: 0), text: String(Character(scalar)), atCaret: true)
        return Outcome(consumed: consumed, kind: .seedPass)
    }

    /// D20 exception (a): an upper-case key after a word that ends with a lower-case letter.
    static func startsNewWord(_ key: Unicode.Scalar, after word: [Unicode.Scalar]) -> Bool {
        guard Character(key).isUppercase else { return false }
        var view = String.UnicodeScalarView()
        view.append(contentsOf: word)
        // The last character, not scalar: decomposed text ends with a mark.
        return String(view).last?.isLowercase == true
    }

    /// D20 exception (b) for a word `seed` cannot take: if it is all letters, the key and the
    /// rest of the word go in unchanged (D33's state, `VietEngine.seedOverflow`) until the
    /// word ends. nil: not letters ("abc123"), the key starts a new word.
    private mutating func continueForeignWord(_ word: [Unicode.Scalar], _ scalar: Unicode.Scalar, location: Int,
                                              engine: inout VietEngine, client: some InPlaceClient) -> Outcome? {
        guard word.allSatisfy({ CharacterSet.letters.contains($0) }) else {
            engine.reset()
            return nil
        }
        var view = String.UnicodeScalarView()
        view.append(contentsOf: word)
        // Characters, as the app's Delete removes them. Fewer than the real word when the
        // read is cut: the state then ends early and the next key reads again.
        engine.seedOverflow(shown: String(view).count)
        guard case .passThrough = engine.handle(scalar) else {
            engine.reset()
            return nil
        }
        #if DEBUG
        lastSeededWord = word
        #endif
        return typeIntoSeededWord(scalar, location: location, client: client)
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

    /// The client's `selectedRange`, the only way in-place mode asks for it: an unusable
    /// answer is NSNotFound from here on (D18).
    static func selectedRange(of client: some InPlaceClient) -> NSRange {
        ClientRange.sanitized(client.selectedRange())
    }

    /// The key's `selectedRange`, waiting for a ⌫ the app has not applied yet when armed
    /// (N3 "Ngoại lệ sau ⌫ chưa áp"; `docs/Architecture.md`, "Chờ ⌫ chưa áp").
    ///
    /// An answer at the caret before that ⌫ cannot tell Safari, which still holds the ⌫ in
    /// WebKit's key queue, from Chrome, whose cache answers late with the ⌫ already queued
    /// ahead in the page. So it asks again every `backspaceWaitStep` until the answer moves
    /// or `backspaceWaitLimit` passes, then goes on with the latest answer. Only the first
    /// `selectedRange` of a key can wait.
    private mutating func askSelection(client: some InPlaceClient) -> NSRange {
        var answer = Self.selectedRange(of: client)
        guard let wait = armedBackspaceWait else { return answer }
        armedBackspaceWait = nil
        let pending = NSRange(location: wait.pendingCaret, length: 0)
        guard answer == pending else { return answer }
        // The limit counts the time of the asks too, from the client's clock.
        let start = client.waitClock
        var asks = 0
        while client.waitClock - start < Self.backspaceWaitLimit {
            client.pause(Self.backspaceWaitStep)
            asks += 1
            answer = Self.selectedRange(of: client)
            if answer != pending { break }
        }
        keyWait = BackspaceWait(asks: asks, waited: client.waitClock - start,
                                applied: answer == NSRange(location: wait.appliedCaret, length: 0))
        return answer
    }

    /// Applies `.replace` with exactly one `insertText` (N3), asking `selectedRange` unless
    /// this key already did (`selection`). `appending`: one more scalar after `insert`
    /// (Backspace, `replaceBeforeDelete`). `word`: the engine's word before this key, when
    /// the answer may be checked for a late app (`replaceIfLate`).
    private mutating func replace(deleteCount: Int, insert: TextBuffer, appending extra: Unicode.Scalar? = nil,
                                  selection known: NSRange?, client: some InPlaceClient,
                                  word: [Unicode.Scalar]? = nil) -> Outcome {
        if deleteCount == 0 {
            insertAtCursor(insert, client: client)
            return Outcome(consumed: true, kind: .insert)
        }
        // Engine letters are BMP scalars, so deleteCount scalars are deleteCount UTF-16
        // units, also for a word seeded from decomposed text.
        let selection = known ?? askSelection(client: client)
        if let followed = tracker.followed.caret, selection == NSRange(location: followed, length: 0) {
            tracker.answeredOnTime()
        }
        var text = insert.description
        if let extra { text.unicodeScalars.append(extra) }
        var attempt = Attempt(deleteCount: deleteCount, selection: selection, predictedCaret: tracker.predictedCaret,
                              followedCaret: tracker.followed.caret, insertedLength: text.utf16.count)
        if let word, let late = replaceIfLate(deleteCount: deleteCount, text: text, selection: selection,
                                              word: word, attempt: &attempt, client: client) {
            return late
        }
        return replaceAtAnswer(selection, deleteCount: deleteCount, text: text, attempt: attempt, client: client)
    }

    /// D11 "App trả lời chậm": when the answer is not the followed caret, one read at the
    /// answer (the D11 read, N3) may prove the app has not applied the latest edits yet
    /// (`CursorTracker.rebuild`); the key then replaces at the followed caret, which the app
    /// reaches as it applies everything in order. nil: the answer stands.
    private mutating func replaceIfLate(deleteCount: Int, text: String, selection: NSRange, word: [Unicode.Scalar],
                                        attempt: inout Attempt, client: some InPlaceClient) -> Outcome? {
        guard !readUnavailable, let followed = tracker.followed.caret, followed >= deleteCount,
              selection.length == 0, selection.location != NSNotFound, selection.location >= 0,
              selection.location != followed else { return nil }
        let read = readBefore(selection.location, client: client)
        lateRead = (selection.location, read)
        #if DEBUG
        attempt.proofTail = tracker.followed.typedBeforeCaret.count
        attempt.proofEdits = tracker.followed.edits.count
        attempt.proofBurst = tracker.lateness.editsInBurst
        #endif
        guard let read else { return nil }
        let units = Array(read.utf16)
        let proof = tracker.rebuild(units, at: selection, inWord: true,
                                    accept: { Self.word(in: $0) == word })
        #if DEBUG
        attempt.proofRead = units.count
        attempt.proofRebuilt = proof?.count ?? -1
        attempt.proofWordAtAnswer = Self.word(in: units) == word ? 1 : 0
        #endif
        if let rebuilt = proof, rebuilt.count >= deleteCount {
            return replaceAtFollowed(followed, deleteCount: deleteCount, text: text, kind: .late,
                                     attempt: attempt, client: client)
        }
        // The first replacement of a word, the answer a little behind, and the word not whole
        // before it, as it would be had the app edited the text before the word. Taking such
        // an answer would replace the letter before the word and move the followed caret back
        // (`docs/Architecture.md`, "App trả lời chậm").
        let behind = followed - selection.location
        if tracker.predictedCaret == nil, behind >= 1, behind <= CursorTracker.LatenessBudget.humanPaceEdits,
           Self.word(in: units) != word {
            return replaceAtFollowed(followed, deleteCount: deleteCount, text: text, kind: .lateGuess,
                                     attempt: attempt, client: client)
        }
        return nil
    }

    /// Replaces at the range `CursorTracker.plan` makes of the app's answer.
    private mutating func replaceAtAnswer(_ selection: NSRange, deleteCount: Int, text: String, attempt: Attempt,
                                          client: some InPlaceClient) -> Outcome {
        var result = Outcome(consumed: true)
        var attempt = attempt
        switch tracker.plan(selection: selection, deleteCount: deleteCount) {
        case .replace(let range):
            attempt.replacement = range
            client.insertText(text, replacementRange: range)
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

    /// Replaces the last `deleteCount` units before `followed` with `text`. The range ends at
    /// `followed` even when the end of the word does not change: VS Code (EditContext) and
    /// Firefox move the caret to the end of the replaced range, so a range ending before the
    /// caret would put the next key inside the word.
    private mutating func replaceAtFollowed(_ followed: Int, deleteCount: Int, text: String,
                                            kind: PerfLog.Kind, attempt: Attempt,
                                            client: some InPlaceClient) -> Outcome {
        let range = NSRange(location: followed - deleteCount, length: deleteCount)
        client.insertText(text, replacementRange: range)
        tracker.didReplace(range, text: text)
        var result = Outcome(consumed: true, kind: kind)
        result.attempt = attempt
        result.attempt?.replacement = range
        return result
    }

    /// One read of up to `readLength` UTF-16 units before `location` (D11, D20). nil: the
    /// client gave no text (counted, `failedReadLimit`), or text of another length, which
    /// means the range split a surrogate pair or the client answered another range
    /// (IMKInputSession.h; D18).
    private mutating func readBefore(_ location: Int, client: some InPlaceClient) -> String? {
        let count = min(location, Self.readLength)
        guard count > 0 else { return "" }
        guard let text = client.text(in: NSRange(location: location - count, length: count)) else {
            readFailed()
            return nil
        }
        readGaveText()
        return text.utf16.count == count ? text : nil
    }

    /// The word at the end of `units`, precomposed, as the engine holds it.
    static func word(in units: [UInt16]) -> [Unicode.Scalar] {
        trailingWord(String(decoding: units, as: UTF16.self).precomposedStringWithCanonicalMapping)
    }

    /// A character the engine leaves as typed, inserted at the caret by the input method,
    /// never left to the app (N3, "Vì sao Dấu tự chèn ký tự"). Returns whether the key is
    /// consumed; the caller records the edit in `tracker`.
    private mutating func typeCharacter(_ scalar: Unicode.Scalar, client: some InPlaceClient) -> Bool {
        #if DEBUG
        if passesCharactersThrough { return false }
        #endif
        waitForBackspace(client: client)
        client.insertText(String(Character(scalar)), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        return true
    }

    /// Text typed at the caret asks nothing, but when armed it asks one `selectedRange` and
    /// waits as `askSelection` does: a ⌫ still queued in WebKit behind it would delete the
    /// text instead. Not armed: no call (N3).
    private mutating func waitForBackspace(client: some InPlaceClient) {
        guard armedBackspaceWait != nil else { return }
        _ = askSelection(client: client)
    }

    /// Inserts at the current selection without asking where it is (deleteCount 0).
    private mutating func insertAtCursor(_ insert: TextBuffer, client: some InPlaceClient) {
        waitForBackspace(client: client)
        let text = insert.description
        client.insertText(text, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        tracker.didInsertAtCursor(text)
    }
}
