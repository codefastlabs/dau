import Foundation

/// D43 (Ô bỏ qua vùng thay chữ): tells a field that takes the text of
/// `insertText(_:replacementRange:)` but ignores the range (Ghostty, terminals built on
/// xterm.js) from a text field, using only the `selectedRange` answers in-place mode
/// already asks for at keys that replace text (N3: no call of its own).
///
/// Measured (docs/Progress.md, log of 11/11/2026, third typing round): a text field's
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
/// Positions alone are not enough: a text field that reports a constant position (one
/// that draws its own text) or an app stalled at the start of an empty document also
/// gives stuck answers. So at the key where the positions are enough (`observe` returns a
/// candidate), the composer reads the text before the cursor once (`evidence`, the N3
/// exception of D43) and either takes the field for one that ignores the range
/// (`confirm`) or, when the app gives back the text this composer typed (`isOwnText`),
/// does not (`refute`). Either way the field is not judged again in the activation.
///
/// Per client and per activation (`reset`): a new activation or another client is judged
/// from the start again; a click or a reset inside the activation keeps the verdict.
///
/// Pure value type, no IMK calls, unit tested in DauInputMethodTests.
struct RangeIgnoreDetector {
    /// How to send a replacement once the field is known to ignore the range (D43, "Lúc
    /// gửi").
    enum Send: Equatable {
        /// xterm.js: it would take the fix as one `insertText` at the cursor while it
        /// handles the key; D43 replaces it in place instead (`InPlaceComposer.eraseMode(for:)`).
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
    /// The positive evidence read showed a text field that reports a wrong position: not
    /// judged again for the rest of the activation.
    private(set) var refuted = false
    /// The latest units this composer put before the cursor in this activation, as far
    /// as it knows (oldest first, at most `typedLimit`): what the evidence read is
    /// compared with.
    private(set) var typed: [UInt16] = []
    /// UTF-16 units read for the positive evidence: as many as a D20 read
    /// (`InPlaceComposer.readLength`), enough for the word being typed and what precedes it.
    static let evidenceLength = 16
    static let typedLimit = 64

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

    /// This composer, or the key it let through, removed the `removing` units before the
    /// cursor and put `inserting` there (for `typed`; `keyHandled` gets the count).
    mutating func edited(removing: Int, inserting: some Collection<UInt16>) {
        typed.removeLast(min(max(0, removing), typed.count))
        typed.append(contentsOf: inserting)
        if typed.count > Self.typedLimit { typed.removeFirst(typed.count - Self.typedLimit) }
    }

    /// The key went to the app: Delete removed the character before the cursor, any
    /// other character key typed itself.
    mutating func keyWentThrough(_ route: KeyRoute) {
        switch route {
        case .character(let c):
            edited(removing: 0, inserting: String(Character(c)).utf16)
        case .backspace:
            // A character this composer knows is one unit, or two for a surrogate pair.
            let pair = typed.count >= 2 && UTF16.isTrailSurrogate(typed[typed.count - 1])
                && UTF16.isLeadSurrogate(typed[typed.count - 2])
            edited(removing: pair ? 2 : 1, inserting: [])
        default:
            break
        }
    }

    /// Where to read for the positive evidence, and the units this composer typed there.
    /// The position the app reports is the one in doubt, so the read ends where this
    /// composer followed the cursor to, counting from where it was at the activation as
    /// 0: right for a field that was empty then (the case the evidence must catch: the
    /// fake that always answers {0,0}, an app stalled at the start of an empty document),
    /// and at worst a read of other text, which only keeps the field recognized as before
    /// the evidence (D43, "Hệ quả đã chấp nhận"). nil: nothing of this composer's own to compare.
    var evidence: (range: NSRange, typed: [UInt16])? {
        guard send == nil, !refuted else { return nil }
        let end = max(0, totals.last ?? 0)
        let count = min(Self.evidenceLength, typed.count, end)
        guard count > 0 else { return nil }
        return (NSRange(location: end - count, length: count), Array(typed.suffix(count)))
    }

    /// The candidate of `observe` stands: the field ignores the range.
    mutating func confirm(_ mode: Send) {
        guard !refuted else { return }
        send = mode
    }

    /// The candidate of `observe` is a text field after all.
    mutating func refute() {
        guard send == nil else { return }
        refuted = true
        suspicion = nil
    }

    /// Whether `read` (the client's text of `evidence.range`) is the text this composer
    /// typed there (`typed`): then the client is a text field that reports a wrong
    /// position. Compared without tone marks, case or đ (`folded`), from the start of the
    /// range, because an app that answers late (D11, "App trả lời chậm") may not have
    /// applied the latest keys or the replacements of the word yet ("vie" read where
    /// "viê" was typed), or may give back less than was asked (an app clamps the range to
    /// its text). What was read must match up to its last word plus that word's first
    /// letter, and hold a letter: Ghostty gives no text or the text selected on screen
    /// (docs/research/TerminalAndUnderline.md), xterm.js the content of its hidden
    /// textarea, neither of which lines up with what was typed.
    static func isOwnText(_ read: String, typed: [UInt16]) -> Bool {
        // A hostile client may answer with a lot of text (D18): only the start counts.
        let head = String(decoding: read.utf16.prefix(evidenceLength * 2), as: UTF16.self)
        let got = folded(head)
        let own = folded(String(decoding: typed, as: UTF16.self))
        var common = 0
        while common < got.count, common < own.count, got[common] == own[common] { common += 1 }
        var wordStart = got.count
        while wordStart > 0, isWordScalar(got[wordStart - 1]) { wordStart -= 1 }
        let needed = wordStart < got.count ? wordStart + 1 : got.count
        guard needed > 0, common >= needed else { return false }
        return got[..<common].contains { CharacterSet.letters.contains($0) }
    }

    /// `text` without combining marks, in lower case, with đ as d.
    static func folded(_ text: String) -> [Unicode.Scalar] {
        text.decomposedStringWithCanonicalMapping.lowercased().unicodeScalars.compactMap { scalar in
            if scalar.properties.generalCategory == .nonspacingMark { return nil }
            return scalar == "\u{111}" ? "d" : scalar
        }
    }

    private static func isWordScalar(_ scalar: Unicode.Scalar) -> Bool {
        CharacterSet.alphanumerics.contains(scalar)
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
    /// in a burst). Returns a candidate, how to send from now on, when the positions are
    /// enough to take the field for one that ignores the range; the caller then reads the
    /// positive evidence and calls `confirm` or `refute`. nil once that is decided.
    mutating func observe(_ selection: NSRange, inBurst: Bool) -> Send? {
        guard send == nil, !refuted else { return nil }
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
        return sawSmallNonZero ? .inKey : .afterKey
    }
}
