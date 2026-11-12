import Foundation
import DauEngine

/// The xterm.js test page of `scripts/selftest/typing/run.sh` (target `xterm`): xterm.js
/// 5.5.0 in Chrome, its "shell" a line editor in the page (DEL erases one code point,
/// other characters from U+0020 are appended, every `onData` chunk is kept). D43 (Ô bỏ
/// qua vùng thay chữ), docs/research/TerminalAndUnderline.md section 2.
///
/// Modelled from the code, three layers, each step citing it (xterm.js tag 5.5.0;
/// Chromium main of 12/11/2026):
///
/// 1. Chromium's `RenderWidgetHostViewCocoa` (content/app_shim_remote_cocoa/
///    render_widget_host_view_cocoa.mm), what the input method talks to:
///    - `insertText:replacementRange:` with a range sends `ImeCommitText(text, range)` to
///      the page at once; without a range while a key is handled it only collects the
///      text (`_textToBeInserted`), and then sets the cached caret to
///      `_markedRange.location + length` and inserts the text into the cached text at
///      `_markedRange.location`. `_markedRange` is an instance variable that only
///      `setMarkedText` changes, so in in-place mode (no marked text) it stays at
///      {0, 0}: the cache then says "caret at the length of the last text" and holds the
///      collected text at its start until the page reports a change.
///    - `selectedRange` and `attributedSubstringForProposedRange:` answer from that cache
///      (`_textSelectionRange`, `_availableText`), which the page updates only when its
///      selection or text changes (`setTextSelectionText:offset:range:`).
///    - `keyEvent:` after `interpretKeyEvents:`: more than one collected unit sends a
///      keydown with keyCode 229 (VKEY_PROCESSKEY) then `ImeCommitText` of that text;
///      if the key also produced edit commands (a key the input method let through:
///      Delete, Return), a fake keyup and the real keydown follow. Otherwise the real
///      keydown goes to the page, then a keypress (`kChar`) with the one collected unit.
/// 2. Blink (third_party/blink/renderer/core/exported/web_input_method_controller_impl.cc
///    `CommitText`, core/editing/ime/input_method_controller.cc):
///    - with a range: `ReplaceTextAndKeepSelection` selects the range, inserts, then puts
///      the old caret back, moved by the change only if it was at or after the end of the
///      range. A caret before the range stays where it was: the new text is then after
///      the caret. A range that starts past the text fails (`PlainTextRange::CreateRangeFor`
///      returns a null range); an empty textarea holds a placeholder `<br>`
///      (`TextControlElement::CreatePlaceholderBreakElement`), counted here as one
///      position: the first range replacement on the page reached the shell (second
///      typing round, "toôoiís"), so a range on the empty textarea is taken.
///    - without a range: `InsertTextAndMoveCaret` inserts at the caret, caret after.
///    - every insertion fires an `input` event (inputType insertText, `composed` true,
///      core/events/input_event.cc) with the inserted text as `data`.
///    - a keydown whose default is prevented suppresses its keypress; a keypress whose
///      default is not prevented inserts its character at the caret.
/// 3. xterm.js 5.5.0 (src/browser/Terminal.ts, src/browser/input/CompositionHelper.ts,
///    src/common/input/Keyboard.ts):
///    - `_keyDown`: `CompositionHelper.keydown` takes keyCode 229 when not composing:
///      `_handleAnyTextareaChanges` keeps the textarea's value and, in a `setTimeout(0)`,
///      sends `newValue.replace(oldValue, '')` if the value grew, one DEL if it shrank,
///      the whole new value if it changed at the same length. Other keys:
///      `evaluateKeyboardEvent`; lower-case letters, digits and punctuation (keyCode 48
///      or more, one character) are sent and the keydown cancelled; A–Z and space have
///      no `result.key` here and go on to `_keyPress`; Delete sends DEL; Return sends CR
///      and empties the textarea (`this.textarea!.value = ''`); Tab sends HT.
///    - `_keyPress` sends the character and does not cancel the event (`cancel` without
///      `force` does nothing while `cancelEvents` is false, the default), so the
///      character also goes into the textarea.
///    - `_inputEvent` sends `data` only when `!ev.composed || !this._keyDownSeen`, i.e.
///      for text that comes between a keyup and the next keydown. `_keyDownSeen` is set
///      in `_keyDown`, cleared in `_keyUp`.
///    - the textarea is emptied only on Return, ⌃C and blur.
///
/// Order: the page handles what Chromium sends in order (one `WidgetInputHandler` pipe);
/// assumed, not read: a `setTimeout(0)` of a key runs after every event Chromium sent for
/// that key (Blink runs input before timers), and the keyup comes before the next key
/// (keys 120 ms apart in the typing runs).
final class FakeXtermPage: InPlaceClient {
    // MARK: Page (Blink textarea, xterm.js, line editor)

    /// xterm.js's hidden textarea (UTF-16, as JavaScript strings) and its caret.
    private(set) var value: [UInt16] = []
    private(set) var caret = 0
    /// Every `onData` chunk xterm.js sent to the "shell".
    private(set) var chunks: [String] = []
    /// The page's line editor (code points: `for (var c of d)`, `line.pop()`).
    private(set) var line: [Unicode.Scalar] = []
    private var keyDownSeen = false
    private var pendingTimer: [UInt16]?

    // MARK: Chromium's cache

    private var cachedCaret = 0
    private var cachedText: [UInt16] = []
    /// What the page last reported (it reports only changes).
    private var reported: (value: [UInt16], caret: Int) = ([], 0)
    /// `_markedRange.location`: {0, 0} in a new view (an Objective-C instance variable),
    /// NSNotFound once any input method has ended marked text with an empty
    /// `setMarkedText` in that view; nothing else changes it.
    let markedLocation: Int

    /// `scripted`: `selectedRange` answers these locations in turn instead of the cache
    /// (the probe of 11/11/2026 measured 0–2 on the page, not their order; the cache's
    /// own answers depend on `_markedRange`, which the earlier history of the view sets).
    /// `value`, `caret`, `line`: the textarea and the line as they are at the start.
    init(markedLocation: Int = 0, scripted: [Int] = [], value: String = "", caret: Int? = nil, line: String = "") {
        self.markedLocation = markedLocation
        self.scripted = scripted
        self.value = Array(value.utf16)
        self.caret = caret ?? self.value.count
        self.line = Array(line.unicodeScalars)
        report()
    }
    private let scripted: [Int]

    /// While `keyEvent:` runs `interpretKeyEvents:`.
    private var handlingKey = false
    private var collected: [UInt16] = []

    // MARK: Calls counted (N3)

    private(set) var selectedRangeCalls = 0
    private(set) var reads = 0
    private(set) var inserts = 0

    var lineText: String { String(String.UnicodeScalarView(line)) }
    var valueText: String { String(decoding: value, as: UTF16.self) }

    // MARK: InPlaceClient

    func selectedRange() -> NSRange {
        selectedRangeCalls += 1
        let answer = scripted.isEmpty ? cachedCaret : scripted[(selectedRangeCalls - 1) % scripted.count]
        return NSRange(location: answer, length: 0)
    }

    func text(in range: NSRange) -> String? {
        reads += 1
        // `attributedSubstringForProposedRange:`: the intersection with the cached text.
        guard range.location != NSNotFound, range.length > 0 else { return nil }
        let lower = max(range.location, 0), upper = min(range.location + range.length, cachedText.count)
        guard lower < upper else { return nil }
        return String(decoding: cachedText[lower..<upper], as: UTF16.self)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        inserts += 1
        let units = Array(string.utf16)
        if replacementRange.location == NSNotFound {
            if handlingKey {
                collected += units
            } else {
                commitAtCaret(units)
            }
            // The cache "hack" of `insertText:replacementRange:` (crbug.com/710101).
            // `int insertEndpoint = _markedRange.location + [imText length]`: NSUInteger
            // arithmetic cut to a 32-bit int (from NSNotFound: the length minus one).
            let end = UInt(bitPattern: markedLocation) &+ UInt(units.count)
            cachedCaret = Int(UInt32(truncatingIfNeeded: end))
            if markedLocation >= 0, markedLocation <= cachedText.count {
                cachedText.insert(contentsOf: units, at: markedLocation)
            }
        } else {
            commit(units, replacing: replacementRange)
        }
    }

    // MARK: Keys

    /// One key: `handle` is the input method's `handleEvent` (returns consumed), then
    /// AppKit's own handling of a key it did not consume, then what Chromium sends the
    /// page, the page's timers and the keyup.
    func key(_ route: KeyRoute, isReturn: Bool = true, handle: () -> Bool) {
        collected = []
        handlingKey = true
        let consumed = handle()
        var editCommands = false
        if !consumed {
            switch route {
            case .character(let c): insertText(String(Character(c)), replacementRange: NSRange(location: NSNotFound, length: 0))
            case .backspace, .endWord: editCommands = true  // deleteBackward:, insertNewline:/insertTab:
            case .ignore: break
            }
        }
        handlingKey = false
        if collected.count > 1 {
            keyDown229()
            commitAtCaret(collected)
            if editCommands {
                keyDownSeen = false  // the fake keyup
                _ = realKeyDown(route, isReturn: isReturn)
            }
        } else {
            let cancelled = realKeyDown(route, isReturn: isReturn)
            if !cancelled, collected.count == 1 { keyPress(collected) }
        }
        runTimer()
        keyDownSeen = false  // keyup
    }

    // MARK: Page side

    private func send(_ data: [UInt16]) {
        let string = String(decoding: data, as: UTF16.self)
        chunks.append(string)
        for scalar in string.unicodeScalars {
            if scalar == "\u{7F}" {
                _ = line.popLast()
            } else if scalar.value >= 0x20 {
                line.append(scalar)
            }
        }
    }

    /// `_inputEvent`.
    private func inputEvent(_ data: [UInt16]) {
        if !data.isEmpty, !keyDownSeen { send(data) }
    }

    /// `ReplaceTextAndKeepSelection`.
    private func commit(_ units: [UInt16], replacing range: NSRange) {
        let positions = value.isEmpty ? 1 : value.count
        guard range.location >= 0, range.location <= positions, range.length >= 0 else { return }
        let start = min(range.location, value.count)
        let end = min(range.location + range.length, value.count)
        let old = caret
        value.replaceSubrange(start..<end, with: units)
        inputEvent(units)
        let rangeEnd = range.location + range.length
        let kept = old >= rangeEnd ? old + units.count - range.length : old
        caret = kept <= value.count ? kept : start + units.count
        report()
    }

    /// `InsertTextAndMoveCaret`.
    private func commitAtCaret(_ units: [UInt16]) {
        guard !units.isEmpty else { return }
        value.insert(contentsOf: units, at: caret)
        caret += units.count
        inputEvent(units)
        report()
    }

    private func report() {
        guard reported.value != value || reported.caret != caret else { return }
        reported = (value, caret)
        cachedText = value
        cachedCaret = caret
    }

    /// `_keyDown` with keyCode 229: `CompositionHelper._handleAnyTextareaChanges`.
    private func keyDown229() {
        keyDownSeen = true
        pendingTimer = value
    }

    private func runTimer() {
        guard let old = pendingTimer else { return }
        pendingTimer = nil
        let new = value
        if new.count > old.count {
            send(Self.replaceFirst(old, in: new))
        } else if new.count < old.count {
            send([0x7F])
        } else if new != old {
            send(new)
        }
    }

    /// JavaScript's `newValue.replace(oldValue, '')`: the first occurrence removed ("" is
    /// found at 0 and removes nothing).
    static func replaceFirst(_ old: [UInt16], in new: [UInt16]) -> [UInt16] {
        guard !old.isEmpty, old.count <= new.count else { return new }
        for i in 0...(new.count - old.count) where Array(new[i..<(i + old.count)]) == old {
            return Array(new[..<i]) + Array(new[(i + old.count)...])
        }
        return new
    }

    /// `_keyDown` for the real keydown; returns whether it was cancelled.
    private func realKeyDown(_ route: KeyRoute, isReturn: Bool) -> Bool {
        keyDownSeen = true
        switch route {
        case .character(let c):
            // `evaluateKeyboardEvent`: space (keyCode 32) has no key; A–Z go to keypress.
            if c == " " || ("A"..."Z").contains(c) { return false }
            send(Array(String(Character(c)).utf16))
            return true
        case .backspace:
            send([0x7F])
            return true
        case .endWord:
            if isReturn {
                value = []
                caret = 0
                report()
                send([0x0D])
            } else {
                send([0x09])
            }
            return true
        case .ignore:
            return true
        }
    }

    /// `_keyPress`, then the keypress's default action (not cancelled).
    private func keyPress(_ units: [UInt16]) {
        send(units)
        value.insert(contentsOf: units, at: caret)
        caret += units.count
        inputEvent(units)  // keyDownSeen: ignored
        report()
    }
}
