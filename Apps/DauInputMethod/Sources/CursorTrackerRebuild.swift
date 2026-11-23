import Foundation

/// The proof that an app answers late (D11 "App trả lời chậm"). The rules below and why each
/// holds are in `docs/Architecture.md`, "App trả lời chậm"; the comments here name them.
extension CursorTracker {
    /// The text before `followed.caret`, if `snapshot` (the app's text ending at `selection`)
    /// is that text from before some of the latest edits and `accept` takes it; nil when the
    /// answer is not proved late.
    ///
    /// `inWord`: a replacement inside the word being typed, which may replay back to the
    /// last answer on time (`LatenessBudget.replayLimit`). `requireDeletedText`: an edit
    /// whose removed text this composer does not know fails.
    func rebuild(_ snapshot: [UInt16], at selection: NSRange, inWord: Bool = false,
                 requireDeletedText: Bool = false, accept: ([UInt16]) -> Bool) -> [UInt16]? {
        let selection = ClientRange.sanitized(selection)  // D18: an unusable answer proves nothing
        let end = selection.location
        guard let caret = followed.caret, selection.length == 0, end != NSNotFound, end != caret else { return nil }
        let edits = followed.edits
        let humanPace = LatenessBudget.humanPaceEdits
        let count = min(lateness.replayLimit(inWord: inWord), edits.count)
        var latestAtCaret: [UInt16]?
        for m in stride(from: 1, through: count, by: 1) {
            let first = edits[edits.count - m]
            if latestAtCaret == nil, first.atCaret, !first.inserted.isEmpty { latestAtCaret = first.inserted }
            var forms: [[UInt16]] = []
            // Form (a): the text as it was before the last `m` edits.
            if first.cursor == end { forms.append(snapshot) }
            // Form (b): that text plus the latest of them inserted at the caret, which
            // Chromium writes into its cache at once.
            if let units = latestAtCaret, first.cursor + units.count == end, snapshot.count >= units.count,
               snapshot.suffix(units.count).elementsEqual(units) {
                forms.append(Array(snapshot.dropLast(units.count)))
            }
            for before in forms {
                guard let text = replay(before, endingAt: first.cursor, last: m,
                                        requireDeletedText: requireDeletedText || m > humanPace),
                      first.cursor - before.count + text.count == caret else { continue }
                if m > humanPace,
                   !typedHere(text, before: before.count, fromStart: first.cursor == before.count) { continue }
                if m <= humanPace, !agrees(text) { continue }
                if accept(text) { return text }
            }
        }
        // Chrome's cache may answer between its own updates, matching neither form: the text
        // read is then the text this composer typed with a few of its latest units missing.
        let missing = caret - end
        if missing >= 1, missing <= humanPace, let text = withMissingUnits(snapshot, missing: missing), accept(text) {
            return text
        }
        return nil
    }

    /// `before` (the app's text, ending at `cursor`) with the last `m` edits applied, or nil
    /// if one of them does not fit there.
    private func replay(_ before: [UInt16], endingAt cursor: Int, last m: Int, requireDeletedText: Bool) -> [UInt16]? {
        let base = cursor - before.count
        var text = before
        for edit in followed.edits.suffix(m) {
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
