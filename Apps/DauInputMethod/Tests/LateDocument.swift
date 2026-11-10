import Foundation
import DauEngine
import DauShared

/// An app that applies every edit in order (keys it types, `insertText` with absolute
/// ranges) but answers `selectedRange` and `attributedSubstring` from an earlier state
/// of its text: Chrome with a busy page (M6 step 1, log of 09/11/2026), and apps that
/// apply keys asynchronously when keys come in a burst (Chromium, Electron, Firefox;
/// `docs/COMPATIBILITY.md` 6.2).
///
/// Which earlier state: `lag` edits ago (set per key, so each word of a log can be
/// replayed exactly), or, with `clock` set, the latest state the app has reported by
/// then (`work`, `reportDelay`: the app applies one edit after the other).
///
/// Order: the app applies the input method's `insertText` after the keys sent before
/// it. Chromium source (main, read 09–10/11/2026): key events and `ImeCommitText` go
/// through the same `WidgetInputHandler` interface, and in the renderer both end in
/// `MainThreadEventQueue` (`WidgetInputHandlerImpl::RunOnMainThread`, `DispatchEvent`);
/// the compositor-thread hop of key events was not read. Firefox: the parent sends the
/// set-selection and insert-text events of a replacement to the content process after
/// the key events before them (`TextInputHandler.mm`, `InsertTextAsCommittingComposition`).
final class LateDocument: InPlaceClient {
    /// What the app answers from.
    enum Cache {
        /// The text and caret of the earlier state as they were (Firefox:
        /// `ContentCacheInParent` and `IMEInputHandler::mSelectedRange`, both updated
        /// only when the content process reports).
        case snapshot
        /// Chromium's browser-side cache (`render_widget_host_view_cocoa.mm`): the state
        /// the page reported last, plus every `insertText` with NSNotFound since (a key
        /// let through, the input method's own insertion at the caret), each written into
        /// `_availableText` at the caret the page reported (`_markedRange.location`), so
        /// later ones before earlier ones; `_textSelectionRange` is that caret plus the
        /// length of the latest one. `insertText` with a range is not written.
        case chromium
    }

    /// Where the caret goes when `insertText` replaces a range that ends before it.
    enum Replace {
        /// It stays after the text that follows, shifted by the change in length: Blink's
        /// `ReplaceTextAndKeepSelection` (Chrome text fields, contenteditable).
        case keepSelection
        /// It goes to the end of the inserted text: Blink's `EditContext::CommitText`
        /// (VS Code, whose editor uses the EditContext API by default, option
        /// `editor.editContext`), Firefox (selects the range, then inserts).
        case caretAfterText
    }

    /// Where the positions the app answers with, and the ranges it takes, count from.
    enum Origin {
        /// The start of the document.
        case document
        /// The start of the word being typed (Cursor's editor, runs of 10/11/2026 in
        /// `docs/PROGRESS.md`: at 100 ms between keys `selectedRange` was the number of
        /// letters of the word at every replacement, 0-based again after each space,
        /// also after a replacement whose text ends with a space; VS Code and Cursor's
        /// Agents input count from the start of the document).
        ///
        /// Measured, from the positions and texts of those logs: the answers; that a
        /// range starting past the text the app holds is dropped ("uo", range 4,1: the
        /// text stayed "uo"; `dropped`); that a range starting right at its end inserts
        /// there ("ve", range 2,1 with "ê" gave "veê"); that the page applies a range in
        /// the coordinates it has when it gets to it ("co", range 0,1 sent while the
        /// page had not applied "c", "o" gave "óo"); that the caret stays after the text
        /// that follows a replaced range ("óo rảnh", "èttlix": the keys after went to the
        /// end of the word; `Replace.keepSelection`, not the EditContext behaviour read
        /// in Chromium's source for VS Code).
        ///
        /// Assumed, not measured: every character that is not a letter or a digit
        /// starts a new word for the app, not only the space; a range that starts
        /// inside the text and ends past it is cut at its end; text read past the
        /// held text gives nothing; after ⌫ past the start of the word the app holds
        /// the word before the caret; the cache between the page and the input method
        /// is Chromium's (`Cache.chromium`), which fits the stale answers of the logs
        /// (the caret of the previous word plus one, or 1 right after a space) but not
        /// all of them ("ve" answered 3 once).
        case word
    }

    struct State {
        var text: [UInt16]
        var cursor: Int
        /// Text inserted at the caret by this edit (`insertText` with NSNotFound).
        var atCaret: [UInt16]? = nil
        /// When the app has applied this edit and told the input method's side about it.
        var reportAt: TimeInterval = -.infinity
        /// Where the text the app holds starts (`Origin.word`; 0 otherwise).
        var window = 0
    }
    private(set) var states: [State]
    var cache = Cache.snapshot
    var replace = Replace.keepSelection
    var origin = Origin.document
    /// Edits the answers are behind by (when `clock` is nil).
    var lag = 0
    /// Timed answers: the latest state reported at or before `clock`.
    var clock: TimeInterval?
    /// When the next edit reaches the app (timed answers).
    var sentAt: TimeInterval = 0
    /// Seconds the app takes to apply one edit, after the previous one (timed answers).
    var work: () -> TimeInterval = { 0 }
    var reportDelay: TimeInterval = 0
    private var lastApplied: TimeInterval = -.infinity
    /// For one key: answer with this text before the caret instead (a state no model
    /// above gives).
    var override: String?
    /// Calls during the current key (N3).
    var selections = 0, reads = 0, inserts = 0
    /// The text the latest read gave (nil: none).
    private(set) var lastRead: String?
    /// An `insertText` whose range is outside the real text (never expected).
    var badRanges = 0
    /// An `insertText` whose range starts past the text the app holds (`Origin.word`):
    /// the app drops it.
    private(set) var dropped = 0
    /// The largest number of edits an answer was behind (timed answers).
    private(set) var maxBehind = 0

    init(_ text: String = "") {
        let units = Array(text.utf16)
        states = [State(text: units, cursor: units.count)]
    }

    var text: String { String(decoding: states[states.count - 1].text, as: UTF16.self) }

    private var answer: State {
        if let override { let units = Array(override.utf16); return State(text: units, cursor: units.count) }
        let last = states.count - 1
        let index: Int
        if let clock {
            index = states.lastIndex { $0.reportAt <= clock } ?? 0
            maxBehind = max(maxBehind, last - index)
        } else {
            index = max(0, last - lag)
        }
        var state = states[index]
        if origin == .word {
            // The page reports the text it holds and the caret inside it.
            state.text.removeFirst(min(state.window, state.text.count))
            state.cursor -= state.window
            state.window = 0
        }
        if cache == .chromium, index < last {
            let caret = state.cursor
            var latest: [UInt16]?
            for later in states[(index + 1)...] {
                guard let units = later.atCaret, caret <= state.text.count else { continue }
                state.text.insert(contentsOf: units, at: caret)
                latest = units
            }
            if let latest { state.cursor = caret + latest.count }
        }
        return state
    }

    func selectedRange() -> NSRange {
        selections += 1
        return NSRange(location: answer.cursor, length: 0)
    }

    func text(in range: NSRange) -> String? {
        reads += 1
        let units = answer.text
        lastRead = nil
        guard range.location >= 0, range.length >= 0, range.location + range.length <= units.count else { return nil }
        lastRead = String(decoding: units[range.location..<(range.location + range.length)], as: UTF16.self)
        return String(decoding: units[range.location..<(range.location + range.length)], as: UTF16.self)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        inserts += 1
        var state = states[states.count - 1]
        var range = replacementRange.location == NSNotFound
            ? NSRange(location: state.cursor, length: 0) : replacementRange
        if origin == .word, replacementRange.location != NSNotFound {
            // The range counts from the start of the text the page holds when it applies it.
            let held = state.text.count - state.window
            guard range.location >= 0, range.length >= 0, range.location <= held else {
                dropped += 1
                state.atCaret = nil
                append(state)   // nothing changes; the answers stay one state per edit
                return
            }
            range = NSRange(location: state.window + range.location, length: min(range.length, held - range.location))
        }
        guard range.location >= 0, range.location + range.length <= state.text.count else {
            badRanges += 1
            return
        }
        let units = Array(string.utf16)
        state.text.replaceSubrange(range.location..<(range.location + range.length), with: units)
        let end = range.location + range.length
        if replacementRange.location == NSNotFound || state.cursor < end || replace == .caretAfterText {
            state.cursor = range.location + units.count
        } else {
            // The caret was after the range (keys the input method had not seen applied
            // yet): it stays after them, shifted by the change in length. The 1b texts
            // show this ("ạnn gửi", no stray "n" at the end of the text).
            state.cursor += units.count - range.length
        }
        state.atCaret = replacementRange.location == NSNotFound ? units : nil
        // Text that ends a word: the app holds a new, empty word from the caret on.
        if let unit = units.last, !Self.isWordUnit(unit) { state.window = state.cursor }
        append(state)
    }

    private func append(_ state: State) {
        var state = state
        if origin == .document {
            state.window = 0
        } else if state.cursor < state.window {
            // The caret went back past the start of the held text: the word before it.
            var start = min(state.cursor, state.text.count)
            while start > 0, Self.isWordUnit(state.text[start - 1]) { start -= 1 }
            state.window = start
        }
        if clock != nil {
            let applied = max(sentAt, lastApplied) + work()
            lastApplied = applied
            state.reportAt = applied + reportDelay
        }
        states.append(state)
    }

    /// A letter or a digit (the units of a word, as `InPlaceComposer.trailingWord`).
    private static func isWordUnit(_ unit: UInt16) -> Bool {
        guard let scalar = Unicode.Scalar(unit) else { return false }
        return CharacterSet.alphanumerics.contains(scalar)
    }

    /// An edit the app makes on its own (autocorrect, smart dashes): the new state.
    func appEdit(_ text: String) {
        let units = Array(text.utf16)
        append(State(text: units, cursor: units.count))
    }

    /// The caret moves without the input method being told (a click IMK does not report,
    /// the app itself): the new state.
    func moveCaret(to cursor: Int) {
        var state = states[states.count - 1]
        state.cursor = cursor
        state.atCaret = nil
        append(state)
    }

    /// What the app does with a key the input method left to it.
    func typed(_ route: KeyRoute) {
        switch route {
        case .character(let c):
            let n = inserts
            insertText(String(Character(c)), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            inserts = n
        case .backspace:
            var state = states[states.count - 1]
            guard state.cursor > 0 else { return }
            state.text.remove(at: state.cursor - 1)
            state.cursor -= 1
            state.atCaret = nil
            append(state)
        case .endWord:
            let n = inserts
            insertText("\n", replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            inserts = n
        case .ignore:
            break
        }
    }
}

/// Deterministic generator for the random sequences, lags and timings of the tests (SplitMix64).
struct SplitMix {
    var state: UInt64
    init(_ seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
    /// Uniform in [low, high].
    mutating func uniform(_ low: Double, _ high: Double) -> Double {
        low + (high - low) * Double(next() >> 11) / Double(1 << 53)
    }
}
