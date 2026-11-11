import Foundation

/// Method A of the open question A/B (DECISIONS.md): ask the client for `selectedRange`
/// on every key whose result replaces text, and compute the absolute replacement range
/// from it. On top of that, remember where the cursor should be after each key of the
/// current word, so a cursor that moved without the input method noticing (a click IMK
/// did not report, an app that edited the text) is caught before anything is replaced
/// (D11: "selectedRange khác vị trí dự đoán").
///
/// It also follows the cursor across word boundaries (`known`), with the edits this
/// composer made or let through (`edits`), so an app that answers from before its latest
/// edits (Chrome with a busy page, M6: the page applies keys late, `selectedRange` and
/// `attributedSubstring` answer from the text as it was) can be told from an app whose
/// text really changed: the text the app gives, plus the edits it has not applied yet,
/// must be the word the engine holds (`rebuild`). The caller decides; nothing here talks
/// to the client.
///
/// Ranges are UTF-16 offsets from the start of the client's document (NSRange).
/// Pure value type, no IMK calls, unit tested in DauInputMethodTests.
struct CursorTracker: Equatable {
    /// Where the cursor should be now, if known. Only kept inside one word: across a word
    /// boundary apps may legitimately edit text (autocorrect, smart quotes), so a mismatch
    /// there would throw away good state.
    private(set) var expected: Int?

    /// Where the cursor is once the app has applied every edit this composer made or let
    /// through, kept across word boundaries; nil when unknown (after a reset, Return,
    /// arrows, a click). Unlike `expected`, a different answer from the app is not a
    /// mismatch by itself: the app may have edited the text at a word boundary.
    private(set) var known: Int?
    /// The text right before `known` that this composer typed or inserted, oldest first
    /// (UTF-16, at most `tailLimit` units; may be shorter than the text that is there).
    private(set) var tail: [UInt16] = []
    /// The latest edits, oldest first (at most `editLimit`).
    private(set) var edits: [Edit] = []
    /// Enough for an app that falls far behind a burst of keys (M6: in the simulation of
    /// VS Code and Firefox at 0 ms, `RapidKeysTests`, answers were over a hundred edits
    /// behind); one edit is a few dozen bytes, and `rebuild` replays only the counts
    /// whose caret matches the answer.
    static let editLimit = 256
    /// Long enough to check, past `editLimit` units of edits, the text the app answers
    /// with before them (`rebuild`, `InPlaceComposer.readLength` units).
    static let tailLimit = 512
    /// How many edits an app may be behind for `rebuild` when the keys came at a human
    /// pace. In the 1b run (M6, Chrome with a page blocked 300 ms every second, keys
    /// 100 ± 30 ms apart) every late answer was one key behind. More would also take for
    /// late an app whose text was replaced by the same letters at the same place (⌘A the
    /// input method never sees, then the word typed again), which D11 must re-read
    /// instead. Edits made by keys that came in a burst add to it (`burst`), with a
    /// stricter check.
    static let lateLimit = 2

    /// The key being handled came less than `InPlaceComposer.settleInterval` after the
    /// previous one (set by the composer for each key).
    var keyInBurst = false
    /// How many of the latest edits were made by keys that came in a burst, one after
    /// the other: no person can click or press ⌘A between them, and an app that applies
    /// keys late may be behind all of them (M3: Chrome, VS Code, Firefox wrong under
    /// 10 ms; `docs/COMPATIBILITY.md` 6.2).
    private(set) var burst = 0

    /// One edit of the document made by this composer or by a key it let through.
    struct Edit: Equatable {
        /// The cursor before the edit.
        var cursor: Int
        /// The range replaced (it ends at or before `cursor`).
        var location: Int
        var deleted: Int
        /// The units removed, when this composer knows them (`tail`).
        var deletedText: [UInt16]?
        var inserted: [UInt16]
        /// Inserted at the app's caret without a range (`insertText` with NSNotFound: a
        /// key let through, or this composer's insertion at the cursor). Chromium writes
        /// such text into the cache it answers from at once (`rebuild`).
        var atCaret = false
    }

    enum Plan: Equatable {
        /// Replace this range (deleteCount UTF-16 units before the cursor).
        case replace(NSRange)
        /// The client does not support document access (selectedRange is NSNotFound):
        /// `replacementRange` would be ignored, so in-place replacement cannot work.
        case unsupported
        /// The cursor (or the start of the selection) is not where this word left it, or
        /// there is not enough text before the cursor. The engine state no longer matches the app.
        case mismatch
    }

    /// Decides the replacement range for `deleteCount` UTF-16 units before the cursor,
    /// given the selection the client reported. An answer outside `ClientRange.limit`
    /// (negative, huge) is no document access, as NSNotFound is (D18).
    func plan(selection reported: NSRange, deleteCount: Int) -> Plan {
        let selection = ClientRange.sanitized(reported)
        if selection.location == NSNotFound { return .unsupported }
        if deleteCount < 0 { return .mismatch }
        if let expected, expected != selection.location { return .mismatch }
        if selection.location < deleteCount { return .mismatch }
        // A selection that starts at the cursor while the engine holds a word is an app's
        // inline autocomplete (browser address bars, Spotlight): every way the user selects
        // text (mouse, ⇧ + arrows, ⌘A) resets the engine first. Replace the suggestion
        // with the word, as any typed key replaces a selection (D11).
        return .replace(NSRange(location: selection.location - deleteCount,
                                length: deleteCount + selection.length))
    }

    // MARK: - Edits

    /// The input method replaced `range` with `text`, the cursor being at the end of
    /// `range` (or `cursor`, when the range ends before it: keys the app applies after).
    /// `atCaret`: the text was in fact inserted at the app's caret without a range (a
    /// key let through at a position read from the app, D20).
    ///
    /// Positions this tracker keeps stay in 0...`ClientRange.limit`: a range or cursor
    /// outside it (D18: a client that answered anything) forgets the position instead.
    mutating func didReplace(_ range: NSRange, text: String, cursor: Int? = nil, atCaret: Bool = false) {
        let end = cursor ?? range.location.addingSaturated(range.length)
        guard ClientRange.isUsable(range), ClientRange.isUsable(position: end) else {
            invalidate()
            return
        }
        record(cursor: end, location: range.location,
               deleted: range.length, inserted: Array(text.utf16), atCaret: atCaret)
        expected = known
    }

    /// The input method inserted `text` at the cursor without asking for its position
    /// (deleteCount 0, replacementRange NSNotFound).
    mutating func didInsertAtCursor(_ text: String) {
        let length = text.utf16.count
        if let e = expected {
            let moved = e.addingSaturated(length)
            expected = ClientRange.isUsable(position: moved) ? moved : nil
        }
        if let k = known { record(cursor: k, location: k, deleted: 0, inserted: Array(text.utf16), atCaret: true) }
    }

    /// The key went to the app unchanged and the app inserts `text`.
    mutating func passedThrough(_ text: String) {
        didInsertAtCursor(text)
    }

    /// The Delete key went to the app unchanged inside a word: it removes one character.
    /// Every letter the engine tracks is one UTF-16 unit (Vietnamese precomposed letters
    /// are in the BMP).
    mutating func backspacePassedThrough() {
        if let e = expected { expected = e > 0 ? e - 1 : nil }
        if let k = known {
            if k > 0 { record(cursor: k, location: k - 1, deleted: 1, inserted: []) } else { forgetPosition() }
        }
    }

    /// The Delete key went to the app with no word: it removes the character before the
    /// cursor, which is known only if this composer typed it and it is one unit that
    /// cannot combine with what precedes it (a space, a punctuation mark, a precomposed
    /// letter).
    mutating func backspaceOutsideWord() {
        expected = nil
        guard let k = known, k > 0, let last = tail.last, Self.isWholeCharacter(last) else {
            forgetPosition()
            return
        }
        record(cursor: k, location: k - 1, deleted: 1, inserted: [])
    }

    /// The word ended (a word-ending key typed here, D4; or ⌫ removed its last letter):
    /// the next word starts with no expected position (`expected`), the position itself
    /// stays known.
    mutating func endWord() {
        expected = nil
    }

    /// The position is known from the app (D20 read): start following from there.
    /// A location outside `ClientRange.limit` (D18) is not a position: forgotten.
    mutating func anchor(at location: Int) {
        if known != location { forgetPosition() }
        guard ClientRange.isUsable(position: location) else { return }
        known = location
    }

    /// Forget the expected position: engine reset, focus or client changed.
    mutating func invalidate() {
        expected = nil
        forgetPosition()
    }

    private mutating func forgetPosition() {
        known = nil
        tail = []
        edits = []
        burst = 0
    }

    private mutating func record(cursor: Int, location: Int, deleted: Int, inserted: [UInt16],
                                 atCaret: Bool = false) {
        if known != cursor {
            // Not where this composer thought: follow from the app's answer.
            tail = []
            edits = []
            burst = 0
        }
        burst = keyInBurst ? min(burst + 1, Self.editLimit) : 0
        let back = cursor - location      // units from the start of the range to the cursor
        var deletedText: [UInt16]?
        if back >= 0, deleted >= 0, deleted <= back, back <= tail.count {
            let start = tail.count - back
            deletedText = Array(tail[start..<(start + deleted)])
            tail.replaceSubrange(start..<(start + deleted), with: inserted)
        } else {
            tail = back == deleted ? inserted : []
        }
        if tail.count > Self.tailLimit { tail.removeFirst(tail.count - Self.tailLimit) }
        edits.append(Edit(cursor: cursor, location: location, deleted: deleted,
                          deletedText: deletedText, inserted: inserted, atCaret: atCaret))
        if edits.count > Self.editLimit { edits.removeFirst(edits.count - Self.editLimit) }
        // Every caller passes positions in 0...ClientRange.limit and short texts, so this
        // cannot overflow; past the limit the position is forgotten (D18).
        let next = cursor.addingSaturated(inserted.count).subtractingSaturated(deleted)
        if ClientRange.isUsable(position: next) { known = next } else { forgetPosition() }
    }

    /// One UTF-16 unit that the app's Delete removes alone: not half of a surrogate pair,
    /// not a combining mark or joiner.
    static func isWholeCharacter(_ unit: UInt16) -> Bool {
        guard let scalar = Unicode.Scalar(unit) else { return false }
        switch scalar.properties.generalCategory {
        case .nonspacingMark, .spacingMark, .enclosingMark, .format, .control, .surrogate: return false
        default: return true
        }
    }

    // MARK: - An app that answers late

    /// The app answered `selection` while it had not applied the last `m` edits yet (its
    /// cursor then was before them). Returns the text before `known`: the text the app
    /// gave (`snapshot`, ending at `selection`) with those edits applied, for the first
    /// `m` (latest edits first) that fits and that `accept` takes. nil: not an app
    /// answering late (or no way to tell).
    ///
    /// The text the app gives is one of two forms (sources in `docs/ARCHITECTURE.md`,
    /// "App trả lời chậm"): the text as it was before those edits (Firefox, and Chrome
    /// when none of them was inserted at the caret); or that text plus the latest of
    /// them that was inserted at the caret (`Edit.atCaret`), which Chromium writes into
    /// its cache at once at the caret the page last reported, the answer then ending
    /// after it.
    ///
    /// Every edit whose removed text is known must find that text where it applies;
    /// `requireDeletedText`: an edit that removes text this composer does not know fails.
    /// `m` is at most `lateLimit`, plus the edits made in the latest burst of keys
    /// (`burst`); past `lateLimit`, the text the app gave before those edits must also be
    /// the text this composer typed there (`tail`), over at least two units, or the edits
    /// must start the document in one burst with this key (`typedHere`).
    ///
    /// Past `lateLimit` an edit that removes text this composer does not know fails too
    /// (a replacement made at the app's answer, away from the followed position, starts
    /// `tail` over): replayed, it fits any text and writes this composer's own text over
    /// it, so the comparison with `tail` would compare `tail` with itself. That took an
    /// app that was on time for a late one where positions count from the start of the
    /// word being typed (Cursor's editor, M6 runs of 10/11/2026: the answer was the
    /// caret the previous replacement had in its own word; "uoongs" gave "uongs").
    ///
    /// Within `lateLimit` the text this composer typed, where it knows it, must not say
    /// otherwise: the text rebuilt and `tail` agree over the units both have (`agrees`).
    /// After a replaced word of one letter the same app answers two before the followed
    /// position with the letters of the new word, which replayed gave the engine's word
    /// though another letter was typed there (run of 11:44, 100 ms: "owr ddaau" gave
    /// "ở dâu").
    func rebuild(_ snapshot: [UInt16], at selection: NSRange,
                 requireDeletedText: Bool = false, accept: ([UInt16]) -> Bool) -> [UInt16]? {
        // D18: an answer outside `ClientRange.limit` proves nothing.
        let selection = ClientRange.sanitized(selection)
        let end = selection.location
        guard let known, selection.length == 0, end != NSNotFound, end != known else { return nil }
        let count = min(Self.lateLimit + burst, edits.count)
        var latestAtCaret: [UInt16]?
        for m in stride(from: 1, through: count, by: 1) {
            let first = edits[edits.count - m]
            if latestAtCaret == nil, first.atCaret, !first.inserted.isEmpty { latestAtCaret = first.inserted }
            var forms: [[UInt16]] = []
            if first.cursor == end { forms.append(snapshot) }
            if let units = latestAtCaret, first.cursor + units.count == end, snapshot.count >= units.count,
               snapshot.suffix(units.count).elementsEqual(units) {
                forms.append(Array(snapshot.dropLast(units.count)))
            }
            for before in forms {
                guard let text = replay(before, endingAt: first.cursor, last: m,
                                        requireDeletedText: requireDeletedText || m > Self.lateLimit),
                      first.cursor - before.count + text.count == known else { continue }
                if m > Self.lateLimit,
                   !typedHere(text, before: before.count, fromStart: first.cursor == before.count) { continue }
                if m <= Self.lateLimit, !agrees(text) { continue }
                if accept(text) { return text }
            }
        }
        // Chrome's cache is not always the text as it was some edits ago, plus the latest
        // key: the page may answer between its own updates (1d run: "hoi" + r answered
        // one behind, and neither form above fit). So the text read may be the text this
        // composer typed with any `d` of its latest units missing.
        let d = known - end
        if d >= 1, d <= Self.lateLimit, let text = withMissingUnits(snapshot, missing: d), accept(text) {
            return text
        }
        return nil
    }

    /// `before` (the app's text, ending at `cursor`) with the last `m` edits applied, or
    /// nil if one of them does not fit there.
    private func replay(_ before: [UInt16], endingAt cursor: Int, last m: Int, requireDeletedText: Bool) -> [UInt16]? {
        let base = cursor - before.count
        var text = before
        for edit in edits.suffix(m) {
            let start = edit.location - base, stop = start + edit.deleted
            guard edit.cursor == base + text.count, start >= 0, stop <= text.count else { return nil }
            if let removed = edit.deletedText {
                guard text[start..<stop].elementsEqual(removed) else { return nil }
            } else if requireDeletedText && edit.deleted > 0 {
                return nil
            }
            text.replaceSubrange(start..<stop, with: edit.inserted)
        }
        return text
    }

    /// `text` (ending at `known`) and `tail` are the same over the units both have.
    private func agrees(_ text: [UInt16]) -> Bool {
        let n = min(text.count, tail.count)
        return text.suffix(n).elementsEqual(tail.suffix(n))
    }

    /// `text` (ending at `known`, its first `count` units read from the app) ends with
    /// `tail`, and `tail` reaches at least two units into the part read: the app's own
    /// text, not only this composer's edits, is what was typed there. `fromStart`: the
    /// part read starts the document; then one unit is enough if `tail` covers all of it.
    /// With less than that (nothing read, a short `tail`), nothing tells a late answer
    /// from a text that was replaced (a field cleared and typed again).
    ///
    /// One case has nothing to read and still counts: the edits start the document
    /// (`fromStart`, `count` 0), so no text of the app's can precede them, `tail` is all
    /// of `text`, and the key being handled is itself in the burst (`keyInBurst`): every
    /// edit past `lateLimit` and this key came one after the other, with no time for a
    /// click IMK does not report (D11). That is the first word of a new document the app
    /// is slow to start (M6, fast-key run of 10/11/2026: VS Code, "Chieeuf" gave "êhieuf",
    /// the answer from before every key of the document). After a pause the answer
    /// stands, as before.
    private func typedHere(_ text: [UInt16], before count: Int, fromStart: Bool) -> Bool {
        let n = min(text.count, tail.count)
        if fromStart, count == 0 {
            return keyInBurst && tail.count == text.count && text.elementsEqual(tail)
        }
        let reach = n - (text.count - count)
        guard reach >= 2 || (fromStart && count >= 1 && reach == count) else { return false }
        return text.suffix(n).elementsEqual(tail.suffix(n))
    }

    /// `snapshot` (ending `missing` units before `known`) is `tail` with `missing` of its
    /// last `missing + lateLimit` units left out, compared over at least two units: then
    /// the text before `known` is the start of `snapshot` followed by `tail`. nil if not.
    ///
    /// A unit that is missing comes after one that was compared: what Chromium's cache
    /// lacks is what the page has not reported, after the text it has. Text that is
    /// `tail` without its first units is an app that holds only the word being typed
    /// (Cursor's editor, run of 11:44: "co" read where "ừ co" was typed, "uwf cos" gave
    /// "ừ co").
    private func withMissingUnits(_ snapshot: [UInt16], missing d: Int) -> [UInt16]? {
        let n = min(snapshot.count, tail.count - d)
        guard n >= 2 else { return nil }
        let seen = Array(snapshot.suffix(n))
        let window = min(tail.count, d + Self.lateLimit)
        func fits(_ left: [UInt16], dropping: Int, from start: Int) -> Bool {
            if dropping == 0 { return Array(left.suffix(n)) == seen }
            for i in stride(from: start, to: left.count, by: 1) {
                var shorter = left
                shorter.remove(at: i)
                if fits(shorter, dropping: dropping - 1, from: i) { return true }
            }
            return false
        }
        guard fits(tail, dropping: d, from: max(tail.count - window, tail.count - (n + d) + 1)) else { return nil }
        return Array(snapshot.dropLast(n)) + Array(tail.suffix(n + d))
    }
}


/// D18 (Phòng thủ với IMK): every `selectedRange` answer goes through `sanitized` before
/// any arithmetic in in-place mode (`InPlaceComposer`, `CursorTracker`,
/// `RangeIgnoreDetector`). A client may answer anything: NSNotFound (no document
/// access), a negative value, or a huge positive one that would overflow
/// `location + length` or `location - deleteCount + …` and trap.
///
/// The ceiling is `limit` (Int32.max UTF-16 units, 4 GiB of text): far beyond any text
/// an app shows in one field, and low enough that a position at the ceiling plus every
/// amount this module adds to it (a word, `CursorTracker.tailLimit` units, a key's
/// delta) stays far from Int.max on a 64-bit Mac. An answer past it, or with a negative
/// part, is taken as no document access (NSNotFound): `CursorTracker.plan` says
/// `.unsupported`, so nothing is replaced and nothing is read (the safe branch: the key
/// starts a word on its own, D11).
enum ClientRange {
    /// Largest location, length or end (location + length) accepted from a client.
    static let limit = Int(Int32.max)

    /// The answer "no document access".
    static let notFound = NSRange(location: NSNotFound, length: NSNotFound)

    /// `range` when both parts are in 0...`limit` and so is its end; `notFound` otherwise
    /// (also for NSNotFound itself, in either part).
    static func sanitized(_ range: NSRange) -> NSRange {
        isUsable(range) ? range : notFound
    }

    /// Both parts and the end are in 0...`limit`.
    static func isUsable(_ range: NSRange) -> Bool {
        let location = range.location, length = range.length
        guard location >= 0, length >= 0, location <= limit, length <= limit else { return false }
        return location + length <= limit  // no overflow: both are at most Int32.max
    }

    /// A position in 0...`limit`.
    static func isUsable(position: Int) -> Bool {
        position >= 0 && position <= limit
    }
}

extension Int {
    /// `self + other`, clamped to Int.min...Int.max instead of trapping (D18).
    func addingSaturated(_ other: Int) -> Int {
        let (sum, overflow) = addingReportingOverflow(other)
        guard overflow else { return sum }
        return other > 0 ? .max : .min
    }

    /// `self - other`, clamped to Int.min...Int.max instead of trapping (D18).
    func subtractingSaturated(_ other: Int) -> Int {
        let (difference, overflow) = subtractingReportingOverflow(other)
        guard overflow else { return difference }
        return other < 0 ? .max : .min
    }
}
