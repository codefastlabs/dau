import Foundation
import DauEngine
import DauShared
import Testing

private func units(_ s: String) -> [UInt16] { Array(s.utf16) }
private func at(_ location: Int) -> NSRange { NSRange(location: location, length: 0) }

/// A tracker that follows held text from the start of a line, after `typed` typed there.
private func heldTracker(_ typed: String, inBurst: Bool = true) -> CursorTracker {
    var t = CursorTracker()
    t.useHeldText()
    t.anchor(at: 0)
    t.lateness.keyInBurst = inBurst
    for c in typed { t.typedAtCaret(String(c)) }
    return t
}

@Suite("Held text: the word before the caret, from the text the input method knows")
struct HeldTextTests {
    @Test("the held text and its length, by Monaco's default word separators")
    func heldText() {
        func length(_ known: String, _ head: HeldText.Head = .boundary) -> Int? {
            HeldText.held(after: units(known), head: head)?.length
        }
        #expect(length("nay. Hoc") == 3)
        #expect(HeldText.held(after: units("nay. Hoc"), head: .unknown)?.known == units("Hoc"))
        // No word before the caret: the one character there.
        #expect(length("nay. Hoc ") == 1)
        #expect(HeldText.held(after: units("Hoc "), head: .unknown)?.known == units(" "))
        #expect(length("x.y") == 1)
        #expect(length("a\t") == 1)
        // Typographic quotes, `_`, digits and marks are units of a word.
        #expect(length(" \u{201C}Hoc") == 4)
        #expect(length(" foo_hoc") == 7)
        #expect(length(" a\u{0301}2") == 3)
        // At most `HeldText.limit`.
        #expect(length(" " + String(repeating: "a", count: 60)) == HeldText.limit)
        #expect(length(String(repeating: "a", count: 60), .unknown) == HeldText.limit)
        // What precedes the known text decides when every known unit is of a word.
        #expect(length("", .lineStart) == 0)
        #expect(length("", .boundary) == nil)
        #expect(length("Hoc", .unknown) == nil)
        #expect(length("Hoc", .wordUnits(4)) == 7)
        #expect(HeldText.held(after: units("Hoc"), head: .wordUnits(4))?.isWhole == false)
    }

    @Test("what a read at an anchored caret tells about the held text")
    func anchoredRead() {
        #expect(HeldText.anchored(read: [], at: 0)?.head == .lineStart)
        #expect(HeldText.anchored(read: units("Hoc"), at: 3)?.head == .boundary)
        #expect(HeldText.anchored(read: units(" "), at: 1)?.head == .unknown)
        // 16 units read before 20: four more units of the word before them.
        #expect(HeldText.anchored(read: units(String(repeating: "a", count: 16)), at: 20)?.head == .wordUnits(4))
        #expect(HeldText.anchored(read: units("a b"), at: 3) == nil)
    }

    @Test("the followed caret after each edit, in held text")
    func caretAfterEdits() {
        var t = heldTracker("chiều nay. Hoc")
        #expect(t.followed.caret == 3)
        t.typedAtCaret(" ")
        #expect(t.followed.caret == 1)
        // ⌫ over the space this composer typed: the word before it again.
        t.backspaceOutsideWord()
        #expect(t.followed.caret == 3)
        // A D4 restore ending with ",": no word before the caret.
        t.didReplace(NSRange(location: 0, length: 3), text: "Hocj,")
        #expect(t.followed.caret == 1)
        // One ending with "…", a unit of a word for Monaco: the run goes on.
        var u = heldTracker(" ab")
        u.didReplace(NSRange(location: 0, length: 2), text: "ab\u{2026}")
        #expect(u.followed.caret == 3)
        // ⌫ over text this composer does not know: unknown.
        var v = CursorTracker()
        v.useHeldText()
        v.anchor(at: 5)
        v.backspaceOutsideWord()
        #expect(v.followed.caret == nil)
    }

    @Test("the range of each replacing operation ends at the held caret")
    func ranges() {
        // A mark in "tie" (+ e): one unit at the end.
        let t = heldTracker(" tie")
        #expect(t.plan(selection: at(3), deleteCount: 1) == .replace(NSRange(location: 2, length: 1)))
        // A word longer than the held text: the range is in its last `HeldText.limit` units.
        let long = heldTracker(" " + String(repeating: "a", count: 55))
        #expect(long.followed.caret == HeldText.limit)
        #expect(long.plan(selection: at(HeldText.limit), deleteCount: 2)
                == .replace(NSRange(location: HeldText.limit - 2, length: 2)))
    }

    @Test("an answer in held text: on time, a state after one of the latest edits, or none")
    func answers() {
        var t = heldTracker("chiều nay. Hoc ")
        t.backspaceOutsideWord()
        let limit = 4
        func match(_ s: String, _ end: Int, limit: Int = limit) -> CursorTracker.HeldMatch? {
            t.heldTextMatch(units(s), at: end, limit: limit, cacheLimit: limit, fromNow: true, whole: false)
        }
        #expect(match("Hoc", 3) == .init(lacking: 0, form: .before))
        // Chromium's cache: the state after "c" plus the space inserted at the caret.
        #expect(match("Hoc ", 4) == .init(lacking: 2, form: .cache))
        // The state after the space, the ⌫ not applied yet.
        #expect(match(" ", 1) == .init(lacking: 1, form: .before))
        // An earlier state of the word, three edits back.
        #expect(match("Ho", 2) == .init(lacking: 3, form: .before))
        #expect(match("Hx", 2) == nil)
        #expect(match(" ", 1, limit: 0) == nil)
        // A late answer proves the held text after every edit.
        let proof = t.prove(units(" "), at: at(1), cacheForm: true, requireDeletedText: true, accept: { _ in true })
        #expect(proof.text == units("Hoc"))
        #expect(proof.edits == 1)
    }

    @Test("a client counting from the document start is not taken for held text")
    func detection() {
        // The editor of Cursor 3.31.15 at "j" of "chiều nay. Hoc ⌫j": known 14, answer 3 "Hoc".
        var t = CursorTracker()
        t.anchor(at: 0)
        t.lateness.keyInBurst = true
        for c in "chiều nay. Hoc " { t.typedAtCaret(String(c)) }
        t.backspaceOutsideWord()
        #expect(t.followed.caret == 14)
        #expect(t.heldTextShown(units("Hoc"), at: at(3), cacheForm: true) == .init(lacking: 0, form: .before))
        #expect(t.heldTextShown(units("Hoc "), at: at(4), cacheForm: true) == .init(lacking: 2, form: .cache))
        // One unit: Google Docs always answers 1 with the character before the caret.
        #expect(t.heldTextShown(units(" "), at: at(1), cacheForm: true) == nil)
        #expect(t.heldTextShown(units("c"), at: at(1), cacheForm: true) == nil)
        // On time at the followed caret: never checked.
        #expect(t.heldTextShown(units("y. Hoc"), at: at(14), cacheForm: true) == nil)
        // A new document that starts with the word typed last, the page stuck after it: a
        // state of the text followed from the start of the document.
        var d = CursorTracker()
        d.anchor(at: 0)
        d.lateness.keyInBurst = true
        for c in "Hoc nay. Hoc " { d.typedAtCaret(String(c)) }
        d.backspaceOutsideWord()
        #expect(d.fitsDocumentState(units("Hoc"), at: 3))
        #expect(d.heldTextShown(units("Hoc"), at: at(3), cacheForm: true) == nil)
        // Not a state of what was typed there: "Hoc" at 3 is not "chi".
        #expect(!t.fitsDocumentState(units("Hoc"), at: 3))
    }

    /// The answers measured at "j" of "Sasng nay moj" in the editor of Cursor 3.31.15, keys
    /// 5 ms apart: states of one unit, the first answers there to differ from the followed caret.
    @Test("held text shown by a state of one unit: after a space with the letter typed next, or a letter some edits back")
    func detectionFromOneUnitStates() {
        var t = CursorTracker()
        t.anchor(at: 0)
        t.lateness.keyInBurst = true
        t.typedAtCaret("S"); t.typedAtCaret("a")
        t.didReplace(NSRange(location: 1, length: 1), text: "á")
        for c in "ng nay mo" { t.typedAtCaret(String(c)) }
        // The space, then the "o" typed last: Chromium's cache, two edits back.
        #expect(t.heldTextShown(units(" o"), at: at(2), cacheForm: false) == .init(lacking: 2, form: .cache))
        // "m", one edit back.
        #expect(t.heldTextShown(units("m"), at: at(1), cacheForm: false) == .init(lacking: 1, form: .before))
        // One unit that is the text before the caret now, as Google Docs answers: never.
        var o = CursorTracker()
        o.anchor(at: 0)
        o.lateness.keyInBurst = true
        for c in "Sáng o o" { o.typedAtCaret(String(c)) }
        #expect(o.heldTextShown(units("o"), at: at(1), cacheForm: false) == nil)
        // Nor a letter of a word before a space: "o" of "o mo".
        var w = CursorTracker()
        w.anchor(at: 0)
        w.lateness.keyInBurst = true
        for c in "Sáng o mo" { w.typedAtCaret(String(c)) }
        #expect(w.heldTextShown(units("o"), at: at(1), cacheForm: false) == nil)
        // A space alone, a state some edits back: never.
        #expect(t.heldTextShown(units(" "), at: at(1), cacheForm: false) == nil)
    }

    @Test("held text shows no text before the word: back to the document's coordinates")
    func switchBack() {
        let t = heldTracker("chiều nay. Hoc")
        #expect(t.showsDocument(units("ều nay. Hoc"), at: at(219)))
        #expect(t.showsDocument(units("ay. Hoc"), at: at(52 + 1)))
        #expect(t.showsDocument(units("ay. Hoc"), at: at(14)))
        #expect(!t.showsDocument(units("Hoc "), at: at(4)))
        #expect(!t.showsDocument(units(" H"), at: at(2)))
        #expect(!t.showsDocument(units("ab"), at: at(2)))
        var u = t
        u.useDocumentCoordinates()
        #expect(u.coordinates == .document && u.followed.caret == nil)
    }

    @Test("waiting for a ⌫: the caret before it, in held text")
    func backspaceWait() {
        var t = heldTracker("nay. Hoc ")
        t.backspaceOutsideWord()
        #expect(t.followed.caret == 3)
        #expect(t.caretBeforeDeletion == 1)
        var d = CursorTracker()
        d.anchor(at: 10)
        d.typedAtCaret(" ")
        d.backspaceOutsideWord()
        #expect(d.caretBeforeDeletion == 11)
    }
}

/// Records the calls in-place mode makes and answers each at once with what the test
/// sets before the key: the position and the text before it, as logged by the app.
final class ScriptedClient: InPlaceClient {
    var answer = (location: 0, before: "")
    private(set) var selections = 0, reads = 0
    private(set) var inserts: [(text: String, range: NSRange)] = []

    func selectedRange() -> NSRange {
        selections += 1
        return NSRange(location: answer.location, length: 0)
    }

    func text(in range: NSRange) -> String? {
        reads += 1
        let before = units(answer.before)
        guard range.location + range.length == answer.location, range.length <= before.count else { return nil }
        return String(decoding: before.suffix(range.length), as: UTF16.self)
    }

    func insertText(_ text: String, replacementRange: NSRange) { inserts.append((text, replacementRange)) }
    func pause(_ seconds: TimeInterval) { waitClock += seconds }
    private(set) var waitClock: TimeInterval = 0
}

@Suite("In-place mode with a client that holds only the word before the caret (answers from Cursor logs)")
struct HeldTextComposerTests {
    struct Session {
        var engine = VietEngine(options: DauSettings.defaults.engineOptions)
        var composer = InPlaceComposer()
        let client = ScriptedClient()
        var now: TimeInterval = 0
        var last = InPlaceComposer.Outcome()
        var overCalls = 0

        /// Keys 10 ms apart; `answers` by key index (a key that asks must have one).
        mutating func type(_ keys: String, answers: [Int: (Int, String)] = [:]) {
            for (i, route) in routes(keys).enumerated() {
                now += 0.01
                if let a = answers[i] { client.answer = (a.0, a.1) }
                let (s, r, n) = (client.selections, client.reads, client.inserts.count)
                last = composer.handle(route, time: now, engine: &engine, client: client)
                if client.selections - s > 1 + (last.backspaceWait?.asks ?? 0) || client.reads - r > 1 || client.inserts.count - n > 1 { overCalls += 1 }
                if answers[i] == nil, client.selections != s { Issue.record("key \(i) asked with no answer set") }
            }
        }

        var lastInsert: (text: String, range: NSRange)? { client.inserts.last }
        /// The last insertText as "text location,length".
        var sent: String {
            guard let last = client.inserts.last else { return "-" }
            return "\(last.text) \(last.range.location),\(last.range.length)"
        }

        /// A new file in Cursor's editor, "chiều này" typed: the D20 read at "c" answers 0,
        /// the replacements of "chiều" are on time, and "này" is where the answer (3 "nay")
        /// first differs from the caret followed from the start of the document.
        static func detected() -> Session {
            var s = Session()
            s.type("chieeuf nayf", answers: [0: (0, ""), 4: (4, "chie"), 6: (5, "chiêu"), 11: (3, "nay")])
            return s
        }
    }

    @Test("the held text is detected at the first word whose answer differs from the followed caret")
    func detection() {
        let s = Session.detected()
        #expect(s.composer.tracker.coordinates == .heldText)
        #expect(s.last.held.switched == .held)
        #expect(s.sent == "ày 1,2")
        #expect(s.overCalls == 0)
    }

    /// A new file in Cursor's editor, keys 5 ms apart: at "s" the answer is 1 with "a", and the
    /// first answers at "j" measured there are states of one unit (`docs/Compatibility.md` 5.4).
    @Test("Sasng nay moj: a state of one unit at j switches to held text and gives mọ at 1,1",
          arguments: [(2, " o"), (1, "m"), (2, "mo")])
    func detectionAtFirstReplacementAfterSpace(_ location: Int, _ before: String) {
        var s = Session()
        s.type("Sasng nay moj", answers: [0: (0, ""), 2: (1, "a"), 12: (location, before)])
        #expect(s.composer.tracker.coordinates == .heldText)
        #expect(s.last.held.switched == .held)
        #expect(s.sent == "ọ 1,1")
        #expect(s.overCalls == 0)
    }

    /// The three answers measured at "j" in the editor of Cursor 3.31.15 (`docs/Compatibility.md`
    /// 5.4): 3 with "Hoc" (on time), 4 with "Hoc " (the cache before the ⌫), 1 with " "
    /// (after the space). Each gives the range 1,2 in the held word.
    @Test("Hoc ⌫j after detection: each measured answer gives Học at 1,2",
          arguments: [(3, "Hoc", InPlaceComposer.HeldCheck.Answer.now), (4, "Hoc ", .cache), (1, " ", .before)])
    func addMarksAfterBackspace(_ location: Int, _ before: String, _ expected: InPlaceComposer.HeldCheck.Answer) {
        var s = Session.detected()
        s.type(". Hoc ⌫j", answers: [7: (location, before)])
        #expect(s.last.kind == .seed)
        #expect(s.sent == "ọc 1,2")
        #expect(s.last.held.answer == expected)
        #expect(s.last.held.inHeldText && s.last.held.length == 3)
        #expect(s.overCalls == 0)
    }

    @Test("D4 restore at a word end, D26 double key and D32 backspace: ranges in the held word")
    func otherReplacements() {
        // "metr" shows "mẻt"; the space restores "etr " over "ẻt", ending at the held caret.
        var s = Session.detected()
        s.type(" metr ", answers: [4: (3, "met"), 5: (3, "mẻt")])
        #expect(s.sent == "etr  1,2")
        // "car" shows "cả"; the second r undoes the mark: "ar" over "ả".
        var d = Session.detected()
        d.type(" carr", answers: [3: (2, "ca"), 4: (2, "cả")])
        #expect(d.sent == "ar 1,1")
        // "hoaf" shows "hoà"; ⌫ re-places the tone with the last letter put back.
        var b = Session.detected()
        b.type(" hoaf⌫", answers: [4: (3, "hoa"), 5: (3, "hoà")])
        #expect(b.sent == "òà 1,2")
        #expect(s.overCalls == 0 && d.overCalls == 0 && b.overCalls == 0)
    }

    @Test("an answer that shows the document: back to its coordinates, the key handled as a mismatch there")
    func switchBack() {
        var s = Session.detected()
        s.type(" tiee", answers: [4: (219, "Sáng nay chiều này. tie")])
        #expect(s.composer.tracker.coordinates == .document)
        #expect(s.last.held.switched == .doc)
    }
}


