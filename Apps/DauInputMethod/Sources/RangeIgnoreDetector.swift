import Foundation

/// D43 (Ô bỏ qua vùng thay chữ): tells a field that takes the text of
/// `insertText(_:replacementRange:)` but ignores the range (Ghostty, terminals built on
/// xterm.js) from a text field, using only the `selectedRange` answers in-place mode
/// already asks for at keys that replace text (N3: no call of its own).
///
/// Measured (docs/PROGRESS.md, log of 11/11/2026, third typing round): a text field's
/// position grows with what is typed (up to 8 in Chrome, Safari and Sublime Text over
/// "toois vieetj "); Ghostty always answers {0,0}; the xterm.js test page answers 0–2.
///
/// An answer is **stuck** when no text field could give it:
/// - it is at most `terminalLimit` (the largest answer measured in a terminal), with no
///   selection;
/// - it is before the start of the current word plus what this composer added to the
///   word, at the oldest state the app may still answer from. An app may answer late by
///   `CursorTracker.lateLimit` keys, plus every key of the latest burst (D11, "App trả
///   lời chậm"); a key that itself comes in a burst is not judged at all, as at the start
///   of a document an app may then be behind every key (D11).
///
/// Counted from the start of the word, not of the activation: shortcuts that are menu
/// key equivalents never reach the input method (⌘A in Chrome's address bar, D11), so
/// the text before the word may have been replaced unseen. The word starts again where
/// the composer itself re-reads or starts over (D11 mismatch, re-sync, D20 seed).
///
/// One stuck answer is only a suspicion: the same unseen edit inside a word ("tốt", ⌘A,
/// "toots" with no space; "toi", ⌘A, ⌫, "s") gives one. The field is taken for one that
/// ignores the range at a second stuck answer that is also below the first one plus
/// everything this composer added since (at the oldest state the app may answer from):
/// a text field's position grows with what is typed, a terminal's does not. An answer
/// above `terminalLimit` clears the suspicion, and it lasts until the end of the word
/// after its own (in a terminal the next stuck answer comes within a word or two; in a
/// text field an unseen edit in the middle of a word is rare, two that close rarer).
///
/// Per client and per activation (`reset`): a new activation or another client is judged
/// from the start again.
///
/// Pure value type, no IMK calls, unit tested in DauInputMethodTests.
struct RangeIgnoreDetector {
    /// How to send a replacement once the field is known to ignore the range (D43, "Lúc
    /// gửi").
    enum Send: Equatable {
        /// One `insertText` at the cursor while the app handles the key (xterm.js).
        case inKey
        /// The key goes to the app, the fix right after (Ghostty, which drops text that
        /// starts with a control character while it handles a key).
        case afterKey
    }

    /// The largest `selectedRange` location measured in a field that ignores the range
    /// (xterm.js test page, 11/11/2026).
    static let terminalLimit = 2

    /// The units this composer added to the document since the activation (letters it
    /// typed, let through or replaced, minus what it erased), after each of the latest
    /// keys, oldest first.
    private(set) var totals: [Int] = [0]
    /// Index in `totals` of the state at the start of the current word.
    private var wordStart = 0
    /// The latest keys that came in a burst (`InPlaceComposer.settleInterval`).
    private var burst = 0
    /// The first stuck answer (location, `totals` at that key), until an answer above
    /// `terminalLimit`.
    private(set) var suspicion: (location: Int, total: Int)?
    /// Words that ended since `suspicion`.
    private var wordsSinceSuspicion = 0
    /// An answer of 1…`terminalLimit` came in this activation: the field answers more than
    /// Ghostty's constant 0 (xterm.js).
    private(set) var sawSmallNonZero = false
    /// Set once the field is known to ignore the range, for the rest of the activation.
    private(set) var send: Send?

    /// States kept: enough for any lateness that is judged (a key in a burst is not, and
    /// the window reaches back `lateLimit` keys plus the burst before the key).
    static let stateLimit = 64

    /// New activation or new client.
    mutating func reset() {
        self = RangeIgnoreDetector()
    }

    /// The composer started the word over at the app's cursor (D11, D20).
    mutating func startWord() {
        // The burst goes on: an app may be behind keys of the previous word too.
        wordStart = totals.count - 1
    }

    /// The word ended, or the cursor may have moved (shortcut, arrow, click, Return/Tab).
    mutating func endWord() {
        startWord()
        guard suspicion != nil else { return }
        wordsSinceSuspicion += 1
        if wordsSinceSuspicion > 1 { suspicion = nil }
    }

    /// A key was handled: it changed the document by `delta` units.
    mutating func keyHandled(delta: Int, inBurst: Bool) {
        // Saturating: a client's odd answer must never trap here (D18).
        totals.append((totals.last ?? 0).addingSaturated(delta))
        if totals.count > Self.stateLimit {
            let drop = totals.count - Self.stateLimit
            totals.removeFirst(drop)
            wordStart = max(0, wordStart - drop)
        }
        burst = inBurst ? burst + 1 : 0
    }

    /// `totals` at the oldest state the app may still answer from (`CursorTracker.lateLimit`
    /// keys back, plus the keys of the latest burst), and whether that reaches back to the
    /// start of the current word.
    private var oldest: (total: Int, inWord: Bool) {
        let window = min(CursorTracker.lateLimit + burst, totals.count - 1)
        let states = totals.suffix(window + 1)
        let inWord = totals.count - 1 - window > wordStart
        return (states.min() ?? 0, inWord)
    }

    /// The smallest location a text field may answer with now, counted from the start of
    /// the current word (itself at 0 or later). 0 when the oldest state the app may answer
    /// from reaches the start of the word.
    var minimumAnswer: Int {
        let (total, inWord) = oldest
        guard inWord else { return 0 }
        return max(0, total.subtractingSaturated(totals[wordStart]))
    }

    /// Any `selectedRange` answer of this client (also at the start of a word, D20): only
    /// tells which way to send (`Send`) and clears a suspicion.
    mutating func note(_ selection: NSRange) {
        guard selection.location != NSNotFound, selection.location >= 0 else { return }
        if selection.location > Self.terminalLimit {
            suspicion = nil
        } else if selection.location > 0 {
            sawSmallNonZero = true
        }
    }

    /// An answer at a key that replaces text in the current word (`inBurst`: the key came
    /// in a burst). Returns how to send from now on when this answer shows the field
    /// ignores the range.
    mutating func observe(_ selection: NSRange, inBurst: Bool) -> Send? {
        if let send { return send }
        note(selection)
        guard !inBurst, selection.location != NSNotFound, selection.length == 0,
              selection.location >= 0, selection.location <= Self.terminalLimit,
              selection.location < minimumAnswer else { return nil }
        let total = totals.last ?? 0
        guard let first = suspicion else {
            suspicion = (selection.location, total)
            wordsSinceSuspicion = 0
            return nil
        }
        // A text field has grown by at least what was added since the first answer, minus
        // the keys it may still be behind by.
        guard selection.location < first.location.addingSaturated(oldest.total.subtractingSaturated(first.total)) else {
            suspicion = (selection.location, total)
            wordsSinceSuspicion = 0
            return nil
        }
        // Ghostty answers 0 every time; xterm.js also 1 or 2 (the probe of 11/11/2026).
        let mode: Send = sawSmallNonZero ? .inKey : .afterKey
        send = mode
        return mode
    }
}
