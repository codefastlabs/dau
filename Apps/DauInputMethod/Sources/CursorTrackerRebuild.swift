import Foundation

/// The proof that an app answers late (D11 "App trả lời chậm"). The rules below and why each
/// holds are in `docs/Architecture.md`, "App trả lời chậm"; the comments here name them.
extension CursorTracker {
    /// The text before `followed.caret`, if `snapshot` (the app's text ending at `selection`)
    /// is that text from before some of the latest edits and `accept` takes it; nil when the
    /// answer is not proved late. `prove` with the same arguments tells why.
    func rebuild(_ snapshot: [UInt16], at selection: NSRange, inWord: Bool = false,
                 requireDeletedText: Bool = false, accept: ([UInt16]) -> Bool) -> [UInt16]? {
        prove(snapshot, at: selection, inWord: inWord, requireDeletedText: requireDeletedText, accept: accept).text
    }

    /// What `rebuild` found: the text, or which check turned the answer down.
    struct LateProof: Equatable {
        /// Which of the app's answers the text read fits (`prove`).
        enum Form: String {
            /// The text as it was before the edits.
            case before = "a"
            /// That text plus the latest of them inserted at the caret (Chromium's cache).
            case cache = "b"
            /// The typed text with a few of its latest units missing (`withMissingUnits`).
            case missingUnits = "m"
        }

        /// The first check that failed for the fewest edits whose caret matches the answer.
        enum Rejection: String {
            /// No followed caret, a selection or an unusable answer, or the answer is the
            /// followed caret where no form may be.
            case answer
            /// No count of edits within the limit proves the answer; `edits`, when set (a D20
            /// read, `cacheForm`), is the fewest past it that would.
            case limit
            /// Replaying the edits does not fit the text read, or ends elsewhere.
            case fit
            /// An edit removed text this composer does not know, where it must.
            case deleted
            /// Past `LatenessBudget.humanPaceEdits`: the text read does not end with what
            /// this composer typed (`typedHere`).
            case typed
            /// Within `humanPaceEdits`: the rebuilt text and the typed text disagree (`agrees`).
            case agrees
            /// The caller turned the rebuilt text down.
            case accept
        }

        var text: [UInt16]?
        /// Edits the answer was taken to lack (proved, or the first candidate turned down).
        var edits: Int?
        var form: Form?
        var rejected: Rejection?
        /// Edits `prove` could replay in form (a).
        var limit = 0
        /// Edits `prove` could replay in form (b).
        var cacheLimit = 0

        /// Some count of edits past the limits proves the answer: it may be a state of the
        /// text from before them (`rejected` is `limit` and `edits` that count).
        var fitsPastLimits: Bool { text == nil && rejected == .limit && edits != nil }
    }

    /// `rebuild`, with the numbers of its decision (Debug diagnostics, D8: numbers only).
    ///
    /// `inWord`: a replacement inside the word being typed, which may replay back to the
    /// last answer on time (`LatenessBudget.replayLimit`). `cacheForm`: a D20 read, whose
    /// answer in Chromium's cache form may also lack edits back to the last answer on time
    /// and may be at the followed caret (`LatenessBudget.cacheReplayLimit`).
    /// `requireDeletedText`: an edit whose removed text this composer does not know fails.
    func prove(_ snapshot: [UInt16], at selection: NSRange, inWord: Bool = false, cacheForm: Bool = false,
               requireDeletedText: Bool = false, accept: ([UInt16]) -> Bool) -> LateProof {
        if coordinates == .heldText {
            return proveHeld(snapshot, at: selection, inWord: inWord, cacheForm: cacheForm, accept: accept)
        }
        var proof = LateProof()
        let selection = ClientRange.sanitized(selection)  // D18: an unusable answer proves nothing
        let end = selection.location
        guard let caret = followed.caret, selection.length == 0, end != NSNotFound,
              end != caret || cacheForm else {
            proof.rejected = .answer
            return proof
        }
        let edits = followed.edits
        let humanPace = LatenessBudget.humanPaceEdits
        let limitBefore = min(lateness.replayLimit(inWord: inWord), edits.count)
        let limitCache = cacheForm ? min(lateness.cacheReplayLimit, edits.count) : limitBefore
        (proof.limit, proof.cacheLimit) = (limitBefore, limitCache)
        let limit = max(limitBefore, limitCache)
        func turnDown(_ m: Int, _ form: LateProof.Form, _ why: LateProof.Rejection) {
            guard proof.rejected == nil else { return }
            (proof.edits, proof.form, proof.rejected) = (m, form, why)
        }
        // The checks of the answer lacking the last `m` edits, read in `form`; nil: proved.
        func check(_ m: Int, _ form: LateProof.Form, _ before: [UInt16], _ first: Edit)
            -> (text: [UInt16]?, rejected: LateProof.Rejection?) {
            let replayed = replay(before, endingAt: first.cursor, last: m,
                                  requireDeletedText: requireDeletedText || m > humanPace)
            guard case .text(let text) = replayed else { return (nil, replayed == .unknownDeletion ? .deleted : .fit) }
            guard first.cursor - before.count + text.count == caret else { return (nil, .fit) }
            if m > humanPace, !typedHere(text, before: before.count, fromStart: first.cursor == before.count) {
                return (nil, .typed)
            }
            if m <= humanPace, !agrees(text) { return (nil, .agrees) }
            return accept(text) ? (text, nil) : (nil, .accept)
        }
        // At a D20 read, counts past the limits are checked too, never to prove: the Debug
        // log tells how far behind such an answer is (`LateProof.fitsPastLimits`).
        let scanned = cacheForm ? edits.count : limit
        var latestAtCaret: [UInt16]?
        var provedPastLimit: (m: Int, form: LateProof.Form)?
        for m in stride(from: 1, through: scanned, by: 1) {
            if provedPastLimit != nil, m > limit { break }
            let first = edits[edits.count - m]
            if latestAtCaret == nil, first.atCaret, !first.inserted.isEmpty { latestAtCaret = first.inserted }
            var forms: [(LateProof.Form, [UInt16])] = []
            // Form (a): the text as it was before the last `m` edits. Never at the followed
            // caret: an answer there is the app's own text, which D20 reads as it is.
            if first.cursor == end, end != caret { forms.append((.before, snapshot)) }
            // Form (b): that text plus the latest of them inserted at the caret, which
            // Chromium writes into its cache at once.
            if let units = latestAtCaret, first.cursor + units.count == end, snapshot.count >= units.count,
               snapshot.suffix(units.count).elementsEqual(units) {
                forms.append((.cache, Array(snapshot.dropLast(units.count))))
            }
            for (form, before) in forms {
                let withinLimit = m <= (form == .cache ? limitCache : limitBefore)
                guard withinLimit || cacheForm else { continue }
                let result = check(m, form, before, first)
                if !withinLimit {
                    if result.text != nil, provedPastLimit == nil { provedPastLimit = (m, form) }
                } else if let text = result.text {
                    var proved = proof
                    (proved.text, proved.edits, proved.form, proved.rejected) = (text, m, form, nil)
                    return proved
                } else if let why = result.rejected {
                    turnDown(m, form, why)
                }
            }
        }
        // Chrome's cache may answer between its own updates, matching neither form: the text
        // read is then the text this composer typed with a few of its latest units missing.
        let missing = caret - end
        if missing >= 1, missing <= humanPace, let text = withMissingUnits(snapshot, missing: missing) {
            if accept(text) {
                (proof.text, proof.edits, proof.form, proof.rejected) = (text, nil, .missingUnits, nil)
                return proof
            }
            if proof.rejected == nil { proof.form = .missingUnits; proof.rejected = .accept }
        }
        if let past = provedPastLimit {
            (proof.edits, proof.form, proof.rejected) = (past.m, past.form, .limit)
        }
        if proof.rejected == nil { proof.rejected = end == caret ? .answer : .limit }
        return proof
    }

    // MARK: Held text (D11 "Ô chỉ giữ từ trước con trỏ")

    /// Which state of the held text an answer shows.
    struct HeldMatch: Equatable {
        /// The latest edits the answer lacks (0: on time).
        var lacking: Int
        /// `.before`: that state as it was; `.cache`: plus the latest text this composer
        /// inserted at the caret after it (Chromium's cache, `prove`).
        var form: LateProof.Form
    }

    /// The state of the held text after one of the latest edits that `snapshot`, read
    /// before `end`, shows; the fewest edits back first. Every edit after it that deleted
    /// text must know that text. `limit`, `cacheLimit`: edits back each form may go.
    /// `fromNow`: the state after the latest edit counts (an answer on time). `whole`: the
    /// state must be a word of at least two units this composer knows in full, read from
    /// position 0, as a switch to held text needs (`heldTextShown`).
    func heldTextMatch(_ snapshot: [UInt16], at end: Int, limit: Int, cacheLimit: Int,
                       fromNow: Bool, whole: Bool) -> HeldMatch? {
        let edits = followed.edits
        guard !edits.isEmpty, end >= 0, snapshot.count <= end else { return nil }
        if whole, snapshot.count != end { return nil }
        var latestAtCaret: [UInt16]?
        var deletionsKnown = true
        for m in 0..<edits.count {
            let index = edits.count - 1 - m
            if m > 0 {
                // The edit right after this state is now among those the answer lacks.
                let after = edits[index + 1]
                if latestAtCaret == nil, after.atCaret, !after.inserted.isEmpty { latestAtCaret = after.inserted }
                if after.deleted > 0, after.deletedText?.count != after.deleted { deletionsKnown = false }
            }
            guard deletionsKnown, m <= max(limit, cacheLimit) else { break }
            guard let state = edits[index].heldAfter else { continue }
            if whole, !(state.isWhole && state.length >= 2 && state.known.allSatisfy { HeldText.isWordUnit($0) }) { continue }
            if m <= limit, m > 0 || fromNow, state.length == end, Self.shows(snapshot, state.known, whole: whole) {
                return HeldMatch(lacking: m, form: .before)
            }
            if m > 0, m <= cacheLimit, let units = latestAtCaret, state.length + units.count == end,
               Self.shows(snapshot, state.known + units, whole: whole) {
                return HeldMatch(lacking: m, form: .cache)
            }
        }
        return nil
    }

    /// `snapshot` is the end of a text ending with `known`: the units both have agree, and
    /// any it has before them are units of a word (the part of the held text not known).
    private static func shows(_ snapshot: [UInt16], _ known: [UInt16], whole: Bool) -> Bool {
        if whole { return snapshot == known }
        let n = min(snapshot.count, known.count)
        guard snapshot.suffix(n).elementsEqual(known.suffix(n)) else { return false }
        return snapshot.dropLast(n).allSatisfy { HeldText.isWordUnit($0) }
    }

    /// `prove` once the client holds only the word before the caret: the answer shows a
    /// state of that text after one of the latest edits, within the limits of `prove`, so
    /// the text there now is the held text after every edit.
    private func proveHeld(_ snapshot: [UInt16], at selection: NSRange, inWord: Bool, cacheForm: Bool,
                           accept: ([UInt16]) -> Bool) -> LateProof {
        var proof = LateProof()
        let selection = ClientRange.sanitized(selection)
        let end = selection.location
        guard let caret = followed.caret, let now = followed.held, selection.length == 0, end != NSNotFound,
              end != caret || cacheForm else {
            proof.rejected = .answer
            return proof
        }
        let edits = followed.edits.count
        let limitBefore = min(lateness.replayLimit(inWord: inWord), edits)
        let limitCache = cacheForm ? min(lateness.cacheReplayLimit, edits) : limitBefore
        (proof.limit, proof.cacheLimit) = (limitBefore, limitCache)
        // As in `prove`, form (a) is never at the followed caret: an answer there is the
        // client's own text, which a D20 read takes as it is.
        guard let match = heldTextMatch(snapshot, at: end, limit: end == caret ? 0 : limitBefore,
                                        cacheLimit: limitCache, fromNow: false, whole: false) else {
            proof.rejected = .limit
            return proof
        }
        (proof.edits, proof.form) = (match.lacking, match.form)
        if accept(now.known) { proof.text = now.known } else { proof.rejected = .accept }
        return proof
    }

    /// A client counting from the start of the document still answers with positions
    /// there: `snapshot`, read before `selection`, shows the word before the caret as held
    /// text after one of the latest edits (`heldTextMatch`, whole), and no state of the text
    /// followed from the start of the document, however far back, fits it
    /// (`fitsDocumentState`). nil when not. `cacheForm`: a D20 read, with its limits.
    func heldTextShown(_ snapshot: [UInt16], at selection: NSRange, cacheForm: Bool) -> HeldMatch? {
        let selection = ClientRange.sanitized(selection)
        let end = selection.location
        guard coordinates == .document, let caret = followed.caret, selection.length == 0, end != NSNotFound,
              end != caret else { return nil }
        let edits = followed.edits.count
        let limit = min(lateness.replayLimit(inWord: !cacheForm), edits)
        let cacheLimit = cacheForm ? min(lateness.cacheReplayLimit, edits) : limit
        guard let match = heldTextMatch(snapshot, at: end, limit: limit, cacheLimit: cacheLimit,
                                        fromNow: true, whole: true),
              !fitsDocumentState(snapshot, at: end) else { return nil }
        return match
    }

    /// Some state of the text followed from the start of the document, after any number of
    /// the latest edits, in either form of `prove`, is `snapshot` ending at `end`, and agrees
    /// with what this composer typed: a late answer of a client counting from there may give
    /// it ("Hoc nay. Hoc" in a new document, the page stuck after the first word).
    func fitsDocumentState(_ snapshot: [UInt16], at end: Int) -> Bool {
        guard let caret = followed.caret else { return false }
        let edits = followed.edits
        var latestAtCaret: [UInt16]?
        for m in stride(from: 1, through: edits.count, by: 1) {
            let first = edits[edits.count - m]
            if latestAtCaret == nil, first.atCaret, !first.inserted.isEmpty { latestAtCaret = first.inserted }
            var forms: [[UInt16]] = []
            if first.cursor == end { forms.append(snapshot) }
            if let units = latestAtCaret, first.cursor + units.count == end, snapshot.count >= units.count,
               snapshot.suffix(units.count).elementsEqual(units) {
                forms.append(Array(snapshot.dropLast(units.count)))
            }
            for before in forms {
                if case .text(let text) = replay(before, endingAt: first.cursor, last: m, requireDeletedText: false),
                   first.cursor - before.count + text.count == caret, agrees(text) {
                    return true
                }
            }
        }
        return false
    }

    /// Held text never shows this: `snapshot`, read before `selection`, is longer than any
    /// held text, or has units of words on both sides of a unit that is not, and ends with
    /// what this composer typed from that boundary on. The client counts from the start of
    /// the document again.
    func showsDocument(_ snapshot: [UInt16], at selection: NSRange) -> Bool {
        let end = ClientRange.sanitized(selection).location
        guard end != NSNotFound else { return false }
        // The longest held text, plus one unit Chromium's cache adds to it.
        if end > HeldText.limit + 1 { return true }
        guard let firstWord = snapshot.firstIndex(where: { HeldText.isWordUnit($0) }),
              let boundary = snapshot.lastIndex(where: { !HeldText.isWordUnit($0) }), boundary > firstWord,
              boundary < snapshot.count - 1 else { return false }
        let typed = followed.typedBeforeCaret
        let across = snapshot.count - boundary
        return typed.count >= across && typed.suffix(across).elementsEqual(snapshot.suffix(across))
    }

    private enum Replay: Equatable {
        case text([UInt16])
        /// An edit does not fit where the text read puts it.
        case misfit
        /// An edit removed text this composer does not know (`requireDeletedText`).
        case unknownDeletion
    }

    /// `before` (the app's text, ending at `cursor`) with the last `m` edits applied.
    private func replay(_ before: [UInt16], endingAt cursor: Int, last m: Int, requireDeletedText: Bool) -> Replay {
        let base = cursor - before.count
        var text = before
        for edit in followed.edits.suffix(m) {
            let start = edit.location - base, stop = start + edit.deleted
            guard edit.cursor == base + text.count, start >= 0, stop <= text.count else { return .misfit }
            if let removed = edit.deletedText {
                guard text[start..<stop].elementsEqual(removed) else { return .misfit }
            } else if requireDeletedText && edit.deleted > 0 {
                return .unknownDeletion
            }
            text.replaceSubrange(start..<stop, with: edit.inserted)
        }
        return .text(text)
    }

    /// `text` (ending at the followed caret) and `followed.typedBeforeCaret` are the same over
    /// the units both have.
    private func agrees(_ text: [UInt16]) -> Bool {
        let typed = followed.typedBeforeCaret
        let n = min(text.count, typed.count)
        return text.suffix(n).elementsEqual(typed.suffix(n))
    }

    /// `text` (ending at the followed caret, its first `count` units read from the app) ends
    /// with what this composer typed, which reaches at least two units into the part read
    /// (one when that part starts the document and is all typed here). `fromStart`: the part
    /// read starts the document.
    ///
    /// With nothing read at the start of the document, the answer counts as late only while
    /// the key being handled is in the same burst: there was no time for a click IMK does
    /// not report (D11, "Ở đầu văn bản").
    private func typedHere(_ text: [UInt16], before count: Int, fromStart: Bool) -> Bool {
        let typed = followed.typedBeforeCaret
        let n = min(text.count, typed.count)
        if fromStart, count == 0 {
            return lateness.keyInBurst && typed.count == text.count && text.elementsEqual(typed)
        }
        let reach = n - (text.count - count)
        guard reach >= 2 || (fromStart && count >= 1 && reach == count) else { return false }
        return text.suffix(n).elementsEqual(typed.suffix(n))
    }

    /// `snapshot` (ending `d` units before the followed caret) is the typed text with `d` of
    /// its last `d + humanPaceEdits` units left out, compared over at least two units: then
    /// the text before the caret is the start of `snapshot` followed by the typed text. nil
    /// if not.
    ///
    /// A missing unit comes after one that was compared: Chromium's cache lacks what the
    /// page has not reported yet, after the text it has. The typed text without its first
    /// units is an app that holds only the word being typed, not a late one.
    private func withMissingUnits(_ snapshot: [UInt16], missing d: Int) -> [UInt16]? {
        let typed = followed.typedBeforeCaret
        let n = min(snapshot.count, typed.count - d)
        guard n >= 2 else { return nil }
        let seen = Array(snapshot.suffix(n))
        let window = min(typed.count, d + LatenessBudget.humanPaceEdits)
        func fits(_ left: [UInt16], dropping: Int, from start: Int) -> Bool {
            if dropping == 0 { return Array(left.suffix(n)) == seen }
            for i in stride(from: start, to: left.count, by: 1) {
                var shorter = left
                shorter.remove(at: i)
                if fits(shorter, dropping: dropping - 1, from: i) { return true }
            }
            return false
        }
        guard fits(typed, dropping: d, from: max(typed.count - window, typed.count - (n + d) + 1)) else { return nil }
        return Array(snapshot.dropLast(n)) + Array(typed.suffix(n + d))
    }
}
