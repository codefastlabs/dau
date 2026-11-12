import Foundation
import DauEngine
import DauShared
import Testing

/// A terminal like Ghostty 1.4.0 (docs/research/TerminalAndUnderline.md): `insertText`
/// sends the text to the shell as typed, whatever the range, except text that starts with
/// a control character while Ghostty handles a key (dropped, the key then sends nothing);
/// `selectedRange` is always {0,0}; no text can be read. The shell's line editor erases
/// one character per DEL.
private final class FakeGhostty: InPlaceClient {
    var line: [Character] = []
    var selectedRangeCalls = 0
    var reads = 0
    var inserts = 0
    /// Ghostty is handling a key (`InPlaceComposer.handle` is running).
    var inKey = false

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
        if inKey, let first = string.unicodeScalars.first, first.properties.generalCategory == .control { return }
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

/// The xterm.js test page in Chrome (third typing round, 11/11/2026): `selectedRange`
/// between 0 and 2 whatever was typed (here 0, 1, 2 in turn); `insertText` goes to the
/// shell as typed. Measured with the current replacement (second round: "toôoiís"): a key
/// the input method consumed with a range-replacing `insertText` still reaches the shell
/// after the text; with text inserted at the cursor (the erase trial), it does not.
private final class FakeXterm: InPlaceClient {
    var line: [Character] = []
    private var answers = 0
    private(set) var rangedInsert = false

    func selectedRange() -> NSRange {
        defer { answers += 1 }
        return NSRange(location: answers % 3, length: 0)
    }

    func text(in range: NSRange) -> String? { nil }

    func insertText(_ string: String, replacementRange: NSRange) {
        if replacementRange.location != NSNotFound { rangedInsert = true }
        send(string)
    }

    func send(_ string: String) {
        for c in string {
            if c == "\u{7F}" { _ = line.popLast() } else { line.append(c) }
        }
    }

    func key(_ route: KeyRoute, consumed: Bool) {
        defer { rangedInsert = false }
        guard !consumed || rangedInsert else { return }
        switch route {
        case .character(let c): send(String(Character(c)))
        case .backspace: send("\u{7F}")
        default: break
        }
    }
}

/// A text field that applies every range and answers where its caret is (on time), with
/// ⌘A the input method never sees (a menu key equivalent, D11): the next key replaces the
/// selection, ⌫ deletes it.
private final class FakeField: InPlaceClient {
    var text: [UInt16] = []
    var cursor = 0
    /// Length of the selection ending at `cursor`.
    var selected = 0

    func selectedRange() -> NSRange { NSRange(location: cursor - selected, length: selected) }

    func text(in range: NSRange) -> String? {
        guard range.location >= 0, range.location + range.length <= text.count else { return nil }
        return String(decoding: text[range.location..<(range.location + range.length)], as: UTF16.self)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        #expect(!string.unicodeScalars.contains("\u{7F}"))
        let range = replacementRange.location == NSNotFound ? selectedRange() : replacementRange
        // A range outside the text (the input method followed a text that was replaced
        // unseen) is dropped, as NSTextView does.
        guard range.location >= 0, range.location + range.length <= text.count else { return }
        let units = Array(string.utf16)
        text.replaceSubrange(range.location..<(range.location + range.length), with: units)
        cursor = range.location + units.count
        selected = 0
    }

    func defaultAction(_ route: KeyRoute) {
        switch route {
        case .character(let c): insertText(String(Character(c)), replacementRange: NSRange(location: NSNotFound, length: 0))
        case .backspace:
            if selected > 0 {
                insertText("", replacementRange: selectedRange())
            } else if cursor > 0 {
                text.remove(at: cursor - 1)
                cursor -= 1
            }
        default: break
        }
    }

    func selectAllUnseen() {
        cursor = text.count
        selected = text.count
    }

    var string: String { String(decoding: text, as: UTF16.self) }
}

/// A text field that applies every range (as NSTextView does) but always answers
/// `selectedRange` with {0,0}: a field that reports a wrong position (D43, "Bằng chứng
/// dương"). `lag` 0: its text reads right. `lag` > 0: an app stalled at the start of an
/// empty document, whose answers come from the text as it was `lag` keys ago; a read is
/// clamped to that text, as Chromium intersects the range with the text it has cached.
private final class FakeZeroAnswer: InPlaceClient {
    var text: [UInt16] = []
    /// The text after each key, oldest first (`lag`).
    private var states: [[UInt16]] = [[]]
    let lag: Int
    var selectedRangeCalls = 0
    var reads = 0
    /// Every string sent with `insertText`, and the deferred texts (D43, after the key).
    var sent: [String] = []

    init(lag: Int = 0) { self.lag = lag }

    func selectedRange() -> NSRange {
        selectedRangeCalls += 1
        return NSRange(location: 0, length: 0)
    }

    func text(in range: NSRange) -> String? {
        reads += 1
        let answer = states[max(0, states.count - 1 - lag)]
        let lower = max(0, range.location), upper = min(answer.count, range.location + range.length)
        guard lower < upper else { return nil }
        return String(decoding: answer[lower..<upper], as: UTF16.self)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        sent.append(string)
        let range = replacementRange.location == NSNotFound
            ? NSRange(location: text.count, length: 0) : replacementRange
        guard range.location >= 0, range.location + range.length <= text.count else { return }
        text.replaceSubrange(range.location..<(range.location + range.length), with: Array(string.utf16))
    }

    /// The app's own handling of a key the input method did not consume, then the key is
    /// over (`lag`).
    func key(_ route: KeyRoute, consumed: Bool) {
        if !consumed {
            switch route {
            case .character(let c): text.append(contentsOf: String(Character(c)).utf16)
            case .backspace: _ = text.popLast()
            default: break
            }
        }
        states.append(text)
    }

    var string: String { String(decoding: text, as: UTF16.self) }
}

@Suite("D43: fields that ignore the replacement range (Ghostty, xterm.js)")
struct RangeIgnoreTests {
    // MARK: Sending, the mode already known

    /// `afterKey`: the app (Ghostty) handles every key the input method did not consume,
    /// then the deferred text arrives, sent as is.
    private func type(_ keys: String, mode: InPlaceComposer.EraseMode) -> (String, FakeGhostty, [Bool]) {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        composer.eraseMode = mode
        let terminal = FakeGhostty()
        var now: TimeInterval = 0
        var oneCallPerKey: [Bool] = []
        for c in keys.unicodeScalars {
            now += 0.2
            let route: KeyRoute = c == "⌫" ? .backspace : .character(c)
            let before = terminal.inserts
            terminal.inKey = true
            let outcome = composer.handle(route, time: now, engine: &engine, client: terminal)
            terminal.inKey = false
            oneCallPerKey.append(terminal.inserts - before + (outcome.deferredText == nil ? 0 : 1) <= 1)
            if !outcome.consumed { terminal.defaultAction(route) }
            if let deferred = outcome.deferredText { terminal.send(deferred) }
        }
        return (String(terminal.line), terminal, oneCallPerKey)
    }

    @Test("after the key: the cells measured in Ghostty come out right, with no selectedRange and no read",
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

    @Test("in the key: Ghostty drops the fix (second typing round, 11/11/2026)")
    func inKeyInGhostty() {
        #expect(type("dd", mode: .inKey).0 == "d")
        #expect(type("vieetj", mode: .inKey).0 == "viet")
    }

    @Test("not known: the same terminal gives what Ghostty gave in the first typing round (11/11/2026)")
    func baseline() {
        // One word, too short to tell the field apart: in-place replacement as before.
        #expect(type("dd", mode: .off).0 == "dđ")
        #expect(type("vieetj", mode: .off).0 == "vieetj")
    }

    // MARK: Telling the field apart

    /// Keys `interval` apart, as a person types them (above `settleInterval`).
    private struct Run {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        var now: TimeInterval = 0
        var interval: TimeInterval = 0.15
        /// Index of the key at which the field was taken for one that ignores the range.
        var detectedAt: Int?
        var keys = 0

        mutating func handle(_ route: KeyRoute, client: some InPlaceClient) -> InPlaceComposer.Outcome {
            now += interval
            let outcome = composer.handle(route, time: now, engine: &engine, client: client)
            if detectedAt == nil, composer.eraseByDelete { detectedAt = keys }
            keys += 1
            return outcome
        }
    }

    private func ghostty(_ keys: String, interval: TimeInterval = 0.15, run start: Run = Run(),
                         terminal: FakeGhostty = FakeGhostty()) -> (String, Run, FakeGhostty) {
        var run = start
        run.interval = interval
        for route in routes(keys) {
            terminal.inKey = true
            let outcome = run.handle(route, client: terminal)
            terminal.inKey = false
            if !outcome.consumed { terminal.defaultAction(route) }
            if let deferred = outcome.deferredText { terminal.send(deferred) }
        }
        return (String(terminal.line), run, terminal)
    }

    private func xterm(_ keys: String) -> (String, Run) {
        var run = Run()
        let terminal = FakeXterm()
        for route in routes(keys) {
            let outcome = run.handle(route, client: terminal)
            terminal.key(route, consumed: outcome.consumed)
            if let deferred = outcome.deferredText { terminal.send(deferred) }
        }
        return (String(terminal.line), run)
    }

    @Test("Ghostty: taken for a terminal at the second word, sending after the key; every word from there is right")
    func ghosttyDetected() {
        let (text, run, terminal) = ghostty("toois vieetj ddi hocj nhaf ")
        #expect(run.composer.eraseMode == .afterKey)
        // "toois " is 6 keys; detected at the second e of "vieetj" (key 9).
        #expect(run.detectedAt == 9)
        #expect(text.hasSuffix(" việt đi học nhà "))
        // The positive evidence: one read, at that key, which gives nothing (Ghostty
        // without a selection); no selectedRange more than the replacing keys ask.
        #expect(terminal.reads == 1)
        #expect(run.composer.detector.send == .afterKey)
        #expect(!run.composer.detector.refuted)
    }

    @Test("Ghostty: a word whose first replacement is late enough is right from that key",
          arguments: [("nguwowif ", "người "), ("truwowngf ", "trường ")])
    func ghosttyLongWord(keys: String, expected: String) {
        // Only one stuck answer in a first short word: a later word still finds the second.
        let (text, run, _) = ghostty("toois " + keys)
        #expect(run.composer.eraseMode == .afterKey)
        #expect(text.hasSuffix(expected))
    }

    @Test("xterm.js: told apart from its answers of 0 to 2 (in the key); in place until a Return, as ranges were sent")
    func xtermDetected() {
        let (_, run) = xterm("toois vieetj nguwowif ddi hocj nhaf ")
        #expect(run.composer.detector.send == .inKey)
        // `InPlaceComposer.eraseMode(for:)`: range replacements came before (XtermPageTests).
        #expect(!run.composer.eraseByDelete)
    }

    /// The line of the fourth typing round (scripts/research/terminal-underline/run.sh,
    /// t4- cells): the prediction written before the run.
    static let t4Line = "toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows "

    @Test("the t4 line: Ghostty right from the second word; xterm.js told apart, in place until a Return")
    func t4Line() {
        let (gh, ghRun, _) = ghostty(Self.t4Line)
        print("t4 ghostty: \"\(gh)\" detected at key \(ghRun.detectedAt.map(String.init) ?? "-")")
        #expect(gh.hasSuffix(" việt đi học nhà người hò windows "))
        let (xt, xtRun) = xterm(Self.t4Line)
        print("t4 xterm: \"\(xt)\"")
        #expect(xtRun.composer.detector.send == .inKey)
        #expect(!xtRun.composer.eraseByDelete)
    }

    @Test("Ghostty: Return (which empties an xterm.js line) changes nothing, the same calls and text")
    func ghosttyReturn() {
        func run(endsLine: Bool) -> (String, Int, Int, InPlaceComposer.EraseMode) {
            var engine = VietEngine()
            var composer = InPlaceComposer()
            let terminal = FakeGhostty()
            var now: TimeInterval = 0
            for scalar in (Self.t4Line + "↩" + Self.t4Line).unicodeScalars {
                now += 0.15
                let route: KeyRoute = scalar == "⌫" ? .backspace : scalar == "↩" ? .endWord : .character(scalar)
                terminal.inKey = true
                let outcome = composer.handle(route, time: now, engine: &engine, client: terminal,
                                              endsLine: endsLine && scalar == "↩")
                terminal.inKey = false
                if !outcome.consumed { terminal.defaultAction(route) }
                if let deferred = outcome.deferredText { terminal.send(deferred) }
            }
            return (String(terminal.line), terminal.inserts, terminal.selectedRangeCalls, composer.eraseMode)
        }
        let with = run(endsLine: true), without = run(endsLine: false)
        #expect(with.0 == without.0)
        #expect(with.1 == without.1)
        #expect(with.2 == without.2)
        #expect(with.3 == .afterKey)
        #expect(with.0.hasSuffix("windows tối việt đi học nhà người hò windows "))
    }

    @Test("keys in a burst are never judged: a terminal typed at 30 ms is not told apart")
    func burst() {
        let (_, run, _) = ghostty("toois vieetj ddi hocj nhaf ", interval: 0.03)
        #expect(run.detectedAt == nil)
    }

    @Test("a new activation judges the field from the start again")
    func activation() {
        var (_, run, _) = ghostty("toois vieetj ")
        #expect(run.composer.eraseByDelete)
        run.composer.activate()
        #expect(!run.composer.eraseByDelete)
        #expect(run.composer.detector.send == nil)
    }

    // MARK: Never a text field

    private func field(_ steps: [(String, Bool)]) -> (String, Run, Bool) {
        var run = Run()
        let doc = FakeField()
        var suspected = false
        for (keys, clearFirst) in steps {
            if clearFirst { doc.selectAllUnseen() }
            for route in routes(keys) {
                let outcome = run.handle(route, client: doc)
                if !outcome.consumed { doc.defaultAction(route) }
                suspected = suspected || run.composer.detector.suspicion != nil
            }
        }
        return (doc.string, run, suspected)
    }

    @Test("a text field from the start of the document is never taken for a terminal")
    func fieldFromStart() {
        let (text, run, suspected) = field([("toois vieetj ddi hocj nhaf dd ", false)])
        #expect(text == "tối việt đi học nhà đ ")
        #expect(!suspected)
        #expect(run.detectedAt == nil)
    }

    @Test("a word cleared unseen in the middle (⌘A ⌫) is one suspicion, not a terminal")
    func clearedMidWord() {
        // "toi", ⌘A unseen, ⌫, then "s…": the answer 0 is before the 2 units the word must
        // have; the next words grow past `terminalLimit` and clear the suspicion.
        let (text, run, suspected) = field([("toi", false), ("⌫sinh vieen ", true), ("toi", false),
                                             ("⌫sinh vieen ", true)])
        #expect(suspected)
        #expect(run.detectedAt == nil)
        #expect(text == "sinh viên ")
    }

    @Test("⌘A unseen and the word typed again with no space (D11: tốt, ⌘A, toots)")
    func retypedAfterSelectAll() {
        let (text, run, _) = field([("toots", false), ("toots", true), ("toots", true), ("dd", true)])
        #expect(run.detectedAt == nil)
        #expect(text == "đ")
    }

    @Test("a suspicion lasts until the end of the next word")
    func suspicionExpires() {
        // Two words cleared unseen, with words between that ask nothing (no replacement).
        let (_, run, suspected) = field([("hoc", false), ("⌫j ", true), ("xyz ", false), ("hoc", false),
                                          ("⌫j ", true)])
        #expect(suspected)
        #expect(run.detectedAt == nil)
    }

    @Test("known limit: cleared unseen just before a mark key in two words in a row is taken for a terminal")
    func clearedInTwoWordsInARow() {
        // Each clear leaves the field at 0 while the word must hold 2 letters, and nothing
        // in between answers above `terminalLimit`.
        withKnownIssue {
            let (_, run, _) = field([("hoc", false), ("⌫j ", true), ("hoc", false), ("⌫j ", true)])
            #expect(run.detectedAt == nil)
        }
    }

    // MARK: Positive evidence (one read)

    /// Keys typed in a `FakeZeroAnswer`; the deferred text (D43, after the key) goes in
    /// as plain text, as a text field would take it.
    private func zero(_ keys: String, lag: Int = 0, run start: Run = Run(),
                      client: FakeZeroAnswer? = nil) -> (FakeZeroAnswer, Run) {
        var run = start
        let doc = client ?? FakeZeroAnswer(lag: lag)
        for route in routes(keys) {
            let outcome = run.handle(route, client: doc)
            doc.key(route, consumed: outcome.consumed)
            if let deferred = outcome.deferredText { doc.insertText(deferred, replacementRange: NSRange(location: NSNotFound, length: 0)) }
        }
        return (doc, run)
    }

    /// What the line gives in a field that always answers {0,0}, replaced in place with no
    /// D43 at all (the same fake on the code before D43): the first replacement of each
    /// word is a mismatch (the answer 0 is before the word, D11), the key starts over
    /// alone ("w" gives "ư"), with the eight selectedRange answers the replacing keys ask.
    static let zeroLine = "vieetj nguwowif tieengs "
    static let zeroBeforeD43 = "vieetj nguưoưif tieengs "

    @Test("a field that always answers {0,0} but reads right: not taken for a terminal, no DEL, as before D43")
    func wrongPositionReadable() {
        let (doc, run) = zero(Self.zeroLine)
        #expect(doc.string == Self.zeroBeforeD43)
        #expect(!doc.sent.contains { $0.unicodeScalars.contains("\u{7F}") })
        #expect(run.detectedAt == nil)
        #expect(run.composer.detector.refuted)
        #expect(run.composer.detector.send == nil)
        // One read more than before D43, no selectedRange more.
        #expect(doc.reads == 1)
        #expect(doc.selectedRangeCalls == 8)
    }

    @Test("an app stalled at the start of an empty document gives back part of Dấu's text: not a terminal",
          arguments: [1, 2, 5, 9])
    func stalledAtStart(lag: Int) {
        // The read is answered from the text `lag` keys ago, clamped to it: the start of
        // what was typed, without the latest keys.
        let (doc, run) = zero(Self.zeroLine, lag: lag)
        #expect(doc.string == Self.zeroBeforeD43)
        #expect(!doc.sent.contains { $0.unicodeScalars.contains("\u{7F}") })
        #expect(run.composer.detector.refuted)
        #expect(doc.reads == 1)
    }

    @Test("known limit: an app stalled so long that it has none of the text read is taken for a terminal")
    func stalledPastTheRead() {
        // Told apart at the tenth key; an answer from before the first key has no text,
        // as Ghostty (D43, "Hệ quả đã chấp nhận": a field with a constant 0 that gives no text).
        withKnownIssue {
            let (doc, _) = zero(Self.zeroLine, lag: 12)
            #expect(!doc.sent.contains { $0.unicodeScalars.contains("\u{7F}") })
        }
    }

    @Test("the verdict lasts the activation: a click or a reset keeps it, with no read again; activation drops it")
    func verdictPerActivation() {
        // Refuted: a click and a shortcut (reset), more words; still one read, no DEL.
        var (doc, run) = zero(Self.zeroLine)
        run.composer.noteEvent(at: run.now + 0.5)
        run.now += 0.5
        _ = run.handle(.ignore, client: doc)
        (doc, run) = zero("toois vieetj ddi ", run: run, client: doc)
        #expect(run.composer.detector.refuted)
        #expect(doc.reads == 1)
        #expect(!doc.sent.contains { $0.unicodeScalars.contains("\u{7F}") })

        // Told apart (Ghostty): the same; the next activation judges again, with its own read.
        var (_, gh, terminal) = ghostty("toois vieetj ")
        #expect(gh.composer.eraseMode == .afterKey)
        gh.composer.noteEvent(at: gh.now + 0.5)
        gh.now += 0.5
        _ = gh.handle(.ignore, client: terminal)
        var text: String
        (text, gh, terminal) = ghostty("ddi hocj ", run: gh, terminal: terminal)
        #expect(gh.composer.eraseMode == .afterKey)
        #expect(text.hasSuffix(" đi học "))
        #expect(terminal.reads == 1)
        gh.composer.activate()
        gh.detectedAt = nil
        // Mid-session no D20 read anchors the first word: told apart one word later.
        (text, gh, terminal) = ghostty("toois vieetj nguwowif ", run: gh, terminal: terminal)
        #expect(gh.composer.eraseMode == .afterKey)
        #expect(terminal.reads == 2)
    }

    @Test("Ghostty over the t4 line: told apart at the same key with one read, no selectedRange added")
    func ghosttyCalls() {
        let (_, run, terminal) = ghostty(Self.t4Line)
        #expect(run.detectedAt == 9)
        #expect(terminal.reads == 1)
        // The same key and the same four selectedRange answers as the code before the
        // evidence read (checked on that code with this fake); the read is the only call added.
        #expect(terminal.selectedRangeCalls == 4)
    }

    // MARK: The detector alone

    @Test("the smallest answer of a text field allows two late keys plus the latest burst")
    func minimumAnswer() {
        var d = RangeIgnoreDetector()
        for _ in 0..<3 { d.keyHandled(delta: 1, inBurst: false) }
        #expect(d.minimumAnswer == 1)       // states 0 1 2 3: two keys late → 1
        d.keyHandled(delta: 0, inBurst: false)
        #expect(d.minimumAnswer == 2)       // 0 1 2 3 3: window of 3 over 2 3 3
        d.keyHandled(delta: 1, inBurst: true)
        #expect(d.minimumAnswer == 2)       // one burst key: window 4 over 2 3 3 4
        d.startWord()
        #expect(d.minimumAnswer == 0)
    }

    @Test("two stuck answers make a terminal; an answer above 2 in between clears the first")
    func suspicion() {
        var d = RangeIgnoreDetector()
        for _ in 0..<4 { d.keyHandled(delta: 1, inBurst: false) }
        let zero = NSRange(location: 0, length: 0)
        #expect(d.observe(zero, inBurst: false) == nil)
        #expect(d.suspicion != nil)
        d.note(NSRange(location: 3, length: 0))
        #expect(d.suspicion == nil)
        #expect(d.observe(zero, inBurst: false) == nil)
        // Nothing added since the first stuck answer: a text field may answer that too.
        #expect(d.observe(zero, inBurst: false) == nil)
        for _ in 0..<3 { d.keyHandled(delta: 1, inBurst: false) }
        #expect(d.observe(zero, inBurst: true) == nil)           // a burst key is not judged
        #expect(d.observe(NSRange(location: 0, length: 2), inBurst: false) == nil)  // a selection
        // Three units added, the app at most two keys behind: a text field is at 1 or later.
        #expect(d.observe(zero, inBurst: false) == .afterKey)
    }

    @Test("an answer of 1 or 2 seen in the activation means sending in the key (xterm.js)")
    func sendInKey() {
        var d = RangeIgnoreDetector()
        d.note(NSRange(location: 2, length: 0))
        for _ in 0..<4 { d.keyHandled(delta: 1, inBurst: false) }
        #expect(d.observe(NSRange(location: 1, length: 0), inBurst: false) == nil)
        for _ in 0..<3 { d.keyHandled(delta: 1, inBurst: false) }
        #expect(d.observe(NSRange(location: 0, length: 0), inBurst: false) == .inKey)
    }

    @Test("the evidence read: Dấu's own text, also late or clamped, refutes; nothing or other text does not",
          arguments: [
            ("việt ngư", "việt ngư", true),     // the field's text
            ("viet ngu", "việt ngư", true),     // the latest replacements not applied yet
            ("việt ng", "việt ngư", true),      // the latest key missing (clamped)
            ("việt ", "việt ngư", true),        // the word not started yet
            ("VIỆT NGƯ", "việt ngư", true),     // case and marks do not count
            ("vieetj ngu", "vieetj nguư", true),
            ("v", "vieetj ng", true),           // only the first key arrived
            ("", "việt ngư", false),
            ("ls -la", "việt ngư", false),      // Ghostty: the text selected on screen
            ("ư", "việt ngư", false),           // xterm.js: the textarea, wherever asked
            ("việt mới", "việt ngư", false),    // another word at that place
            ("x việt ngư", "việt ngư", false),  // not lined up with the range
            ("  ", "  ", false),                // no letter
          ])
    func ownText(read: String, typed: String, own: Bool) {
        #expect(RangeIgnoreDetector.isOwnText(read, typed: Array(typed.utf16)) == own)
    }

    @Test("the evidence range ends where Dấu followed the cursor to, from 0 at the activation, at most 16 units")
    func evidenceRange() {
        var d = RangeIgnoreDetector()
        #expect(d.evidence == nil)
        d.edited(removing: 0, inserting: "abc".utf16)
        d.keyHandled(delta: 3, inBurst: false)
        #expect(d.evidence?.range == NSRange(location: 0, length: 3))
        // "c" replaced with 19 units: 21 units typed, the last 16 read.
        d.edited(removing: 1, inserting: ("d" + String(repeating: "đ", count: 18)).utf16)
        d.keyHandled(delta: 18, inBurst: false)
        #expect(d.evidence?.range == NSRange(location: 5, length: 16))
        #expect(d.evidence?.typed == Array(String(repeating: "đ", count: 16).utf16))
        d.refute()
        #expect(d.evidence == nil)
        #expect(d.observe(NSRange(location: 0, length: 0), inBurst: false) == nil)
    }
}
