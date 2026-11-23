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
        // At a D20 read, counts past the limits are checked too, never to prove: an answer
        // that fits one may be a state from before those edits (`LateProof.fitsPastLimits`,
        // `wordFromWordStart`), and the Debug log tells how far behind it is.
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

    /// What `wordFromWordStart` found: the word and how many edits the app lacked.
    struct WordStartAnswer: Equatable {
        /// The word this composer typed last, as the app shows it from position 0. The
        /// followed caret is at `word.count` in the app's coordinates.
        var word: [UInt16]
        /// The latest edits the answer lacks (0: on time).
        var lacking: Int
        var form: LateProof.Form?
    }

    /// The word before the caret when `snapshot`, read before `selection` at a D20 read whose
    /// `proof` failed, comes from an app that counts positions from the start of the word
    /// being typed (`docs/Architecture.md`, "App trả lời chậm"); nil if it does not.
    ///
    /// The text read is the whole of what the app holds before its answer (the read reaches
    /// position 0). It may lack the latest edits, within the limits of `prove` and in the same
    /// two forms, every edit it lacks removing text this composer knows. That text plus those
    /// edits is one word, the end of `typedBeforeCaret`, and what this composer typed right
    /// before it is not part of a word. The app shows the whole word: the edits it lacks
    /// only change what follows it ("Hoc " lacking the ⌫ that deleted the space), so the word
    /// is the app's text, never this composer's alone.
    ///
    /// An answer that fits a state of the text from before some edits, past the limits too,
    /// may be a late one and is not taken (`LateProof.fitsPastLimits`): an app that counts
    /// from the start of the document gives such an answer only when the whole document
    /// before its caret is that word.
    func wordFromWordStart(_ snapshot: [UInt16], at selection: NSRange, proof: LateProof) -> WordStartAnswer? {
        let selection = ClientRange.sanitized(selection)
        let end = selection.location
        guard let caret = followed.caret, selection.length == 0, end != NSNotFound, end > 0, end < caret,
              proof.text == nil, !proof.fitsPastLimits, snapshot.count == end else { return nil }
        let edits = followed.edits
        let limitBefore = min(lateness.replayLimit(inWord: false), edits.count)
        let limitCache = min(lateness.cacheReplayLimit, edits.count)
        let typed = followed.typedBeforeCaret
        // The word the app shows (`before`, ending at the followed `cursor`) with the last `m`
        // edits applied.
        func word(_ before: [UInt16], endingAt cursor: Int, last m: Int) -> [UInt16]? {
            guard case .text(let text) = replay(before, endingAt: cursor, last: m, requireDeletedText: true),
                  cursor - before.count + text.count == caret, !text.isEmpty, text.count <= before.count,
                  before.prefix(text.count).elementsEqual(text), text.allSatisfy(Self.isWordUnit),
                  typed.count > text.count, !Self.isWordUnit(typed[typed.count - text.count - 1]),
                  typed.suffix(text.count).elementsEqual(text) else { return nil }
            return text
        }
        if let text = word(snapshot, endingAt: caret, last: 0) {
            return WordStartAnswer(word: text, lacking: 0, form: nil)
        }
        var latestAtCaret: [UInt16]?
        for m in stride(from: 1, through: max(limitBefore, limitCache), by: 1) {
            let first = edits[edits.count - m]
            if latestAtCaret == nil, first.atCaret, !first.inserted.isEmpty { latestAtCaret = first.inserted }
            if m <= limitBefore, let text = word(snapshot, endingAt: first.cursor, last: m) {
                return WordStartAnswer(word: text, lacking: m, form: .before)
            }
            if m <= limitCache, let units = latestAtCaret, snapshot.count >= units.count,
               snapshot.suffix(units.count).elementsEqual(units),
               let text = word(Array(snapshot.dropLast(units.count)), endingAt: first.cursor, last: m) {
                return WordStartAnswer(word: text, lacking: m, form: .cache)
            }
        }
        return nil
    }

    /// A unit of a word as `InPlaceComposer.trailingWord` takes it: a letter, a combining
    /// mark or a digit.
    private static func isWordUnit(_ unit: UInt16) -> Bool {
        guard let scalar = Unicode.Scalar(unit) else { return false }
        return CharacterSet.alphanumerics.contains(scalar)
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
