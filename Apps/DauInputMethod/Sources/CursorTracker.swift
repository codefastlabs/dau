import Foundation

/// Where the caret is in the client's document, for in-place replacement (D11).
///
/// Inside a word it predicts the caret after each key, so a caret that moved without the
/// input method noticing (a click IMK did not report, an app edit) is caught before anything
/// is replaced. Across words it follows the caret with the edits leading to it, so an app
/// that answers from before its latest edits can be told from one whose text changed
/// (`rebuild`). Nothing here talks to the client; positions are UTF-16 offsets from the
/// start of the document (NSRange).
struct CursorTracker: Equatable {
    /// Where the caret should be after the latest key of the word being typed; nil at the
    /// start of a word. Not kept across a word boundary, where apps legitimately edit text
    /// (autocorrect, smart quotes).
    private(set) var predictedCaret: Int?
    /// The caret followed across words, and the edits that led to it.
    private(set) var followed = FollowedText()
    /// How many of the latest edits a late answer may lack.
    var lateness = LatenessBudget()

    enum Plan: Equatable {
        /// Replace this range (deleteCount UTF-16 units before the cursor).
        case replace(NSRange)
        /// No document access: `replacementRange` would be ignored.
        case unsupported
        /// The caret is not where this word left it, or there is not enough text before it.
        case mismatch
    }

    /// The replacement range for `deleteCount` UTF-16 units before the caret, given the
    /// selection the client reported.
    func plan(selection reported: NSRange, deleteCount: Int) -> Plan {
        let selection = ClientRange.sanitized(reported)
        if selection.location == NSNotFound { return .unsupported }
        if deleteCount < 0 { return .mismatch }
        if let predictedCaret, predictedCaret != selection.location { return .mismatch }
        if selection.location < deleteCount { return .mismatch }
        // A selection starting at the caret while a word is being typed is an app's inline
        // autocomplete: every way the user selects text resets the engine first. The word
        // replaces it, as any typed key replaces a selection (D11).
        return .replace(NSRange(location: selection.location - deleteCount,
                                length: deleteCount + selection.length))
    }

    // MARK: - Edits

    /// The input method replaced `range` with `text`. `cursor`: the caret, when the range
    /// ends before it (keys the app applies after). `atCaret`: the text was in fact inserted
    /// at the app's caret without a range. A range or cursor outside `ClientRange.limit`
    /// forgets the caret (D18).
    mutating func didReplace(_ range: NSRange, text: String, cursor: Int? = nil, atCaret: Bool = false) {
        let end = cursor ?? range.location.addingSaturated(range.length)
        guard ClientRange.isUsable(range), ClientRange.isUsable(position: end) else {
            invalidate()
            return
        }
        record(cursor: end, location: range.location,
               deleted: range.length, inserted: Array(text.utf16), atCaret: atCaret)
        predictedCaret = followed.caret
    }

    /// The input method inserted `text` at the caret without asking where it is.
    mutating func didInsertAtCursor(_ text: String) {
        let length = text.utf16.count
        if let predicted = predictedCaret {
            let moved = predicted.addingSaturated(length)
            predictedCaret = ClientRange.isUsable(position: moved) ? moved : nil
        }
        if let caret = followed.caret {
            record(cursor: caret, location: caret, deleted: 0, inserted: Array(text.utf16), atCaret: true)
        }
    }

    /// The input method typed a character the engine left unchanged (N3).
    mutating func typedAtCaret(_ text: String) {
        didInsertAtCursor(text)
    }

    /// Delete went to the app inside a word: it removes one letter, one UTF-16 unit
    /// (Vietnamese precomposed letters are in the BMP).
    mutating func backspacePassedThrough() {
        if let predicted = predictedCaret { predictedCaret = predicted > 0 ? predicted - 1 : nil }
        if let caret = followed.caret {
            if caret > 0 {
                record(cursor: caret, location: caret - 1, deleted: 1, inserted: [])
            } else {
                forgetFollowedCaret()
            }
        }
    }

    /// Delete went to the app with no word: what it removes is known only if this composer
    /// typed it and it is one unit that cannot combine with what precedes it.
    mutating func backspaceOutsideWord() {
        predictedCaret = nil
        guard let caret = followed.caret, caret > 0, let last = followed.typedBeforeCaret.last,
              Self.isWholeCharacter(last) else {
            forgetFollowedCaret()
            return
        }
        record(cursor: caret, location: caret - 1, deleted: 1, inserted: [])
    }

    /// The word ended: the next one starts with no prediction; the followed caret stays.
    mutating func endWord() {
        predictedCaret = nil
    }

    /// The app told where the caret is (a D20 read): follow from there. A location outside
    /// `ClientRange.limit` is forgotten (D18).
    mutating func anchor(at location: Int) {
        guard followed.caret != location else { return }
        forgetFollowedCaret()
        guard ClientRange.isUsable(position: location) else { return }
        followed.caret = location
        // No edit came after the app told this position: it counts as an answer on time,
        // otherwise an app late from the start of a document stays capped at
        // `LatenessBudget.humanPaceEdits` (`docs/research/LateAnswerFixes.md` 3.3).
        lateness.startOnTime(missing: 0)
    }

    /// The app answered at the followed caret: it has every edit except those such an
    /// answer cannot show (`FollowedText.editsAnAnswerAtCaretMayLack`).
    mutating func answeredOnTime() {
        lateness.startOnTime(missing: followed.editsAnAnswerAtCaretMayLack)
    }

    /// Forget every position: engine reset, focus or client changed.
    mutating func invalidate() {
        predictedCaret = nil
        forgetFollowedCaret()
    }

    private mutating func forgetFollowedCaret() {
        followed.forget()
        lateness.forget()
    }

    private mutating func record(cursor: Int, location: Int, deleted: Int, inserted: [UInt16],
                                 atCaret: Bool = false) {
        // Not where this composer thought: follow from the app's answer.
        if followed.caret != cursor { forgetFollowedCaret() }
        lateness.countEdit()
        followed.append(cursor: cursor, location: location, deleted: deleted, inserted: inserted, atCaret: atCaret)
        let next = cursor.addingSaturated(inserted.count).subtractingSaturated(deleted)
        if ClientRange.isUsable(position: next) { followed.caret = next } else { forgetFollowedCaret() }
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
}

// MARK: - State

extension CursorTracker {
    /// One edit of the document made by this composer or by a key it let through (⌫).
    struct Edit: Equatable {
        /// The caret before the edit.
        var cursor: Int
        /// Start of the range replaced; the range ends at or before `cursor`.
        var location: Int
        var deleted: Int
        /// The units removed, when this composer typed them (`FollowedText.typedBeforeCaret`).
        var deletedText: [UInt16]?
        var inserted: [UInt16]
        /// Inserted at the app's caret without a range (`insertText` with NSNotFound).
        /// Chromium writes such text into the cache it answers from at once (`rebuild`).
        var atCaret = false

        var caretAfter: Int {
            cursor.addingSaturated(inserted.count).subtractingSaturated(deleted)
        }
    }

    /// The caret followed across words, with the edits and the text that led to it.
    struct FollowedText: Equatable {
        /// Where the caret is once the app has applied every edit; nil when unknown (after a
        /// reset, Return, arrows, a click). Unlike `predictedCaret`, a different answer is
        /// not a mismatch by itself: the app may have edited the text at a word boundary.
        fileprivate(set) var caret: Int?
        /// The text right before `caret` that this composer typed or inserted, oldest first;
        /// may be shorter than the text there.
        fileprivate(set) var typedBeforeCaret: [UInt16] = []
        /// The latest edits, oldest first.
        fileprivate(set) var edits: [Edit] = []
        /// Edits recorded so far, wrapping: tells the caller whether a key recorded one.
        /// Forgetting the caret keeps it counting.
        fileprivate(set) var editsRecorded = 0

        /// Enough for an app far behind a burst of keys; `rebuild` replays only the counts
        /// whose caret matches the answer.
        static let editLimit = 256
        /// Long enough to compare, past `editLimit` units of edits, the app's text before
        /// them (`rebuild`).
        static let typedLimit = 512

        /// The latest edit deleted text this composer typed, at `caret`, with nothing after
        /// it: the UTF-16 units it deleted, or nil (N3 "Ngoại lệ sau ⌫ chưa áp").
        var unitsDeletedAtCaret: Int? {
            guard let caret, let last = edits.last, last.inserted.isEmpty, last.deleted > 0,
                  last.deletedText?.count == last.deleted, last.location == caret,
                  last.cursor == caret.addingSaturated(last.deleted) else { return nil }
            return last.deleted
        }

        /// How many of the latest edits an answer at `caret` cannot show were applied: those
        /// that left the caret where it was (a mark on a letter), and before them at most one
        /// text inserted at the caret, which Chromium's cache counts at once
        /// (`docs/research/LateAnswerFixes.md` 3.3).
        var editsAnAnswerAtCaretMayLack: Int {
            guard var answer = caret else { return 0 }
            var missing = 0, sawCacheInsertion = false
            for edit in edits.reversed() {
                guard edit.caretAfter == answer else { break }
                if edit.cursor == answer {
                    missing += 1
                } else if !sawCacheInsertion, edit.atCaret, !edit.inserted.isEmpty, edit.deleted == 0 {
                    sawCacheInsertion = true
                    answer = edit.cursor
                    missing += 1
                } else {
                    break
                }
            }
            return missing
        }

        fileprivate mutating func forget() {
            caret = nil
            typedBeforeCaret = []
            edits = []
        }

        fileprivate mutating func append(cursor: Int, location: Int, deleted: Int, inserted: [UInt16],
                                         atCaret: Bool) {
            let back = cursor - location      // units from the start of the range to the cursor
            var deletedText: [UInt16]?
            if back >= 0, deleted >= 0, deleted <= back, back <= typedBeforeCaret.count {
                let start = typedBeforeCaret.count - back
                deletedText = Array(typedBeforeCaret[start..<(start + deleted)])
                typedBeforeCaret.replaceSubrange(start..<(start + deleted), with: inserted)
            } else {
                typedBeforeCaret = back == deleted ? inserted : []
            }
            if typedBeforeCaret.count > Self.typedLimit {
                typedBeforeCaret.removeFirst(typedBeforeCaret.count - Self.typedLimit)
            }
            editsRecorded &+= 1
            edits.append(Edit(cursor: cursor, location: location, deleted: deleted,
                              deletedText: deletedText, inserted: inserted, atCaret: atCaret))
            if edits.count > Self.editLimit { edits.removeFirst(edits.count - Self.editLimit) }
        }
    }

    /// How many of the latest edits an app may lack from an answer `rebuild` still takes
    /// as late.
    struct LatenessBudget: Equatable {
        /// At a human pace a busy page answered at most one key behind (measurement under
        /// the name `lateLimit` in `docs/history/LogM6.md`). More would also take for late an app whose
        /// text was replaced by the same letters at the same place (⌘A the input method never
        /// sees, then the word typed again), which D11 must re-read instead.
        static let humanPaceEdits = 2

        /// The key being handled came less than `InPlaceComposer.settleInterval` after the
        /// previous one.
        var keyInBurst = false
        /// How many of the latest edits came from keys in a burst: no person can click or
        /// press ⌘A between them, so a late answer may lack all of them
        /// (`docs/Compatibility.md` 6.2).
        fileprivate(set) var editsInBurst = 0
        /// Edits since the app last answered on time or the caret was anchored at its answer;
        /// nil when neither happened since the caret was last followed. The app had every edit
        /// up to then, so a late answer lacks at most these (`docs/research/LateAnswerFixes.md`
        /// 3.3).
        fileprivate(set) var editsSinceOnTimeAnswer: Int?

        /// How many edits `rebuild` may replay. Back to the last answer on time only inside a
        /// word: after a word end, text that looks late may be text the app changed into one
        /// this composer had before ("car" autocorrected to "cả", then ⌫ r).
        func replayLimit(inWord: Bool) -> Int {
            let paced = Self.humanPaceEdits + editsInBurst
            return inWord ? max(paced, editsSinceOnTimeAnswer ?? 0) : paced
        }

        fileprivate mutating func countEdit() {
            editsInBurst = keyInBurst ? min(editsInBurst + 1, FollowedText.editLimit) : 0
            if let since = editsSinceOnTimeAnswer {
                editsSinceOnTimeAnswer = min(since + 1, FollowedText.editLimit)
            }
        }

        fileprivate mutating func startOnTime(missing: Int) {
            editsSinceOnTimeAnswer = missing
        }

        fileprivate mutating func forget() {
            editsInBurst = 0
            editsSinceOnTimeAnswer = nil
        }
    }
}
