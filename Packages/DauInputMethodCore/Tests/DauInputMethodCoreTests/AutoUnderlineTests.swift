import Foundation
import DauEngine
import DauShared
@testable import DauInputMethodCore
import Testing

/// A text field seen through `IMKTextInput`, in either mode. It keeps the text Dấu sent
/// and records every call; `selectedRange` and the read answer at once, from that text, from
/// an earlier state of it, or with a scripted answer.
private final class RecordingField: InPlaceClient, MarkedTextClient {
    enum Call: Equatable {
        case selectedRange
        case read(NSRange)
        case insert(String, NSRange?)
        case setMarked(String)
    }

    enum Answer {
        /// The caret after every edit received.
        case caret
        /// The caret and text as they were `n` edits ago.
        case editsBehind(Int)
        /// Always this caret.
        case fixed(Int)
        /// One more than the last answer at every ask, from `start`.
        case growing(from: Int)
        /// These carets in turn, the last one after them (answers from a perf log).
        case script([Int])
    }

    enum ReadAnswer {
        /// The text received.
        case text
        /// The unit right before the caret, whatever range is asked.
        case unitBeforeCaret
        /// The first unit of the text, whatever range is asked.
        case firstUnit
    }

    var calls: [Call] = []
    var answer = Answer.caret
    var readAnswer = ReadAnswer.text
    private var states: [(text: [UInt16], caret: Int)]
    private var asks = 0

    /// `text`: already in the field, the caret after it.
    init(_ text: String = "") {
        states = [(Array(text.utf16), text.utf16.count)]
    }

    private var text: [UInt16] { states.last!.text }
    private var caret: Int { states.last!.caret }

    func selectedRange() -> NSRange {
        calls.append(.selectedRange)
        asks += 1
        switch answer {
        case .caret: return NSRange(location: caret, length: 0)
        case .editsBehind(let n): return NSRange(location: state(behind: n).caret, length: 0)
        case .fixed(let location): return NSRange(location: location, length: 0)
        case .growing(let start): return NSRange(location: start + asks - 1, length: 0)
        case .script(let carets): return NSRange(location: carets[min(asks, carets.count) - 1], length: 0)
        }
    }

    func text(in range: NSRange) -> String? {
        calls.append(.read(range))
        switch readAnswer {
        case .unitBeforeCaret:
            return caret > 0 ? String(decoding: [text[caret - 1]], as: UTF16.self) : ""
        case .firstUnit:
            return text.first.map { String(decoding: [$0], as: UTF16.self) } ?? ""
        case .text:
            let source: [UInt16]
            if case .editsBehind(let n) = answer { source = state(behind: n).text } else { source = text }
            guard range.location >= 0, range.location + range.length <= source.count else { return nil }
            return String(decoding: source[range.location..<(range.location + range.length)], as: UTF16.self)
        }
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        let atCaret = replacementRange.location == NSNotFound
        calls.append(.insert(string, atCaret ? nil : replacementRange))
        let range = atCaret ? NSRange(location: caret, length: 0) : replacementRange
        guard range.location >= 0, range.location + range.length <= text.count else { return }
        var next = text
        next.replaceSubrange(range.location..<(range.location + range.length), with: Array(string.utf16))
        states.append((next, range.location + string.utf16.count))
    }

    func setMarkedText(_ text: String, selectionRange: NSRange, replacementRange: NSRange) {
        calls.append(.setMarked(text))
    }

    func pause(_ seconds: TimeInterval) {}
    var waitClock: TimeInterval { 0 }

    private func state(behind n: Int) -> (text: [UInt16], caret: Int) {
        states[max(0, states.count - 1 - n)]
    }

    var selectedRangeCount: Int { calls.filter { $0 == .selectedRange }.count }
    var readCount: Int { calls.filter { if case .read = $0 { true } else { false } }.count }
}

/// Keys through the two composers as the input method's controller routes them (D13).
private struct Controller {
    var engine: VietEngine
    var inPlace = InPlaceComposer()
    var composer = MarkedComposer()
    var auto = AutoUnderline()
    let field: RecordingField
    var changes: [AutoUnderline.Change] = []
    /// Whether each key went through underline mode.
    var underlined: [Bool] = []
    /// What the detector did on each in-place key, and the key's kind.
    var hidden: [HiddenTextKey] = []
    var kinds: [PerfLog.Kind] = []
    /// Underline-mode keys that asked `selectedRange` (N3 "Ngoại lệ ô giấu chữ").
    var commitAsks = 0
    /// Seconds between keys; under `InPlaceComposer.settleInterval` is a burst.
    var interval: TimeInterval = 0.2
    private var now: TimeInterval = 0

    init(rule: AutoUnderline.Rule = .detect, addMarks: Bool = true, text: String = "") {
        field = RecordingField(text)
        engine = VietEngine(options: DauSettings.defaults.engineOptions)
        inPlace.addMarksEnabled = addMarks
        setRule(rule)
    }

    mutating func setRule(_ rule: AutoUnderline.Rule) {
        if let change = auto.setRule(rule) { switchMode(change) }
        inPlace.hiddenText.isOn = auto.detects
    }

    mutating func key(_ route: KeyRoute) {
        now += interval
        underlined.append(auto.underlines)
        if auto.underlines {
            var check = auto
            var asked = false
            let askedBefore = field.calls.count
            let outcome = composer.handle(route, engine: &engine, client: field) {
                asked = check.beforeWordCommit(client: field)
            }
            auto = check
            if asked {
                commitAsks += 1
                // Asked before the commit, never after it.
                #expect(field.calls[askedBefore] == .selectedRange)
            }
            if let change = auto.afterMarkedKey(outcome) { switchMode(change) }
        } else {
            let outcome = inPlace.handle(route, time: now, engine: &engine, client: field)
            hidden.append(outcome.hiddenText)
            kinds.append(outcome.kind)
            if let change = auto.afterInPlaceKey(detector: inPlace.hiddenText, wordOpen: engine.isComposing) {
                switchMode(change)
            }
        }
    }

    mutating func type(_ keys: String) {
        for c in keys.unicodeScalars {
            key(c == "⏎" ? .endWord : .character(c))
        }
    }

    private mutating func switchMode(_ change: AutoUnderline.Change) {
        changes.append(change)
        inPlace.hiddenText.forget()
        inPlace.hiddenText.isOn = auto.detects
        inPlace.reset(engine: &engine)
    }

    var sightings: Int { hidden.filter(\.sighted).count }
}

private let sentence = "Hoom nay minhf hojc tieengs Vieetj voiws banj, buooir hojc online raats vui. "

@Suite("Hidden-text field: auto underline (D13 \"Ô giấu chữ\", N3)")
struct AutoUnderlineTests {
    @Test("Google Docs in Chrome when the first answer is already (1, 0) (not at the start of the document), the unit before the caret shown: found in the first word, underline from the second")
    func docsWithFollowedCaret() {
        var c = Controller()
        c.field.answer = .fixed(1)
        c.field.readAnswer = .unitBeforeCaret
        c.type("Hoom ")
        #expect(c.changes == [.on])
        #expect(c.sightings == 2)
        // The second sighting is the one extra ask at the space ending the word.
        #expect(c.hidden.last?.asked == true)
        #expect(c.hidden.contains { $0.read } == false)
        c.type("nay ")
        #expect(c.underlined.suffix(4) == [true, true, true, true])
        #expect(c.field.calls.suffix(4).contains(.setMarked("na")))
    }

    @Test("without a followed caret, a sighting needs the unit before the answer to be the word's last: Chrome's is, Safari's (the first of the document) is not")
    func docsWithoutFollowedCaret() {
        var chrome = Controller(addMarks: false)
        chrome.field.answer = .fixed(1)
        chrome.field.readAnswer = .unitBeforeCaret
        chrome.type("Hoom ")
        #expect(chrome.changes == [.on])
        #expect(chrome.hidden.contains { $0.read && $0.sighted })

        var safari = Controller(addMarks: false)
        safari.field.answer = .fixed(1)
        safari.field.readAnswer = .firstUnit
        safari.type("Hoom ")
        #expect(safari.changes.isEmpty)
        #expect(safari.sightings == 0)
        // No sighting: no ask at the space.
        #expect(safari.hidden.last?.asked == false)
    }

    @Test("Google Docs in Safari answers (1, 0) and reads the document's first unit: the first word is proved late (D11), \"minhf\" is a sighting that ends in a mismatch, its space the second; underline from \"hojc\"")
    func docsSafari() {
        // A document starts with a unit that is not a letter (the caret is at 1 with nothing
        // typed); Safari's read before 1 gives it, whatever the caret.
        var c = Controller(text: "\n")
        c.field.answer = .fixed(1)
        c.field.readAnswer = .firstUnit
        c.type("Hoom nay ")
        #expect(c.kinds.contains(.late))
        #expect(c.sightings == 0)
        c.type("minhf")
        #expect(c.kinds.last == .mismatch)
        #expect(c.sightings == 1)
        c.type(" ")
        #expect(c.hidden.last?.asked == true)
        #expect(c.changes == [.on])
        c.type("hojc ")
        #expect(c.underlined.suffix(5).allSatisfy { $0 })
    }

    @Test("Google Docs in a new document in Chrome: the first answer is (0, 0), so the first word's (1, 0) is proved late as at the start of any document (D11); the first sighting is \"minhf\", underline from \"hojc\"")
    func docsChromeNewDocument() {
        var c = Controller()
        c.field.answer = .script([0, 1, 3, 3])
        c.field.readAnswer = .firstUnit
        c.type("Hoom nay ")
        #expect(c.kinds.contains(.late))
        #expect(c.sightings == 0)
        c.type("minhf ")
        #expect(c.sightings == 2)
        #expect(c.changes == [.on])
    }

    @Test("two sightings in one word (Vieetj) switch at the end of that word, not inside it")
    func twoSightingsInOneWord() {
        var c = Controller(addMarks: false)
        c.field.answer = .fixed(1)
        c.field.readAnswer = .unitBeforeCaret
        c.type("Vieetj")
        #expect(c.sightings == 2)
        #expect(c.changes.isEmpty)
        #expect(c.underlined.allSatisfy { !$0 })
        c.type(" ")
        #expect(c.changes == [.on])
        // Found already: the space asks nothing more.
        #expect(c.hidden.last?.asked == false)
    }

    @Test("an answer inside the word that D11 proves late (the start of a document, keys in a burst) is no sighting and costs no call")
    func lateAnswerAtDocumentStart() {
        var on = Controller()
        on.interval = 0.005
        on.field.answer = .editsBehind(1)
        on.type(sentence)
        var off = Controller(rule: .noUnderline)
        off.interval = 0.005
        off.field.answer = .editsBehind(1)
        off.type(sentence)
        // The late app shows: answers inside the word were replaced at the followed caret.
        #expect(on.kinds.contains(.late))
        #expect(on.sightings == 0)
        #expect(on.changes.isEmpty)
        #expect(on.field.calls == off.field.calls)
    }

    @Test("an app that answers the caret: no sighting and not one extra call")
    func normalAppNoExtraCalls() {
        var on = Controller()
        on.type(sentence)
        var off = Controller(rule: .noUnderline)
        off.type(sentence)
        #expect(on.sightings == 0)
        #expect(on.changes.isEmpty)
        #expect(on.field.calls == off.field.calls)
        #expect(on.hidden.allSatisfy { $0 == HiddenTextKey() })
    }

    @Test("found by mistake: the caret grows by exactly the units committed two commits in a row, back to in place")
    func returnsWhenCaretFollowsCommits() {
        var c = Controller()
        c.field.answer = .fixed(1)
        c.field.readAnswer = .unitBeforeCaret
        c.type("Hoom ")
        #expect(c.changes == [.on])
        c.field.answer = .caret
        c.field.readAnswer = .text
        // First commit sets the baseline, the next two grow by exactly what was committed.
        c.type("nay minh hoc ")
        #expect(c.changes == [.on, .off(.caretFollowsCommits)])
        #expect(c.commitAsks == 3)
        // In place again, detection on again.
        c.type("tieengs ")
        #expect(c.underlined.suffix(8).allSatisfy { !$0 })
        #expect(c.inPlace.hiddenText.isOn)
    }

    @Test("Google Docs once underlined answers a small caret growing about one per word: no return, and asks stop after 8 commits")
    func docsAfterUnderlineStays() {
        var c = Controller()
        c.field.answer = .fixed(1)
        c.field.readAnswer = .unitBeforeCaret
        c.type("Hoom ")
        c.field.answer = .growing(from: 4)
        let asksBefore = c.field.selectedRangeCount
        c.type("nay minhf hojc tieengs Vieetj voiws banj buooir hojc online raats vui ")
        #expect(c.changes == [.on])
        #expect(c.commitAsks == AutoUnderline.checkedCommits)
        #expect(c.field.selectedRangeCount - asksBefore == AutoUnderline.checkedCommits)
        #expect(!c.auto.checksCommits)
    }

    @Test("after 8 commits the caret is not asked any more, even one that would follow the commits")
    func noCheckAfterEightCommits() {
        var c = Controller()
        c.field.answer = .fixed(1)
        c.field.readAnswer = .unitBeforeCaret
        c.type("Hoom ")
        c.type("nay minhf hojc tieengs Vieetj voiws banj buooir ")
        #expect(c.commitAsks == AutoUnderline.checkedCommits)
        c.field.answer = .caret
        let asksBefore = c.field.selectedRangeCount
        c.type("hojc online raats vui ")
        #expect(c.field.selectedRangeCount == asksBefore)
        #expect(c.changes == [.on])
        #expect(c.auto.underlines)
    }

    @Test("a key left to the app between commits starts the count over")
    func keyLeftToAppBreaksTheCount() {
        var c = Controller()
        c.field.answer = .fixed(1)
        c.field.readAnswer = .unitBeforeCaret
        c.type("Hoom ")
        c.field.answer = .caret
        c.field.readAnswer = .text
        // Return goes to the app after its commit: the count starts over at the next commit.
        c.type("nay minh⏎hoc ")
        #expect(c.changes == [.on])
        c.type("tap ")
        #expect(c.changes == [.on])
        c.type("vui ")
        #expect(c.changes == [.on, .off(.caretFollowsCommits)])
    }

    @Test("an Underline rule always underlines and never asks; No underline turns detection off; a rule ends auto underline")
    func rulePrecedence() {
        var underline = Controller(rule: .underline)
        underline.field.answer = .caret
        underline.type("Hoom nay minh hoc ")
        #expect(underline.underlined.allSatisfy { $0 })
        #expect(underline.field.selectedRangeCount == 0)
        #expect(underline.changes.isEmpty)

        var noUnderline = Controller(rule: .noUnderline)
        noUnderline.field.answer = .fixed(1)
        noUnderline.field.readAnswer = .unitBeforeCaret
        noUnderline.type(sentence)
        #expect(noUnderline.changes.isEmpty)
        #expect(noUnderline.sightings == 0)
        #expect(noUnderline.underlined.allSatisfy { !$0 })

        var auto = Controller()
        auto.field.answer = .fixed(1)
        auto.field.readAnswer = .unitBeforeCaret
        auto.type("Hoom ")
        #expect(auto.auto.underlines)
        auto.setRule(.noUnderline)
        #expect(auto.changes == [.on, .off(.rule)])
        #expect(!auto.auto.underlines)
        #expect(!auto.inPlace.hiddenText.isOn)
        auto.setRule(.detect)
        #expect(auto.inPlace.hiddenText.isOn)
    }

    @Test("an Underline rule found while detecting: nothing is detected under it")
    func underlineRuleNeverDetects() {
        var rule = AutoUnderline()
        _ = rule.setRule(.underline)
        var detector = HiddenTextDetector()
        detector.isOn = true
        detector.sight(inWordOf: 2)
        detector.sight(inWordOf: 2)
        #expect(rule.afterInPlaceKey(detector: detector, wordOpen: false) == nil)
        #expect(!rule.detects)
        #expect(!rule.checksCommits)
    }

    @Test("an answer lies inside the word only from 1 up to the word's length, with no selection")
    func liesInside() {
        #expect(HiddenTextDetector.liesInside(NSRange(location: 1, length: 0), wordUnits: 2))
        #expect(!HiddenTextDetector.liesInside(NSRange(location: 0, length: 0), wordUnits: 2))
        #expect(!HiddenTextDetector.liesInside(NSRange(location: 2, length: 0), wordUnits: 2))
        #expect(!HiddenTextDetector.liesInside(NSRange(location: 1, length: 1), wordUnits: 2))
        #expect(!HiddenTextDetector.liesInside(NSRange(location: NSNotFound, length: 0), wordUnits: 2))
        #expect(!HiddenTextDetector.liesInside(NSRange(location: 1, length: 0), wordUnits: 1))
    }
}
