import Foundation
import DauEngine
import DauShared
import Testing

/// Keys → composer → `LateDocument` with WebKit's key queue (`LateDocument.keyQueue`).
/// Before each key the page handles a number of queued key events (`schedule`); at the
/// end it is free and handles the rest.
private struct WebKitSession {
    var engine: VietEngine
    var composer = InPlaceComposer()
    let doc: LateDocument
    var now: TimeInterval = 0
    var kinds: [PerfLog.Kind] = []
    /// Keys with more than one call of a kind (N3).
    var overCalls = 0
    /// Keys whose character the composer left unchanged (`pass`) without typing it at the
    /// caret (N3: one `insertText`).
    var badTyped = 0

    /// `passThrough`: the old behaviour, characters the engine leaves unchanged go to the
    /// app (`InPlaceComposer.passesCharactersThrough`).
    init(_ text: String = "", passThrough: Bool = false) {
        engine = VietEngine(options: DauSettings.defaults.engineOptions)
        doc = LateDocument(text)
        doc.keyQueue = true
        doc.replace = .caretAfterText
        #if DEBUG
        composer.passesCharactersThrough = passThrough
        #endif
    }

    /// One key `seconds` after the previous one; the page first handles `handled` events.
    mutating func key(_ route: KeyRoute, after seconds: TimeInterval, handled: Int) {
        var left = handled
        while left > 0, doc.pageHandlesKeyEvent() { left -= 1 }
        now += seconds
        doc.selections = 0; doc.reads = 0; doc.inserts = 0
        let outcome = composer.handle(route, time: now, engine: &engine, client: doc)
        if doc.selections > 1 || doc.reads > 1 || doc.inserts > 1 { overCalls += 1 }
        if outcome.kind == .pass, case .character = route, doc.inserts != 1 || !outcome.consumed {
            badTyped += 1
        }
        kinds.append(outcome.kind)
        doc.keyEvent(route, handled: outcome.consumed)
    }

    mutating func finish() { doc.pageIdle() }
}

/// How the page keeps up with the keys.
enum WebKitSchedule: CaseIterable, CustomStringConvertible {
    /// Keys sent in a burst (1–5 ms apart) to a free page: each event waits for the
    /// page's answer about the one before, so the queue holds one or two events.
    case burst
    /// A busy page at the pace of a person typing fast (40 ± 20 ms between keys): the
    /// page is stuck for 3 to 10 keys, then handles every queued event.
    case busy

    var description: String { self == .burst ? "burst" : "busy" }

    /// Seconds before each key and events the page handles before it.
    func plan(_ count: Int, seed: UInt64) -> [(TimeInterval, Int)] {
        var rng = SplitMix(seed &* 6_364_136_223_846_793_005 &+ 1)
        var plan: [(TimeInterval, Int)] = []
        var stuck = 0
        for _ in 0..<count {
            switch self {
            case .burst:
                plan.append((rng.uniform(0.001, 0.005), Int(rng.next() % 2)))
            case .busy:
                let gap = rng.uniform(0.02, 0.06)
                if stuck > 0 {
                    stuck -= 1
                    plan.append((gap, 0))
                } else {
                    stuck = 3 + Int(rng.next() % 8)
                    plan.append((gap, Int.max))
                }
            }
        }
        return plan
    }
}

@Suite("In-place mode in WebKit's key queue (Safari: the input method's calls overtake keys it leaves to the app)")
struct WebKitQueueTests {
    static let seeds = 40

    private static func run(_ keys: String, _ schedule: WebKitSchedule, seed: UInt64,
                            passThrough: Bool = false) -> WebKitSession {
        var s = WebKitSession(passThrough: passThrough)
        let keyRoutes = routes(keys)
        for (route, (gap, handled)) in zip(keyRoutes, schedule.plan(keyRoutes.count, seed: seed)) {
            s.key(route, after: gap, handled: handled)
        }
        s.finish()
        return s
    }

    /// The old behaviour reproduces the Safari runs (`docs/Compatibility.md` 5.1, busy
    /// page, keys at a person's fast pace: the text scrambled): a key let through waits
    /// in the queue while the replacement of the next key reaches the page first.
    @Test("keys left to the app (the old behaviour), page stuck from the first key: vieetj scrambles")
    func oldBehaviourScrambles() {
        var s = WebKitSession(passThrough: true)
        for route in routes("vieetj") { s.key(route, after: 0.04, handled: 0) }
        s.finish()
        #expect(s.doc.text != "việt")
    }

    @Test("every character typed by the input method, page stuck from the first key: việt")
    func typedCharactersKeepOrder() {
        var s = WebKitSession()
        for route in routes("vieetj ") { s.key(route, after: 0.04, handled: 0) }
        // Before the page handles a single key event, the text is already right: the
        // queue holds no key for the page to type.
        #expect(s.doc.text == "việt ")
        s.finish()
        #expect(s.doc.text == "việt ")
        #expect(s.overCalls == 0)
        #expect(s.badTyped == 0)
        #expect(s.doc.badRanges == 0)
    }

    @Test("the old behaviour, std string, busy page and keys in a burst: wrong in most seeds")
    func oldBehaviourStdString() {
        for schedule in WebKitSchedule.allCases {
            var wrong = 0
            for seed in 1...UInt64(Self.seeds) {
                let s = Self.run(LateAnswerTests.stdKeys, schedule, seed: seed, passThrough: true)
                if s.doc.text != LateAnswerTests.strings[1].1 { wrong += 1 }
            }
            #expect(wrong > Self.seeds / 2, "\(schedule): \(wrong)/\(Self.seeds) wrong")
        }
    }

    /// The load-test strings (`scripts/selftest/load/run.sh`, `--text std`, `--text edit`)
    /// with every character typed by the input method. `edit` has ⌫, which still goes to
    /// the app (D32) and so still waits behind the queued events of the keys before it:
    /// tested without its ⌫ here, and with them below.
    @Test("std and edit (without ⌫) strings, busy page and keys in a burst, many seeds: the text is right",
          arguments: WebKitSchedule.allCases)
    func loadStrings(_ schedule: WebKitSchedule) {
        let editWithoutDelete = LateAnswerTests.editKeys
            .replacingOccurrences(of: "Hoc ⌫j", with: "Hocj")
            .replacingOccurrences(of: "khoong⌫g", with: "khoong")
        let cases = [
            ("std", LateAnswerTests.stdKeys, LateAnswerTests.strings[1].1),
            ("edit", editWithoutDelete, LateAnswerTests.strings[0].1),
        ]
        for (name, keys, expected) in cases {
            var wrong = 0, over = 0, badTyped = 0, bad = 0
            var example: String?
            for seed in 1...UInt64(Self.seeds) {
                let s = Self.run(keys, schedule, seed: seed)
                if s.doc.text != expected { wrong += 1; if example == nil { example = s.doc.text } }
                over += s.overCalls
                badTyped += s.badTyped
                bad += s.doc.badRanges
            }
            #expect(wrong == 0, "\(schedule) \(name): \(wrong)/\(Self.seeds) wrong, e.g. \(example ?? "")")
            #expect(over == 0)
            #expect(badTyped == 0)
            #expect(bad == 0)
        }
    }

    /// ⌫ is still left to the app (D32): behind the queued events of the keys typed
    /// before it, it reaches the page after the input method's next calls. Measured in
    /// Safari with a busy page on a build that typed characters itself: "Hoc ⌫j" gave
    /// "Hocj" in 3 of 6 runs (`docs/research/LateAnswerFixes.md` 5.4).
    @Test("⌫ behind queued events, busy page: Hoc ⌫j is still wrong (known, LateAnswerFixes 5.4)")
    func deleteStillWaits() {
        var s = WebKitSession()
        for route in routes("Hoc ") { s.key(route, after: 0.04, handled: 0) }
        for route in routes("⌫j") { s.key(route, after: 0.04, handled: 0) }
        s.finish()
        withKnownIssue("⌫ goes to the app and waits in WebKit's key queue (D32, LateAnswerFixes 5.4)") {
            #expect(s.doc.text == "Học")
        }
    }

    /// The same model with a free page that handles each event before the next key:
    /// the old and the new behaviour give the same text (the bug needs a queue).
    @Test("page free between keys: the old and the new behaviour type the same text")
    func freePageSameText() {
        for passThrough in [false, true] {
            var s = WebKitSession(passThrough: passThrough)
            for route in routes(LateAnswerTests.editKeys) { s.key(route, after: 0.1, handled: Int.max) }
            s.finish()
            #expect(s.doc.text == LateAnswerTests.strings[0].1, "passThrough \(passThrough)")
        }
    }
}
