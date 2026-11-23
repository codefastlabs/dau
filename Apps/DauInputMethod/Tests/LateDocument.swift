import Foundation
import DauEngine
import DauShared
import Testing

/// An app that applies every edit in order (keys it types, `insertText` with absolute
/// ranges) but answers `selectedRange` and `attributedSubstring` from an earlier state
/// of its text: Chrome with a busy page (`docs/history/LogM6.md` step 1), and apps that
/// apply keys asynchronously when keys come in a burst (Chromium, Electron, Firefox;
/// `docs/Compatibility.md` 6.2). With `keyQueue`, WebKit instead: the input method's
/// calls overtake the keys it left to the app (see "WebKit's key queue" below).
///
/// Which earlier state: `lag` edits ago (set per key, so each word of a log can be
/// replayed exactly), or, with `clock` set, the latest state the app has reported by
/// then (`work`, `reportDelay`: the app applies one edit after the other).
///
/// Order: the app applies the input method's `insertText` after the keys sent before
/// it. Chromium source (main, read 09–10/11/2026): key events and `ImeCommitText` go
/// through the same `WidgetInputHandler` interface, and in the renderer both end in
/// `MainThreadEventQueue` (`WidgetInputHandlerImpl::RunOnMainThread`, `DispatchEvent`);
/// the compositor-thread hop of key events was not read. Firefox: the parent sends the
/// set-selection and insert-text events of a replacement to the content process after
/// the key events before them (`TextInputHandler.mm`, `InsertTextAsCommittingComposition`).
final class LateDocument: InPlaceClient {
    /// What the app answers from.
    enum Cache {
        /// The text and caret of the earlier state as they were (Firefox:
        /// `ContentCacheInParent` and `IMEInputHandler::mSelectedRange`, both updated
        /// only when the content process reports).
        case snapshot
        /// Chromium's browser-side cache (`render_widget_host_view_cocoa.mm`): the state
        /// the page reported last, plus every `insertText` with NSNotFound since (a key
        /// let through, the input method's own insertion at the caret), each written into
        /// `_availableText` at the caret the page reported (`_markedRange.location`), so
        /// later ones before earlier ones; `_textSelectionRange` is that caret plus the
        /// length of the latest one. `insertText` with a range is not written.
        case chromium
    }

    /// Where the caret goes when `insertText` replaces a range that ends before it.
    enum Replace {
        /// It stays after the text that follows, shifted by the change in length: Blink's
        /// `ReplaceTextAndKeepSelection` (Chrome text fields, contenteditable).
        case keepSelection
        /// It goes to the end of the inserted text: Blink's `EditContext::CommitText`
        /// (VS Code, whose editor uses the EditContext API by default, option
        /// `editor.editContext`), Firefox (selects the range, then inserts).
        case caretAfterText
    }

    struct State {
        var text: [UInt16]
        var cursor: Int
        /// Text inserted at the caret by this edit (`insertText` with NSNotFound).
        var atCaret: [UInt16]? = nil
        /// When the app has applied this edit and told the input method's side about it.
        var reportAt: TimeInterval = -.infinity
    }
    private(set) var states: [State]
    var cache = Cache.snapshot
    var replace = Replace.keepSelection
    /// Edits the answers are behind by (when `clock` is nil).
    var lag = 0
    /// Timed answers: the latest state reported at or before `clock`.
    var clock: TimeInterval?
    /// When the next edit reaches the app (timed answers).
    var sentAt: TimeInterval = 0
    /// Seconds the app takes to apply one edit, after the previous one (timed answers).
    var work: () -> TimeInterval = { 0 }
    var reportDelay: TimeInterval = 0
    private var lastApplied: TimeInterval = -.infinity
    /// For one key: answer with this text before the caret instead (a state no model
    /// above gives).
    var override: String?
    /// Calls during the current key (N3).
    var selections = 0, reads = 0, inserts = 0
    /// The text the latest read gave (nil: none).
    private(set) var lastRead: String?
    /// An `insertText` whose range is outside the real text (never expected).
    var badRanges = 0
    /// The largest number of edits an answer was behind (timed answers).
    private(set) var maxBehind = 0

    init(_ text: String = "") {
        let units = Array(text.utf16)
        states = [State(text: units, cursor: units.count)]
    }

    var text: String { String(decoding: states[states.count - 1].text, as: UTF16.self) }

    private var answer: State {
        if let override { let units = Array(override.utf16); return State(text: units, cursor: units.count) }
        let last = states.count - 1
        let index: Int
        if keyQueue {
            index = last   // WebKit answers from the page's own text
        } else if let clock {
            index = states.lastIndex { $0.reportAt <= clock } ?? 0
            maxBehind = max(maxBehind, last - index)
        } else {
            index = max(0, last - lag)
        }
        var state = states[index]
        if cache == .chromium, index < last {
            let caret = state.cursor
            var latest: [UInt16]?
            for later in states[(index + 1)...] {
                guard let units = later.atCaret, caret <= state.text.count else { continue }
                state.text.insert(contentsOf: units, at: caret)
                latest = units
            }
            if let latest { state.cursor = caret + latest.count }
        }
        return state
    }

    func selectedRange() -> NSRange {
        selections += 1
        waitForPage()
        catchUp()
        return NSRange(location: answer.cursor, length: 0)
    }

    func text(in range: NSRange) -> String? {
        reads += 1
        waitForPage()
        catchUp()
        let units = answer.text
        lastRead = nil
        guard range.location >= 0, range.length >= 0, range.location + range.length <= units.count else { return nil }
        lastRead = String(decoding: units[range.location..<(range.location + range.length)], as: UTF16.self)
        return String(decoding: units[range.location..<(range.location + range.length)], as: UTF16.self)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        inserts += 1
        catchUp()
        var state = states[states.count - 1]
        let range = replacementRange.location == NSNotFound
            ? NSRange(location: state.cursor, length: 0) : replacementRange
        guard range.location >= 0, range.location + range.length <= state.text.count else {
            badRanges += 1
            return
        }
        let units = Array(string.utf16)
        state.text.replaceSubrange(range.location..<(range.location + range.length), with: units)
        let end = range.location + range.length
        if replacementRange.location == NSNotFound || state.cursor < end || replace == .caretAfterText {
            state.cursor = range.location + units.count
        } else {
            // The caret was after the range (keys the input method had not seen applied
            // yet): it stays after them, shifted by the change in length. Chrome's texts
            // show this ("ạnn gửi", no stray "n" at the end of the text).
            state.cursor += units.count - range.length
        }
        state.atCaret = replacementRange.location == NSNotFound ? units : nil
        append(state)
    }

    private func append(_ state: State) {
        var state = state
        if clock != nil, !keyQueue {
            let applied = max(sentAt, lastApplied) + work()
            lastApplied = applied
            state.reportAt = applied + reportDelay
        }
        states.append(state)
    }

    /// An edit the app makes on its own (autocorrect, smart dashes): the new state.
    func appEdit(_ text: String) {
        let units = Array(text.utf16)
        append(State(text: units, cursor: units.count))
    }

    /// The caret moves without the input method being told (a click IMK does not report,
    /// the app itself): the new state.
    func moveCaret(to cursor: Int) {
        var state = states[states.count - 1]
        state.cursor = cursor
        state.atCaret = nil
        append(state)
    }

    // MARK: WebKit's key queue

    /// WebKit (Safari), from its source (main, read 18/11 and 22/11/2026;
    /// `docs/research/LateAnswerFixes.md` section 5.1): the view sends every key event it
    /// gets, key-down and key-up, whether the input method handled it or not, to
    /// `WebPageProxy::handleKeyboardEvent` (`WebViewImpl::keyDown`, `keyUp`), which puts it
    /// in `keyEventQueue`. The queue sends the page one event at a time; the next goes
    /// only when the page says it is done with the one before (`keyEventHandlingCompleted`).
    /// An event the input method did not handle carries its key to the page (the page
    /// types it); one it handled carries nothing, its text came through the input
    /// method's call. The input method's calls (`insertTextAsync`,
    /// `getSelectedRangeAsync`, `attributedSubstringForCharacterRangeAsync`) go to the
    /// page at once, not through that queue, and the page answers them from its own
    /// text, applying a `replacementRange` to the text it has then, the caret going to the
    /// end of the inserted text (`Replace.caretAfterText`).
    ///
    /// The event at the head of the queue was already sent: it reaches the page before
    /// any later call of the input method (both on the one connection to the page), so it
    /// is applied when sent. The events behind it wait until the page handles the head
    /// (`pageHandlesKeyEvent`). Key-ups are not modelled as events of their own: they
    /// only make the queue longer, which the test's schedule of `pageHandlesKeyEvent`
    /// stands for. On: set `keyQueue`, keep `lag` 0 and `cache` `.snapshot` (no cache: answers
    /// from the latest state). With `clock` nil the test hands events to the page
    /// (`pageHandlesKeyEvent`); with `clock` set the page is done with each event `work()`
    /// after it is free (`pageFree`), and the input method's waits (`pause`) move the clock.
    var keyQueue = false
    /// The key events in WebKit's queue, head first (sent, not handled yet). nil: an
    /// event the input method handled (no key for the page to type).
    private(set) var queuedKeys: [KeyRoute?] = []

    /// One key event reaches WebKit's queue, after the input method's `handle` returned
    /// (`handled`: it returned true). Sent to the page at once if the queue was empty.
    func keyEvent(_ route: KeyRoute, handled: Bool) {
        catchUp()
        queuedKeys.append(handled ? nil : route)
        guard queuedKeys.count == 1 else { return }
        send(at: clock)
    }

    /// Sends the event at the head of the queue at `time` (nil: untimed): its key, if
    /// any, is typed; with `clock` set, the page is done with it `work()` after it is
    /// free (`pageFree`).
    private func send(at time: TimeInterval?) {
        guard let head = queuedKeys.first else { return }
        if let key = head { applying(key) }
        headDoneAt = time.map { pageFree($0) + work() }
    }

    /// Timed queue (`clock` set): when the page, busy until then, can start on an event
    /// sent at a time (a page blocked by a script: the end of the block). Untimed: unused.
    var pageFree: (TimeInterval) -> TimeInterval = { $0 }
    /// Timed queue: when the page is done with the event at the head of the queue.
    private var headDoneAt: TimeInterval?
    private var inApply = false

    /// Timed queue: the page handles every event it is done with by `clock`, in order,
    /// each next one sent when the one before is done.
    private func catchUp() {
        guard keyQueue, !inApply, let clock else { return }
        while let done = headDoneAt, done <= clock {
            queuedKeys.removeFirst()
            headDoneAt = nil
            send(at: done)
        }
    }

    private func applying(_ key: KeyRoute) {
        inApply = true
        apply(key)
        inApply = false
    }

    /// Seconds the input method waited during the current key (`pause`, and WebKit's
    /// blocked answers).
    var paused: TimeInterval = 0
    /// Time that passed in the input method's waits (`InPlaceClient.waitClock`).
    private(set) var waitClock: TimeInterval = 0

    /// The input method waits (N3, "Ngoại lệ sau ⌫ chưa áp").
    /// - WebKit's queue (`keyQueue`): model time goes on and the page goes on handling
    ///   events; Safari answers the input method from the page, apart from its own
    ///   main thread.
    /// - The other models: the answers do not move. Chrome answers from a cache in the
    ///   browser process that is not updated while the input method blocks it (measured:
    ///   every wait in Chrome with a busy page runs out, `docs/research/LateAnswerFixes.md`
    ///   5.4); Firefox, whose cache
    ///   is in its parent process, is taken to do the same (not measured). The time still
    ///   counts for the next key (`paused`).
    func pause(_ seconds: TimeInterval) {
        paused += seconds
        waitClock += seconds
        if keyQueue, let clock { self.clock = clock + seconds }
    }

    /// WebKit's queue in time: `selectedRange` and the read are synchronous for the input
    /// method and answered by the page when it is free (`pageFree`), after the event it
    /// was sent last; the input method waits that long (measured: the first ask blocks
    /// until the page is free).
    private func waitForPage() {
        guard keyQueue, let clock else { return }
        let ready = pageFree(clock)
        guard ready > clock else { return }
        paused += ready - clock
        waitClock += ready - clock
        self.clock = ready
    }

    /// The page is done with the event at the head of the queue: the next one is sent
    /// (and its key, if any, typed). False when the queue is empty.
    @discardableResult
    func pageHandlesKeyEvent() -> Bool {
        guard !queuedKeys.isEmpty else { return false }
        queuedKeys.removeFirst()
        if let next = queuedKeys.first, let key = next { applying(key) }
        return true
    }

    /// The page is free: it handles every event in the queue.
    func pageIdle() {
        while pageHandlesKeyEvent() {}
    }

    /// What the app does with a key the input method left to it (WebKit's key queue:
    /// `keyEvent`).
    func typed(_ route: KeyRoute) {
        if keyQueue {
            keyEvent(route, handled: false)
            return
        }
        apply(route)
    }

    /// The app types a key the input method left to it, now.
    private func apply(_ route: KeyRoute) {
        switch route {
        case .character(let c):
            let n = inserts
            insertText(String(Character(c)), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            inserts = n
        case .backspace:
            var state = states[states.count - 1]
            guard state.cursor > 0 else { return }
            state.text.remove(at: state.cursor - 1)
            state.cursor -= 1
            state.atCaret = nil
            append(state)
        case .endWord:
            let n = inserts
            insertText("\n", replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            inserts = n
        case .ignore:
            break
        }
    }
}

/// Deterministic generator for the random sequences, lags and timings of the tests (SplitMix64).
struct SplitMix {
    var state: UInt64
    init(_ seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
    /// Uniform in [low, high].
    mutating func uniform(_ low: Double, _ high: Double) -> Double {
        low + (high - low) * Double(next() >> 11) / Double(1 << 53)
    }
}

/// Whether the app handles `route` itself after in-place mode handled it (`outcome`): the
/// harnesses type only such keys (⌫, Return, Tab, reset keys). A `.character` route is
/// always consumed in in-place mode (N3: the input method types every character itself);
/// one left to the app is recorded as an issue, not typed.
func leftToApp(_ route: KeyRoute, _ outcome: InPlaceComposer.Outcome,
               sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    guard !outcome.consumed else { return false }
    if case .character(let c) = route {
        Issue.record("N3: character \(String(Character(c)).debugDescription) left to the app in in-place mode",
                     sourceLocation: sourceLocation)
        return false
    }
    return true
}
