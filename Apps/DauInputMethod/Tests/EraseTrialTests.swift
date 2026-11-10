import Foundation
import DauEngine
import DauShared
import Testing

/// A terminal like Ghostty 1.4.0 (docs/research/TERMINAL-AND-UNDERLINE.md): `insertText`
/// sends the text to the shell as typed, whatever the range; `selectedRange` is always
/// {0,0}; no text can be read. The shell's line editor erases one character per DEL.
private final class FakeTerminal: InPlaceClient {
    var line: [Character] = []
    var selectedRangeCalls = 0
    var reads = 0
    var inserts = 0

    func selectedRange() -> NSRange {
        selectedRangeCalls += 1
        return NSRange(location: 0, length: 0)
    }

    func text(in range: NSRange) -> String? {
        reads += 1
        return nil
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        inserts += 1
        send(string)
    }

    /// Bytes reaching the shell: DEL erases, anything else is appended.
    func send(_ string: String) {
        for c in string {
            if c == "\u{7F}" { _ = line.popLast() } else { line.append(c) }
        }
    }

    /// The app's own handling of a key the input method did not consume.
    func defaultAction(_ route: KeyRoute) {
        switch route {
        case .character(let c): send(String(Character(c)))
        case .backspace: send("\u{7F}")
        default: break
        }
    }
}

@Suite("Erase trial (Debug): DEL characters for a client that ignores replacementRange")
struct EraseTrialTests {
    private func type(_ keys: String, erase: Bool) -> (String, FakeTerminal, [Bool]) {
        type(keys, mode: erase ? .inKey : .off)
    }

    /// `afterKey`: the app (Ghostty) handles every key the input method did not consume,
    /// then the deferred text arrives, sent as is.
    private func type(_ keys: String, mode: InPlaceComposer.EraseMode) -> (String, FakeTerminal, [Bool]) {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        composer.eraseMode = mode
        let terminal = FakeTerminal()
        var now: TimeInterval = 0
        var oneCallPerKey: [Bool] = []
        for c in keys.unicodeScalars {
            now += 0.2
            let route: KeyRoute = c == "⌫" ? .backspace : .character(c)
            let before = terminal.inserts
            let outcome = composer.handle(route, time: now, engine: &engine, client: terminal)
            oneCallPerKey.append(terminal.inserts - before <= 1)
            if !outcome.consumed { terminal.defaultAction(route) }
            if let deferred = outcome.deferredText { terminal.send(deferred) }
        }
        return (String(terminal.line), terminal, oneCallPerKey)
    }

    @Test("the cells measured in Ghostty come out right, with no selectedRange and no read",
          arguments: [("dd", "đ"), ("toois", "tối"), ("vieetj", "việt"), ("toois vieetj", "tối việt"),
                      ("tooisf", "tồi"), ("hoaf⌫", "hò"), ("DD", "Đ"), ("windows ", "windows ")])
    func cells(keys: String, expected: String) {
        let (text, terminal, oneCall) = type(keys, erase: true)
        #expect(text == expected)
        #expect(terminal.selectedRangeCalls == 0)
        #expect(terminal.reads == 0)
        #expect(oneCall.allSatisfy { $0 })
    }

    @Test("after the key: the fix follows the app's own handling of the key",
          arguments: [("dd", "đ"), ("toois", "tối"), ("vieetj", "việt"), ("toois vieetj", "tối việt"),
                      ("tooisf", "tồi"), ("hoaf⌫", "hò"), ("DD", "Đ"), ("windows ", "windows "),
                      ("toois vieetj ddi hoaf⌫ windows ", "tối việt đi hò windows ")])
    func afterKey(keys: String, expected: String) {
        let (text, terminal, oneCall) = type(keys, mode: .afterKey)
        #expect(text == expected)
        #expect(terminal.selectedRangeCalls == 0)
        #expect(terminal.reads == 0)
        #expect(oneCall.allSatisfy { $0 })
    }

    @Test("without the trial the same terminal gives what Ghostty gave (measured 11/11/2026)")
    func baseline() {
        #expect(type("dd", erase: false).0 == "dđ")
        #expect(type("vieetj", erase: false).0 == "vieetj")
    }
}
