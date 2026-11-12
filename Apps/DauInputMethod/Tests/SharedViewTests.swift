import Foundation
import DauEngine
import Testing

/// One IMK client holding a terminal and an ordinary text field: an Electron or Chromium
/// app whose terminal (xterm.js) and editor are elements of one page, so of one
/// `RenderWidgetHostViewCocoa` (VS Code and Cursor: the integrated terminal next to the
/// editor; the Claude app: an xterm.js terminal and a TipTap editor in one bundle, read
/// from its code, not measured). D43 (Ô bỏ qua vùng thay chữ) keeps its verdict until IMK
/// activates the input method again.
///
/// A click from one element to the other, from Chromium's code (main of 12/11/2026,
/// content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm):
/// - `mouseEvent:` never passes a mouse down to the input context ("TODO(suzhe): We
///   should send mouse events to the input method first"); it calls
///   `finishComposingText`, which returns at once without marked text (in-place mode).
///   So the input method sees no click at all: no reset, no `noteEvent`, the same
///   composer, engine and `CursorTracker` state.
/// - `insertText:replacementRange:` filters no control character: without a range the
///   text is collected while a key is handled, else sent with `ImeCommitText`.
///
/// Assumed, not read or not measured:
/// - focus moving between two editable elements of the page changes no IMK client and
///   brings no `activateServer` (the case the question is about);
/// - the field after the click answers on time (`LateDocument`, `lag` 0, Chromium cache);
/// - a DEL (U+007F) that reaches the field is inserted as a character, as `LateDocument`
///   does with any text: Blink's `EditingBehavior::ShouldInsertCharacter` only refuses
///   units below U+0020 for a one-unit keypress (read), and `ImeCommitText` of more than
///   one unit was not followed down to the editor (TipTap/ProseMirror, Monaco's
///   EditContext: not read). How an editor shows U+007F is not modelled.
/// - xterm.js's textarea is emptied on blur (xterm.js 5.5.0), so the terminal after a
///   click back starts with an empty textarea (a new `FakeXtermPage`).
final class FakeSharedView: InPlaceClient {
    enum Terminal {
        case xterm(FakeXtermPage)
        /// Hypothetical: no app is known to put a Ghostty-like field in one view with a
        /// text field (Ghostty is an app of its own, so another client).
        case ghostty(FakeGhostty)
    }
    enum Focus { case terminal, field }

    var terminal: Terminal
    let field: LateDocument
    var focus = Focus.terminal

    /// Calls the input method made (N3), deferred texts included in `inserts`.
    private(set) var inserts = 0, selections = 0, reads = 0
    /// DEL characters that reached the field.
    private(set) var fieldDeletes = 0

    init(terminal: Terminal, field: LateDocument = LateDocument(), focus: Focus = .terminal) {
        self.terminal = terminal
        self.field = field
        self.focus = focus
        field.cache = .chromium
    }

    /// The terminal's line (what reached the shell).
    var line: String {
        switch terminal {
        case .xterm(let page): page.lineText
        case .ghostty(let g): String(g.line)
        }
    }

    // MARK: InPlaceClient

    private var target: any InPlaceClient {
        if focus == .field { return field }
        switch terminal {
        case .xterm(let page): return page
        case .ghostty(let g): return g
        }
    }

    func selectedRange() -> NSRange {
        selections += 1
        return target.selectedRange()
    }

    func text(in range: NSRange) -> String? {
        reads += 1
        return target.text(in: range)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        inserts += 1
        if focus == .field {
            fieldDeletes += string.unicodeScalars.filter { $0 == "\u{7F}" }.count
            // `LateDocument` records an issue for a DEL; the tests that send one say so.
        }
        target.insertText(string, replacementRange: replacementRange)
    }

    // MARK: Keys

    /// One key: the app's path for it, with `handle` the input method's `handleEvent`;
    /// a deferred text (D43, after the key) goes in once the app has handled the key, as
    /// `DauInputController` sends it.
    func key(_ route: KeyRoute, endsLine: Bool, handle: () -> InPlaceComposer.Outcome) {
        var deferred: String?
        switch (focus, terminal) {
        case (.terminal, .xterm(let page)):
            page.key(route, isReturn: endsLine) {
                let outcome = handle()
                deferred = outcome.deferredText
                return outcome.consumed
            }
        case (.terminal, .ghostty(let g)):
            g.inKey = true
            let outcome = handle()
            g.inKey = false
            if !outcome.consumed { g.defaultAction(route) }
            deferred = outcome.deferredText
        case (.field, _):
            let outcome = handle()
            if !outcome.consumed { field.typed(route) }
            deferred = outcome.deferredText
        }
        if let deferred {
            inserts += 1
            if focus == .field { fieldDeletes += deferred.unicodeScalars.filter { $0 == "\u{7F}" }.count }
            switch (focus, terminal) {
            case (.terminal, .ghostty(let g)): g.send(deferred)
            default: target.insertText(deferred, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            }
        }
    }
}

@Suite("D43 in one view holding a terminal and a text field (Electron, Chromium)")
struct SharedViewTests {
    struct Run {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        var now: TimeInterval = 0
        var keys = 0
        /// Key index at which the detector first had a verdict.
        var detectedAt: Int?
        /// Key index at which `eraseByDelete` first turned on.
        var erasingAt: Int?
        /// Most calls of each kind in one key, since `phase()`.
        var most = (inserts: 0, selections: 0, reads: 0)
    }

    /// Calls since a point, and the keys typed before it.
    struct Mark {
        let inserts: Int, selections: Int, reads: Int, keys: Int
    }

    /// Keys 120 ms apart: `⌫` Delete, `↩` Return, `⇥` Tab (`XtermPageTests.routes`).
    static func type(_ keys: String, on view: FakeSharedView, run: inout Run) {
        for (route, endsLine) in XtermPageTests.routes(keys) {
            run.now += 0.12
            let before = (view.inserts, view.selections, view.reads)
            view.key(route, endsLine: endsLine) {
                run.composer.handle(route, time: run.now, engine: &run.engine, client: view, endsLine: endsLine)
            }
            run.most.inserts = max(run.most.inserts, view.inserts - before.0)
            run.most.selections = max(run.most.selections, view.selections - before.1)
            run.most.reads = max(run.most.reads, view.reads - before.2)
            if run.detectedAt == nil, run.composer.detector.send != nil { run.detectedAt = run.keys }
            if run.erasingAt == nil, run.composer.eraseByDelete { run.erasingAt = run.keys }
            run.keys += 1
        }
    }

    /// A click from one element of the page to the other: the input method sees nothing
    /// (Chromium, see `FakeSharedView`); a second passes. Returns the calls so far.
    static func click(to focus: FakeSharedView.Focus, on view: FakeSharedView, run: inout Run) -> Mark {
        run.now += 1
        view.focus = focus
        run.most = (0, 0, 0)
        return Mark(inserts: view.inserts, selections: view.selections, reads: view.reads, keys: run.keys)
    }

    /// DEL as "␡", line breaks as "⏎", for the printed results.
    static func shown(_ text: String) -> String {
        text.replacingOccurrences(of: "\u{7F}", with: "␡").replacingOccurrences(of: "\n", with: "⏎")
    }

    static func report(_ name: String, _ view: FakeSharedView, _ run: Run, since mark: Mark) {
        print("""
            shared view \(name): field "\(shown(view.field.text))", DEL \(view.fieldDeletes); \
            terminal "\(shown(view.line))"; detected at key \(run.detectedAt.map(String.init) ?? "-"), \
            erasing from key \(run.erasingAt.map(String.init) ?? "-"); after the click: \
            insertText \(view.inserts - mark.inserts), selectedRange \(view.selections - mark.selections), \
            reads \(view.reads - mark.reads) over \(run.keys - mark.keys) keys, most per key \(run.most)
            """)
    }

    /// The editor's line after the click: a sentence, Return (a new line in an editor; in
    /// the Claude app's chat input, sending the message), a second sentence.
    static let fieldKeys = "hoom nay tooi ddi hocj vui ver ↩camr own banj "
    static let fieldAnswer = "hôm nay tôi đi học vui vẻ \ncảm ơn bạn "
    /// The field before the click: an empty chat input, an editor with text before the caret.
    static let fieldStarts = ["", "Xin chào. "]

    // MARK: Terminal, then the field

    @Test("a: xterm.js after Return, then a click to the editor: DEL reaches the editor in every replacement",
          arguments: fieldStarts)
    func xtermAfterReturnThenField(start: String) {
        let view = FakeSharedView(terminal: .xterm(FakeXtermPage(scripted: XtermPageTests.scripted)),
                                  field: LateDocument(start))
        var run = Run()
        Self.type(RangeIgnoreTests.t4Line + "↩", on: view, run: &run)
        #expect(run.composer.eraseMode == .inKey)
        let mark = Self.click(to: .field, on: view, run: &run)
        withKnownIssue("D43 keeps the verdict for the activation; Chromium tells the input method of no click") {
            Self.type(Self.fieldKeys, on: view, run: &run)
            #expect(view.field.text == start + Self.fieldAnswer)
            #expect(view.fieldDeletes == 0)
        }
        Self.report("a", view, run, since: mark)
        // What comes out: every fix goes in at the caret as DEL characters and the new
        // text, the letters it was meant to replace left before them.
        #expect(view.field.text == start + "ho\u{7F}ôm nay to\u{7F}ôi d\u{7F}đi hoc\u{7F}\u{7F}ọc vui ve\u{7F}ẻ \n"
                + "cam\u{7F}\u{7F}ảm o\u{7F}ơn ban\u{7F}\u{7F}ạn ")
        #expect(view.fieldDeletes == 11)
        // N3 holds: no selectedRange, no read, at most one insertText per key.
        #expect(view.selections == mark.selections)
        #expect(view.reads == mark.reads)
        #expect(run.most.inserts <= 1)
    }

    @Test("b: xterm.js told apart, no Return yet, then the editor: right until a Return there, DEL after it",
          arguments: fieldStarts)
    func xtermBeforeReturnThenField(start: String) {
        let view = FakeSharedView(terminal: .xterm(FakeXtermPage(scripted: XtermPageTests.scripted)),
                                  field: LateDocument(start))
        var run = Run()
        Self.type(RangeIgnoreTests.t4Line, on: view, run: &run)
        #expect(run.composer.detector.send == .inKey)
        #expect(run.composer.eraseMode == .off)
        let mark = Self.click(to: .field, on: view, run: &run)
        withKnownIssue("the editor's Return starts sending DEL (InPlaceComposer.handle, endsLine)") {
            Self.type(Self.fieldKeys, on: view, run: &run)
            #expect(view.field.text == start + Self.fieldAnswer)
            #expect(view.fieldDeletes == 0)
        }
        Self.report("b", view, run, since: mark)
        #expect(view.field.text == start + "hôm nay tôi đi học vui vẻ \ncam\u{7F}\u{7F}ảm o\u{7F}ơn ban\u{7F}\u{7F}ạn ")
        #expect(view.fieldDeletes == 5)
        // The Return typed in the editor (the 32nd key after the click) starts the erase mode.
        #expect(run.erasingAt == mark.keys + 31)
        // Before it, one selectedRange per replacing key (5), as in any field; none after.
        #expect(view.selections - mark.selections == 5)
        #expect(view.reads == mark.reads)
        #expect(run.most.inserts <= 1)
    }

    @Test("c (hypothetical, no such app known): a Ghostty-like field, then the editor: DEL after every replacing key")
    func ghosttyLikeThenField() {
        let view = FakeSharedView(terminal: .ghostty(FakeGhostty()))
        var run = Run()
        Self.type(RangeIgnoreTests.t4Line, on: view, run: &run)
        #expect(run.composer.eraseMode == .afterKey)
        let mark = Self.click(to: .field, on: view, run: &run)
        withKnownIssue("D43 keeps the verdict for the activation") {
            Self.type(Self.fieldKeys, on: view, run: &run)
            #expect(view.field.text == Self.fieldAnswer)
            #expect(view.fieldDeletes == 0)
        }
        Self.report("c", view, run, since: mark)
        // The key goes in, then the fix: DEL for the word shown and the key, then the word.
        #expect(view.field.text == "hoo\u{7F}\u{7F}ôm nay too\u{7F}\u{7F}ôi dd\u{7F}\u{7F}đi hocj\u{7F}\u{7F}\u{7F}ọc "
                + "vui ver\u{7F}\u{7F}ẻ \ncamr\u{7F}\u{7F}\u{7F}ảm ow\u{7F}\u{7F}ơn banj\u{7F}\u{7F}\u{7F}ạn ")
        #expect(view.fieldDeletes == 19)
        #expect(view.selections == mark.selections)
        #expect(view.reads == mark.reads)
        #expect(run.most.inserts <= 1)  // the deferred text counted as the key's one call
    }

    // MARK: The field, then the terminal

    /// The terminal after the click: the t4 line, Return, the t4 line again, Return, a
    /// last line (`XtermPageTests.waitsForReturn` types the same in a new activation).
    static let terminalKeys = RangeIgnoreTests.t4Line + "↩" + RangeIgnoreTests.t4Line + "↩toois vieetj "
    /// What a new activation gives with those keys (`waitsForReturn`): told apart at key
    /// 39 of the first line, in place until its Return, right from the second line.
    static let terminalAnswer = "toôois vieetj dđdi hocj nhaàf nguưwoơwiờif hoa windows "
        + "tối việt đi học nhà người hò windows tối việt "

    @Test("d: the editor, then a click to xterm.js: told apart two lines late, never sending DEL in these keys")
    func fieldThenXterm() {
        let view = FakeSharedView(terminal: .xterm(FakeXtermPage(scripted: XtermPageTests.scripted)),
                                  focus: .field)
        var run = Run()
        Self.type("hoom nay tooi ddi hocj vui ver ", on: view, run: &run)
        #expect(view.field.text == "hôm nay tôi đi học vui vẻ ")
        let mark = Self.click(to: .terminal, on: view, run: &run)
        withKnownIssue("the composer keeps the editor's caret and D20 state over a click it never sees") {
            Self.type(Self.terminalKeys, on: view, run: &run)
            #expect(run.detectedAt == mark.keys + 39)
            #expect(view.line == Self.terminalAnswer)
        }
        Self.report("d", view, run, since: mark)
        // Told apart at key 113 after the click (the third line), after the last Return:
        // every line is replaced in place, as before D43.
        #expect(run.detectedAt == mark.keys + 113)
        #expect(run.erasingAt == nil)
        #expect(view.line == "tooiís vieêetj dđdi hocọcj nhaf nguưwowif hoa windows "
                + "toois vieêetj dđdi hocọcj nhaf nguưwowif hoaà windows toôois vieêetệtj ")
        #expect(run.most.inserts <= 1)
        #expect(run.most.selections <= 1)
        #expect(run.most.reads <= 1)
    }

    @Test("d, control: the same keys with the click taken as a reset are told apart as in a new activation")
    func fieldThenXtermClickSeen() {
        // As `DauInputController` handles a mouse down it is given (an NSTextView app);
        // Chromium gives none. The difference with `fieldThenXterm` is the composer's own
        // state (CursorTracker, what precedes the cursor), not the detector.
        let view = FakeSharedView(terminal: .xterm(FakeXtermPage(scripted: XtermPageTests.scripted)),
                                  focus: .field)
        var run = Run()
        Self.type("hoom nay tooi ddi hocj vui ver ", on: view, run: &run)
        let mark = Self.click(to: .terminal, on: view, run: &run)
        run.composer.reset(engine: &run.engine)
        run.composer.noteEvent(at: run.now)
        Self.type(Self.terminalKeys, on: view, run: &run)
        Self.report("d, click seen", view, run, since: mark)
        #expect(run.detectedAt == mark.keys + 39)
        #expect(view.line == Self.terminalAnswer)
        #expect(run.most.inserts <= 1)
    }

    @Test("d (hypothetical): the editor, then a Ghostty-like field: its answers of 1–2 make it 'in the key', which Ghostty drops")
    func fieldThenGhosttyLike() {
        let view = FakeSharedView(terminal: .ghostty(FakeGhostty()), focus: .field)
        var run = Run()
        Self.type("hoom nay tooi ddi hocj vui ver ", on: view, run: &run)
        let mark = Self.click(to: .terminal, on: view, run: &run)
        withKnownIssue("the editor's small answers count as xterm.js's (RangeIgnoreDetector, answers 1…2)") {
            Self.type(Self.terminalKeys, on: view, run: &run)
            #expect(run.composer.detector.send == .afterKey)
        }
        Self.report("d, Ghostty-like", view, run, since: mark)
        #expect(run.composer.detector.send == .inKey)
        #expect(run.detectedAt == mark.keys + 25)
        // The fixes in the key are dropped: the last line keeps no mark ("toi viet").
        #expect(view.line.hasSuffix("toi viet "))
    }
}
