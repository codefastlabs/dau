import Foundation
@testable import DauInputMethodCore
import Testing

@Suite("CursorTracker (method A + D11 drift check)")
struct CursorTrackerTests {
    private let notFound = NSRange(location: NSNotFound, length: NSNotFound)

    private func at(_ location: Int, _ length: Int = 0) -> NSRange {
        NSRange(location: location, length: length)
    }

    @Test("first replacement of a word trusts selectedRange")
    func firstReplacement() {
        let t = CursorTracker()
        #expect(t.plan(selection: at(10), deleteCount: 1) == .replace(at(9, 1)))
        #expect(t.plan(selection: at(3), deleteCount: 3) == .replace(at(0, 3)))
    }

    @Test("no document access: NSNotFound is reported as unsupported")
    func unsupported() {
        let t = CursorTracker()
        #expect(t.plan(selection: notFound, deleteCount: 1) == .unsupported)
        #expect(t.plan(selection: NSRange(location: NSNotFound, length: 0), deleteCount: 1) == .unsupported)
    }

    @Test("too little text or a negative count is a mismatch; a negative answer is no document access (D18)")
    func invalid() {
        let t = CursorTracker()
        #expect(t.plan(selection: at(1), deleteCount: 2) == .mismatch)
        #expect(t.plan(selection: at(1, 5), deleteCount: 2) == .mismatch)
        #expect(t.plan(selection: at(-1), deleteCount: 1) == .unsupported)
        #expect(t.plan(selection: at(5), deleteCount: -1) == .mismatch)
    }

    @Test("tooi: t o typed at the caret, o replaces, i typed at the caret; the next replacement must match")
    func followsTheWord() {
        // Document "x " then the word starts at 2.
        var t = CursorTracker()
        t.typedAtCaret("t") // nothing known yet
        t.typedAtCaret("o")
        #expect(t.predictedCaret == nil)
        guard case .replace(let r) = t.plan(selection: at(4), deleteCount: 1) else {
            Issue.record("expected a replacement"); return
        }
        t.didReplace(r, text: "ô")
        #expect(t.predictedCaret == 4)
        t.typedAtCaret("i")
        #expect(t.predictedCaret == 5)
        #expect(t.plan(selection: at(5), deleteCount: 2) == .replace(at(3, 2)))
    }

    @Test("inline autocomplete — 'go' + selected 'ogle.com', x replaces word and suggestion (D11)")
    func inlineAutocomplete() {
        // First replacement of the word: nothing expected yet, the suggestion is selected.
        var t = CursorTracker()
        #expect(t.plan(selection: at(2, 8), deleteCount: 2) == .replace(at(0, 10)))
        // Later in the word the suggestion must start where the word ended.
        t.didReplace(at(0, 10), text: "gõ")
        #expect(t.plan(selection: at(2, 6), deleteCount: 2) == .replace(at(0, 8)))
        #expect(t.plan(selection: at(5, 6), deleteCount: 2) == .mismatch)
    }

    @Test("the cursor moved without a reported click → mismatch (D11)")
    func drift() {
        var t = CursorTracker()
        t.didReplace(at(9, 1), text: "x")
        #expect(t.plan(selection: at(42), deleteCount: 1) == .mismatch)
        #expect(t.plan(selection: at(10), deleteCount: 1) == .replace(at(9, 1)))
    }

    @Test("pass-through Delete moves the expectation back by one")
    func backspace() {
        var t = CursorTracker()
        t.didReplace(at(9, 1), text: "xy")
        t.backspacePassedThrough()
        #expect(t.predictedCaret == 10)
        var z = CursorTracker()
        z.didReplace(at(0, 0), text: "")
        z.backspacePassedThrough()
        #expect(z.predictedCaret == nil)
    }

    @Test("insertion at the cursor and invalidation")
    func insertAndInvalidate() {
        var t = CursorTracker()
        t.didInsertAtCursor("x")
        #expect(t.predictedCaret == nil)
        t.didReplace(at(4, 1), text: "x")
        t.didInsertAtCursor("yz")
        #expect(t.predictedCaret == 7)
        t.invalidate()
        #expect(t.predictedCaret == nil)
        #expect(t.plan(selection: at(100), deleteCount: 1) == .replace(at(99, 1)))
    }

    // MARK: Following the cursor across words (an app that answers late)

    @Test("the position is followed across a word end; the expected one is not")
    func knownAcrossWords() {
        var t = CursorTracker()
        t.anchor(at: 0)
        t.typedAtCaret("b"); t.typedAtCaret("a")
        t.didReplace(at(1, 1), text: "á")
        t.typedAtCaret(" ")
        t.endWord()
        #expect(t.predictedCaret == nil)
        #expect(t.followed.caret == 3)
        #expect(t.followed.typedBeforeCaret == Array("bá ".utf16))
        t.typedAtCaret("n")
        #expect(t.followed.caret == 4)
        #expect(t.followed.edits.last == CursorTracker.Edit(cursor: 3, location: 3, deleted: 0, deletedText: [], inserted: Array("n".utf16),
                                                   atCaret: true, heldAfter: HeldText(length: 1, known: Array("n".utf16))))
    }

    @Test("an answer one edit late: the text read plus that edit, checked by the caller")
    func rebuildOneLate() {
        var t = CursorTracker()
        t.anchor(at: 4)
        for c in ["b", "a", "n"] { t.typedAtCaret(c) }
        // The app answers 6 with "xx, ba" while "ban" is typed (followed caret 7).
        let snapshot = Array("xx, ba".utf16)
        #expect(t.rebuild(snapshot, at: at(6), accept: { _ in true }) == Array("xx, ban".utf16))
        // The caller refuses it (not the engine's word): nothing.
        #expect(t.rebuild(snapshot, at: at(6), accept: { _ in false }) == nil)
        // On time, a selection, or more than `LatenessBudget.humanPaceEdits` edits behind: nothing.
        #expect(t.rebuild(Array("xx, ban".utf16), at: at(7), accept: { _ in true }) == nil)
        #expect(t.rebuild(snapshot, at: at(6, 1), accept: { _ in true }) == nil)
        #expect(t.rebuild(Array("xx, ".utf16), at: at(4), accept: { _ in true }) == nil)
    }

    @Test("a late answer must contain the text the edits removed")
    func rebuildChecksRemovedText() {
        var t = CursorTracker()
        t.anchor(at: 0)
        for c in ["H", "o", "c", " "] { t.typedAtCaret(c) }
        t.backspaceOutsideWord()
        #expect(t.followed.caret == 3)
        // Answer from before the ⌫: "Hoc " at 4.
        #expect(t.rebuild(Array("Hoc ".utf16), at: at(4), requireDeletedText: true, accept: { _ in true }) == Array("Hoc".utf16))
        // Something else before the cursor at 4: not a late answer.
        #expect(t.rebuild(Array("Hocx".utf16), at: at(4), requireDeletedText: true, accept: { _ in true }) == nil)
    }

    @Test("⌫ with no word: known only after a character this composer typed")
    func backspaceOutsideWord() {
        var t = CursorTracker()
        t.anchor(at: 5)
        t.backspaceOutsideWord()          // nothing typed here: unknown
        #expect(t.followed.caret == nil)
        t.anchor(at: 5)
        t.typedAtCaret(" ")
        t.backspaceOutsideWord()
        #expect(t.followed.caret == 5)
        #expect(t.followed.edits.last?.deletedText == Array(" ".utf16))
        // A combining mark could join the character before it: unknown.
        t.typedAtCaret("\u{0301}")
        t.backspaceOutsideWord()
        #expect(t.followed.caret == nil)
    }

    @Test("an answer elsewhere starts following again from it")
    func reanchor() {
        var t = CursorTracker()
        t.anchor(at: 10)
        t.typedAtCaret("a")
        t.didReplace(at(20, 1), text: "á")
        #expect(t.followed.caret == 21)
        #expect(t.followed.edits.count == 1)
        #expect(t.followed.typedBeforeCaret == Array("á".utf16))
        t.invalidate()
        #expect(t.followed.caret == nil && t.followed.edits.isEmpty && t.followed.typedBeforeCaret.isEmpty)
    }
}
