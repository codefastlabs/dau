import Foundation
import DauEngine
import Testing

/// A text field that applies every range and answers where its caret is, counting calls.
private final class CountingField: InPlaceClient {
    var text: [UInt16] = []
    var cursor = 0
    var calls = 0

    func selectedRange() -> NSRange {
        calls += 1
        return NSRange(location: cursor, length: 0)
    }

    func text(in range: NSRange) -> String? {
        calls += 1
        guard range.location >= 0, range.location + range.length <= text.count else { return nil }
        return String(decoding: text[range.location..<(range.location + range.length)], as: UTF16.self)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        calls += 1
        let range = replacementRange.location == NSNotFound ? NSRange(location: cursor, length: 0) : replacementRange
        guard range.location >= 0, range.location + range.length <= text.count else { return }
        let units = Array(string.utf16)
        text.replaceSubrange(range.location..<(range.location + range.length), with: units)
        cursor = range.location + units.count
    }

    func key(_ route: KeyRoute, consumed: Bool) {
        guard !consumed else { return }
        switch route {
        case .character(let c): insertText(String(Character(c)), replacementRange: NSRange(location: NSNotFound, length: 0))
        case .backspace:
            if cursor > 0 { text.remove(at: cursor - 1); cursor -= 1 }
        case .endWord: insertText("\n", replacementRange: NSRange(location: NSNotFound, length: 0))
        case .ignore: break
        }
    }

    var string: String { String(decoding: text, as: UTF16.self) }
}

/// D43 (Ô bỏ qua vùng thay chữ) on the xterm.js test page, through `FakeXtermPage` (a
/// model of Chromium, Blink and xterm.js 5.5.0 from their code). Observations it must
/// give back, from docs/Progress.md (11/11/2026) and docs/research/TerminalAndUnderline.md:
/// - O1 (second typing round, in place before D43): `toois vieetj dd ` →
///   "toôoiís vieêetj dđd ";
/// - O2 (second round, DEL sent in the key from the first key): "tối việt đ ", the shell
///   getting "⌫ô", "⌫⌫ối"…, never the key typed;
/// - O3 (fourth round, DEL sent in the key from the detection key at the j of "vieetj",
///   after a range replacement at its second e): "toôoiís vieêeệtê ệtđêi hoệtọcê…", each
///   chunk sending again every earlier fix and an "ê" at its end.
@Suite("D43 on the xterm.js page (FakeXtermPage)")
struct XtermPageTests {
    struct Run {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        var now: TimeInterval = 0
        /// Most `insertText` calls the input method made in one key.
        var mostInserts = 0
    }

    /// Keys 120 ms apart, as in the typing runs: `⌫` Delete, `↩` Return, `⇥` Tab.
    static func routes(_ keys: String) -> [(KeyRoute, Bool)] {
        keys.unicodeScalars.map {
            switch $0 {
            case "⌫": (.backspace, false)
            case "↩": (.endWord, true)
            case "⇥": (.endWord, false)
            default: (.character($0), false)
            }
        }
    }

    static func type(_ keys: String, on page: FakeXtermPage, run: inout Run) {
        for (route, endsLine) in routes(keys) {
            run.now += 0.12
            var inserts = 0
            page.key(route, isReturn: endsLine) {
                let before = page.inserts
                let outcome = run.composer.handle(route, time: run.now, engine: &run.engine, client: page,
                                                  endsLine: endsLine)
                inserts = page.inserts - before
                #expect(outcome.deferredText == nil)
                return outcome.consumed
            }
            run.mostInserts = max(run.mostInserts, inserts)
        }
    }

    // MARK: The fake gives back what was measured

    @Test("O1: in place, as measured before D43 (second typing round)")
    func inPlaceAsMeasured() {
        let page = FakeXtermPage()
        var run = Run()
        Self.type("toois vieetj dd ", on: page, run: &run)
        #expect(page.lineText == "toôoiís vieêetj dđd ")
        // The replacement first, then the key typed.
        #expect(page.chunks.prefix(4) == ["t", "o", "ô", "o"])
    }

    @Test("O2: DEL in the key from the first key, as measured (second round): right, never the key typed")
    func inKeyFromTheStart() {
        let page = FakeXtermPage()
        var run = Run()
        run.composer.eraseMode = .inKey
        Self.type("toois vieetj dd ", on: page, run: &run)
        #expect(page.lineText == "tối việt đ ")
        #expect(page.chunks.prefix(5) == ["t", "o", "\u{7F}ô", "i", "\u{7F}\u{7F}ối"])
        // The textarea keeps every fix and every space, its caret at the end.
        #expect(page.caret == page.value.count)
    }

    @Test("O3: DEL in the key with text left after the textarea's caret stacks, as in the fourth round")
    func fourthRoundStacks() {
        // The state the fourth round's chunks imply at the j of "vieetj": a range
        // replacement at the second e put "ê" after the caret (kept before the range by
        // ReplaceTextAndKeepSelection), the space of "toois " before it.
        var run = Run()
        run.composer.eraseMode = .inKey
        Self.type("toois vieet", on: FakeXtermPage(), run: &run)
        let page = FakeXtermPage(value: " ê", caret: 1, line: "toôoiís vieêet")
        Self.type("j ddi hocj", on: page, run: &run)
        #expect(page.lineText == "toôoiís vieêeệtê ệtđêi hoệtọcê")
        #expect(page.chunks.first == " \u{7F}\u{7F}ệtê")
        #expect(page.chunks.contains(" \u{7F}\u{7F}ệt \u{7F}đê"))
    }

    @Test("control: the same keys with the textarea's caret at the end do not stack")
    func caretAtTheEndDoesNotStack() {
        var run = Run()
        run.composer.eraseMode = .inKey
        Self.type("toois vieet", on: FakeXtermPage(), run: &run)
        let page = FakeXtermPage(value: " ê", caret: 2, line: "tối viêt")
        Self.type("j ddi hocj ", on: page, run: &run)
        #expect(page.lineText == "tối việt đi học ")
        #expect(page.chunks.first == "\u{7F}\u{7F}ệt")
    }

    // MARK: The fix

    /// The page answering 0, 1, 2 in turn (`scripted`): told apart as xterm.js (in the key).
    static let scripted = [0, 1, 2]

    @Test("detected with range replacements behind: in place until Return, then right from the next line")
    func waitsForReturn() {
        let page = FakeXtermPage(scripted: Self.scripted)
        var run = Run()
        Self.type(RangeIgnoreTests.t4Line, on: page, run: &run)
        #expect(run.composer.detector.send == .inKey)
        #expect(run.composer.eraseMode == .off)
        let firstLine = page.lineText
        let calls = (page.selectedRangeCalls, page.reads)
        Self.type("↩", on: page, run: &run)
        #expect(run.composer.eraseMode == .inKey)
        #expect(page.value.isEmpty)
        let chunksBefore = page.chunks.count
        run.mostInserts = 0
        let secondLine = RangeIgnoreTests.t4Line + "toois vieetj "
        Self.type(secondLine, on: page, run: &run)
        print("xterm page, first line (in place until Return): \"\(firstLine)\"")
        #expect(page.lineText == firstLine + "tối việt đi học nhà người hò windows tối việt ")
        // No stacking: one chunk per key, the textarea's caret at its end; no
        // selectedRange, no read; at most one insertText per key (N3).
        #expect(page.chunks.count - chunksBefore == secondLine.unicodeScalars.count)
        #expect(page.caret == page.value.count)
        #expect(page.selectedRangeCalls == calls.0)
        #expect(page.reads == calls.1)
        #expect(run.mostInserts <= 1)
    }

    @Test("the erase mode waits only when a range was sent since the last Return (or the activation)")
    func eraseModePolicy() {
        var composer = InPlaceComposer()
        #expect(composer.eraseMode(for: .inKey) == nil)  // activation: unknown
        #expect(composer.eraseMode(for: .afterKey) == .afterKey)
        var engine = VietEngine()
        let field = CountingField()
        _ = composer.handle(.endWord, time: 1, engine: &engine, client: field, endsLine: true)
        #expect(composer.eraseMode(for: .inKey) == .inKey)
        for (i, c) in "dd".unicodeScalars.enumerated() {
            let outcome = composer.handle(.character(c), time: 2 + Double(i), engine: &engine, client: field)
            field.key(.character(c), consumed: outcome.consumed)
        }
        #expect(field.string == "đ")
        #expect(composer.eraseMode(for: .inKey) == nil)  // "đ" went in with a range
        _ = composer.handle(.endWord, time: 5, engine: &engine, client: field, endsLine: false)
        #expect(composer.eraseMode(for: .inKey) == nil)  // Tab does not empty a line
        composer.activate()
        #expect(composer.eraseMode(for: .inKey) == nil)
    }

    @Test("in the key: Delete that re-places the tone is consumed and right (D32)",
          arguments: [("hoaf⌫ ", "hò "), ("toois⌫ ", "tố "), ("hoaf⌫⌫ ", "h ")])
    func backspace(keys: String, expected: String) {
        let page = FakeXtermPage()
        var run = Run()
        run.composer.eraseMode = .inKey
        Self.type(keys, on: page, run: &run)
        #expect(page.lineText == expected)
    }

    @Test("in the key: one letter that is not the key's own goes through the textarea too",
          arguments: [("wa ", "ưa "), ("wowcs ", "ước "), ("Wa ", "Ưa "), ("windows ", "windows ")])
    func singleLetter(keys: String, expected: String) {
        let page = FakeXtermPage()
        var run = Run()
        run.composer.eraseMode = .inKey
        Self.type(keys, on: page, run: &run)
        #expect(page.lineText == expected)
        #expect(page.caret == page.value.count)
    }

    @Test("in the key: Return and Tab send no fix (the word stays as shown, as in Ghostty)",
          arguments: ["↩", "⇥"])
    func returnAndTab(key: String) {
        let page = FakeXtermPage()
        var run = Run()
        run.composer.eraseMode = .inKey
        Self.type("windows" + key, on: page, run: &run)
        #expect(page.chunks.last == (key == "↩" ? "\r" : "\t"))
        #expect(!page.lineText.hasPrefix("windows"))
        #expect(!page.chunks.contains { $0.unicodeScalars.first == "\u{7F}" && $0.hasSuffix("windows") })
    }

    // MARK: Unchanged elsewhere

    @Test("a text field: Return changes no call and no text (N3)")
    func textFieldUnchanged() {
        func run(endsLine: Bool) -> (String, Int, InPlaceComposer.EraseMode) {
            var composer = InPlaceComposer()
            var engine = VietEngine()
            let field = CountingField()
            var now: TimeInterval = 0
            for (route, isReturn) in Self.routes("toois vieetj↩ddi hocj↩nhaf ") {
                now += 0.12
                let outcome = composer.handle(route, time: now, engine: &engine, client: field,
                                              endsLine: isReturn && endsLine)
                field.key(route, consumed: outcome.consumed)
            }
            return (field.string, field.calls, composer.eraseMode)
        }
        let with = run(endsLine: true), without = run(endsLine: false)
        #expect(with.0 == "tối việt\nđi học\nnhà ")
        #expect(with.0 == without.0)
        #expect(with.1 == without.1)
        #expect(with.2 == .off)
    }
}
