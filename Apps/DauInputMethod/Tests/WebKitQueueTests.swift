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
    var waits: [InPlaceComposer.BackspaceWait] = []

    /// `passThrough`: characters the engine leaves unchanged go to the app
    /// (`InPlaceComposer.passesCharactersThrough`), the control.
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
        if doc.selections > 1 + (outcome.backspaceWait?.asks ?? 0) || doc.reads > 1 || doc.inserts > 1 { overCalls += 1 }
        if outcome.kind == .pass, case .character = route, doc.inserts != 1 || !outcome.consumed {
            badTyped += 1
        }
        kinds.append(outcome.kind)
        if let wait = outcome.backspaceWait { waits.append(wait) }
        doc.keyEvent(route, handled: outcome.consumed)
    }

    mutating func finish() { doc.pageIdle() }
}

/// Keys → composer → `LateDocument` with WebKit's key queue in time: the page handles
/// each queued event `work` after it is free (`LateDocument.pageFree`), and the input
/// method's waits (`pause`) let the page go on. Keys are handled one after the other
/// from their arrival (a key that comes while the input method waits is handled after).
private struct TimedWebKitSession {
    var engine = VietEngine(options: DauSettings.defaults.engineOptions)
    var composer = InPlaceComposer()
    let doc = LateDocument()
    var overCalls = 0
    var waits: [InPlaceComposer.BackspaceWait] = []
    private var free: TimeInterval = 0

    init(pageFree: @escaping (TimeInterval) -> TimeInterval, work: @escaping () -> TimeInterval) {
        doc.keyQueue = true
        doc.replace = .caretAfterText
        doc.clock = 0
        doc.pageFree = pageFree
        doc.work = work
    }

    mutating func key(_ route: KeyRoute, at arrival: TimeInterval) {
        doc.clock = max(arrival, free)
        doc.selections = 0; doc.reads = 0; doc.inserts = 0
        let outcome = composer.handle(route, time: arrival, engine: &engine, client: doc)
        if doc.selections > 1 + (outcome.backspaceWait?.asks ?? 0) || doc.reads > 1 || doc.inserts > 1 { overCalls += 1 }
        if let wait = outcome.backspaceWait { waits.append(wait) }
        doc.keyEvent(route, handled: outcome.consumed)
        free = (doc.clock ?? arrival) + 0.0005
    }

    /// The page is free from here on and handles every queued event.
    mutating func finish() {
        doc.pageFree = { $0 }
        doc.clock = 1e6
        _ = doc.selectedRange()
    }
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

    /// Characters left to the app reproduce the Safari runs (`docs/Compatibility.md` 5.1,
    /// busy page, keys at a person's fast pace: the text is scrambled): a key let through waits
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
    /// before it, it reaches the page after the input method's next calls ("Hoc ⌫j" gives
    /// "Hocj" in Safari with a busy page, `docs/research/LateAnswerFixes.md` 5.4). The key
    /// after it waits (N3 "Ngoại lệ sau ⌫ chưa áp"); a page that never gets
    /// to the ⌫ within `backspaceWaitLimit` (untimed queue, nothing handled) leaves the key
    /// to go on as without the wait.
    @Test("⌫ behind queued events, page stuck past the wait limit: the key waits the whole limit, then goes on")
    func deleteWaitTimesOut() {
        var s = WebKitSession()
        for route in routes("Hoc ") { s.key(route, after: 0.04, handled: 0) }
        for route in routes("⌫j") { s.key(route, after: 0.04, handled: 0) }
        s.finish()
        #expect(s.waits.count == 1)
        #expect(s.waits.first?.applied == false)
        #expect((s.waits.first?.waited ?? 0) >= InPlaceComposer.backspaceWaitLimit)
        #expect(s.overCalls == 0)
    }

    /// The same model with a free page that handles each event before the next key:
    /// characters left to the app and typed by the input method give the same text (the
    /// order bug needs a queue).
    @Test("page free between keys: the old and the new behaviour type the same text")
    func freePageSameText() {
        for passThrough in [false, true] {
            var s = WebKitSession(passThrough: passThrough)
            for route in routes(LateAnswerTests.editKeys) { s.key(route, after: 0.1, handled: Int.max) }
            s.finish()
            #expect(s.doc.text == LateAnswerTests.strings[0].1, "passThrough \(passThrough)")
            // Every ⌫ is applied before the next key: no key asks again (N3).
            #expect(s.waits.isEmpty)
        }
    }

    // MARK: In time: the key after a ⌫ waits for the page (N3 "Ngoại lệ sau ⌫ chưa áp")

    /// A page blocked 300 ms in every second, at a phase set by the seed (the Safari busy
    /// page: a script blocks the page 300 ms every second). The times are chosen, not
    /// measured.
    static func busyPage(seed: UInt64) -> (TimeInterval) -> TimeInterval {
        var rng = SplitMix(seed &* 2_654_435_761 &+ 7)
        let phase = rng.uniform(0, 1)
        return { t in
            let into = (t + phase).truncatingRemainder(dividingBy: 1)
            return into < 0.3 ? t + (0.3 - into) : t
        }
    }

    /// Seconds the page takes per key event, uniform in `low...high` ms.
    static func work(_ low: Double, _ high: Double, seed: UInt64) -> () -> TimeInterval {
        var rng = SplitMix(seed &* 40_503 &+ 11)
        return { rng.uniform(low, high) / 1000 }
    }

    /// Arrival times: a person typing fast (40 ± 20 ms, 150 ms more after a space; the
    /// Safari runs, `docs/Compatibility.md` 5.1), or a burst (1–5 ms).
    static func arrivalTimes(_ keys: [KeyRoute], burst: Bool, seed: UInt64) -> [TimeInterval] {
        var rng = SplitMix(seed &* 9_973 &+ 5)
        var t = 0.0
        var times: [TimeInterval] = []
        var afterSpace = false
        for key in keys {
            t += burst ? rng.uniform(0.001, 0.005) : rng.uniform(0.02, 0.06) + (afterSpace ? 0.15 : 0)
            times.append(t)
            afterSpace = key == .character(" ")
        }
        return times
    }

    private static func timedRun(_ keys: String, busy: Bool, seed: UInt64) -> TimedWebKitSession {
        // Busy: a page blocked as above. Burst: a free page. Each event 0.05–0.3 ms once the
        // page is free (chosen: Safari applies the ⌫ about 3 ms after the first ask,
        // `docs/research/LateAnswerFixes.md` 5.4), 0.5–2 ms on the free page so that keys
        // 1–5 ms apart queue up.
        var s = TimedWebKitSession(pageFree: busy ? busyPage(seed: seed) : { $0 },
                                   work: busy ? work(0.05, 0.3, seed: seed) : work(0.5, 2, seed: seed))
        let keyRoutes = routes(keys)
        for (route, time) in zip(keyRoutes, arrivalTimes(keyRoutes, burst: !busy, seed: seed)) {
            s.key(route, at: time)
        }
        s.finish()
        return s
    }

    @Test("page blocked when the keys come: Hoc ⌫j → Học, khoong⌫g → không; the key after ⌫ waits for it",
          arguments: [("Hoc ⌫j", "Học"), ("khoong⌫g", "không")])
    func blockedPageBackspace(_ keys: String, _ expected: String) {
        var s = TimedWebKitSession(pageFree: { t in t < 0.4 ? 0.4 : t }, work: { 0.001 })
        for (index, route) in routes(keys).enumerated() { s.key(route, at: 0.04 * Double(index + 1)) }
        s.finish()
        #expect(s.doc.text == expected)
        #expect(s.overCalls == 0)
        #expect(s.doc.badRanges == 0)
        // "Hoc ⌫j": j reads for D20 and waits for the ⌫. "khoong⌫g": g is typed at the
        // caret; right after the ⌫ it asks one selectedRange and waits too (N3).
        #expect(s.waits.filter { !$0.applied }.isEmpty)
        #expect(s.waits.count == 1)
    }

    /// j 51 ms after the ⌫ (past `settleInterval`, a person's pace) while the page is still
    /// blocked: it waits too (N3: any key less than `backspaceWaitWindow` after the ⌫).
    @Test("page blocked, j 51 ms after the ⌫: it waits for the ⌫, Hoc ⌫j → Học")
    func blockedPageSlowerKey() {
        var s = TimedWebKitSession(pageFree: { t in t < 0.4 ? 0.4 : t }, work: { 0.001 })
        for (route, time) in zip(routes("Hoc ⌫j"), [0.04, 0.08, 0.12, 0.16, 0.20, 0.251]) { s.key(route, at: time) }
        s.finish()
        #expect(s.doc.text == "Học")
        #expect(s.waits.count == 1)
        #expect(s.waits.first?.applied == true)
        #expect(s.overCalls == 0)
    }

    /// A key `backspaceWaitWindow` or more after the ⌫ does not wait, whatever the app
    /// answers (here a page blocked for a second): no extra `selectedRange` (N3).
    @Test("⌫, then a pause past the wait window, then j: no wait")
    func pausePastWaitWindow() {
        var s = TimedWebKitSession(pageFree: { t in t < 1.0 ? 1.0 : t }, work: { 0.001 })
        let afterDelete = 0.20 + InPlaceComposer.backspaceWaitWindow + 0.01
        for (route, time) in zip(routes("Hoc ⌫j"), [0.04, 0.08, 0.12, 0.16, 0.20, afterDelete]) {
            s.key(route, at: time)
        }
        s.finish()
        #expect(s.waits.isEmpty)
        #expect(s.overCalls == 0)
    }

    /// The load-test strings in full, ⌫ included ("Hoc ⌫j": j reads for D20; "khoong⌫g":
    /// g is typed at the caret), a busy page at a person's fast pace and a burst on a free
    /// page, many seeds. Lines starting with BKSP give the waits.
    @Test("std and edit (with ⌫) in time, busy page and keys in a burst, many seeds: the text is right")
    func timedLoadStrings() {
        var lines: [String] = []
        for busy in [true, false] {
            for (name, keys, expected) in [("std", LateAnswerTests.stdKeys, LateAnswerTests.strings[1].1),
                                           ("edit", LateAnswerTests.editKeys, LateAnswerTests.strings[0].1)] {
                var wrong = 0, over = 0, bad = 0, waits = 0, applied = 0, longest = 0.0
                var example: String?
                for seed in 1...UInt64(Self.seeds) {
                    let s = Self.timedRun(keys, busy: busy, seed: seed)
                    if s.doc.text != expected { wrong += 1; if example == nil { example = s.doc.text } }
                    over += s.overCalls
                    bad += s.doc.badRanges
                    waits += s.waits.count
                    applied += s.waits.filter(\.applied).count
                    longest = max(longest, s.waits.map(\.waited).max() ?? 0)
                }
                let label = busy ? "busy page" : "burst"
                lines.append("BKSP webkit \(label) \(name): \(wrong)/\(Self.seeds) wrong, ⌫ waits \(waits) "
                    + "(applied \(applied)), longest \(Int(longest * 1000)) ms")
                #expect(over == 0)
                #expect(applied == waits, "\(label) \(name): a wait ran out")
                #expect(wrong == 0, "\(label) \(name): e.g. \(example ?? "")")
                #expect(bad == 0)
            }
        }
        print(lines.joined(separator: "\n"))
    }

    /// The same strings in the Chromium-cache models (`AppModel`), whose answers do not move
    /// while the input method waits (`LateDocument.pause`): how often the key after a ⌫
    /// waits there and how long (printed: lines BKSP), and that the text is exactly the
    /// text without any wait (`InPlaceComposer.skipsBackspaceWait`), right or not.
    @Test("Chromium and Firefox models with ⌫: how often the key after it waits; same text as without the wait")
    func chromiumWaitTable() {
        var lines: [String] = []
        var failures = 0
        for model in AppModel.all {
            for ms in [5.0, 10, 20, 40] {
                var wrong = 0, waits = 0, applied = 0, longest = 0.0, keys = 0, changed = 0
                for seed in 1...UInt64(Self.seeds) {
                    let run = RapidKeysTests.simulate(LateAnswerTests.editKeys, model, ms: ms, seed: seed)
                    if !run.ok { wrong += 1 }
                    let plain = RapidKeysTests.simulate(LateAnswerTests.editKeys, model, ms: ms, seed: seed,
                                                        noWait: true)
                    if run.text != plain.text { changed += 1 }
                    longest = max(longest, run.waits.map(\.waited).max() ?? 0)
                    waits += run.waits.count
                    applied += run.waits.filter(\.applied).count
                    keys += run.kinds.count
                    failures += run.overCalls + run.badRanges
                }
                lines.append("BKSP \(model) \(Int(ms)) ms edit: \(wrong)/\(Self.seeds) wrong, ⌫ waits \(waits) "
                    + "(applied \(applied)) in \(keys) keys, longest \(Int(longest * 1000)) ms, text changed by waiting \(changed)")
                failures += changed
                if model.name != AppModel.busy.name { failures += wrong }
            }
        }
        print(lines.joined(separator: "\n"))
        #expect(failures == 0)
    }
}
