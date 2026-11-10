import Foundation
import DauEngine
import DauShared
import Testing

/// Keys → composer → a `LateDocument` that behaves as Cursor's editor does
/// (`LateDocument.Origin.word`, Chromium's cache, the caret kept after a replaced range),
/// every key `interval` after the previous one.
private struct EditorSession {
    var engine = VietEngine(options: DauSettings.defaults.engineOptions)
    var composer = InPlaceComposer()
    let doc = LateDocument()
    var now: TimeInterval = 0
    var outcomes: [InPlaceComposer.Outcome] = []
    /// Keys with more than one call of a kind (must stay 0, N3).
    var overCalls = 0

    init() {
        doc.cache = .chromium
        doc.replace = .keepSelection
        doc.origin = .word
    }

    var kinds: [PerfLog.Kind] { outcomes.map(\.kind) }

    mutating func key(_ route: KeyRoute, after seconds: TimeInterval, lag: Int = 0) {
        now += seconds
        doc.lag = lag
        doc.selections = 0; doc.reads = 0; doc.inserts = 0
        let outcome = composer.handle(route, time: now, engine: &engine, client: doc)
        if doc.selections > 1 || doc.reads > 1 || doc.inserts > 1 { overCalls += 1 }
        outcomes.append(outcome)
        if !outcome.consumed { doc.typed(route) }
    }

    /// `lag`: edits the app's answers are behind by.
    mutating func type(_ keys: String, every interval: TimeInterval, lag: Int = 0) {
        for route in routes(keys) { key(route, after: interval, lag: lag) }
    }
}

/// Cursor's editor answers `selectedRange` from the start of the word being typed
/// (`LateDocument.Origin.word`; runs of 10/11/2026 in `docs/PROGRESS.md`, logs in
/// build/load/cursor-20261110-094602 and cursor2-20261110-100405, not committed).
@Suite("In-place mode in an app that counts positions from the start of the word (M6: Cursor's editor)")
struct CursorEditorTests {
    // MARK: The app is on time (group 1 of the runs)

    /// Milliseconds between the keys of the 20 ms run of 09:46 (cell c-20, Dấu Debug
    /// dc7208c, `ev_ns` of the perf log): about 30 ms, and near 90 ms every eighth key.
    static let gapsOf20msRun: [Double] = [
        0, 50, 12, 18, 26, 32, 29, 83, 30, 29, 35, 22, 33, 23, 28, 102, 20, 33, 25, 31, 28, 37, 30, 120, 34, 31, 39,
        28, 91, 7, 21, 81, 31, 30, 32, 26, 32, 27, 31, 86, 31, 30, 30, 27, 30, 26, 32, 101, 29, 37, 23, 37, 33, 26,
        33, 87, 33, 25, 32, 25, 41, 26, 27, 84, 27, 32, 35, 30, 28, 36, 26, 88, 63, 28, 26, 38, 32, 28, 32, 86, 26,
        29, 34, 25, 30, 28, 31, 123, 15, 27, 35, 42, 54, 31, 47, 96, 26, 28, 30, 32, 39, 27, 30, 89, 26, 27, 29, 31,
        29, 30, 30, 99, 25, 27, 28, 30, 25, 36, 30, 72, 28, 27, 30, 30, 30, 29, 34, 85, 29, 29, 34, 33, 33, 33, 31,
        71, 33, 29, 36, 26, 30, 32, 37, 90, 27, 33, 32, 29, 30, 27, 29, 86, 29, 26, 28, 29, 26, 31, 30, 90, 30, 28,
        30, 32, 29, 28, 28, 101, 30, 35, 37, 33, 31, 28, 28, 94, 26, 31, 30, 31, 29, 28, 35, 87, 27, 28, 27, 33, 28,
        28, 32, 77, 33, 26, 27, 28, 27, 29, 35, 82, 30, 27, 29, 30, 28, 35, 39, 90, 29, 31, 22, 35, 35, 34, 28, 105,
        25, 28, 51, 26, 33, 32, 29, 115, 20, 33, 28,
    ]

    /// The 20 ms run replayed with its own key times and an app that is on time. That
    /// run gave "uongs" and "tuanf" and nothing else wrong (as every run at nominal 5 and
    /// 20 ms; none at 100 ms): `late` at keys 47 ("uo" + o, sel 2, known 5, range 4,1)
    /// and 112 ("tua" + a, sel 3, known 7, range 6,1), `mismatch` at the next mark key
    /// of each word.
    ///
    /// Cursor's answer was right at both keys. The keys since the previous replacement
    /// came in one burst, and the answer happened to be the caret that replacement had
    /// (a position in its own word), so the text read, with that replacement replayed
    /// over it, came out as the text the tracker typed: the replacement's removed text
    /// was not known (it was made at the app's answer, away from the followed position),
    /// so it fitted any text. Taken for an app that had applied none of those keys, the
    /// key replaced at the followed position, a range the app drops.
    @Test("the 20 ms run of the Cursor log replayed with its key times, the app on time: every word right")
    func runAt20ms() {
        var s = EditorSession()
        let keys = routes(LateAnswerTests.stdKeys)
        #expect(keys.count == Self.gapsOf20msRun.count)
        for (route, gap) in zip(keys, Self.gapsOf20msRun) { s.key(route, after: gap / 1000) }
        #expect(s.doc.text == LateAnswerTests.strings[1].1)
        // An app that is on time is never taken for a late one.
        let odd = s.kinds.enumerated().filter { $0.element == .late || $0.element == .lateGuess || $0.element == .mismatch }
        #expect(odd.isEmpty, "\(odd.map { "key \($0.offset + 1) \($0.element.rawValue)" })")
        #expect(s.doc.dropped == 0)
        #expect(s.doc.badRanges == 0)
        #expect(s.overCalls == 0)
    }

    /// The two words with the positions of the logs, the keys of the burst 5 and 20 ms
    /// apart. `before` is typed at 100 ms: the word whose replacement the app's answer
    /// was taken for (in the logs "ddi" and "saus" were replaced at the app's answer,
    /// which was not the followed position).
    @Test("words of the Cursor logs: the answer is right, the keys since the last replacement came in a burst",
          arguments: [
              // "uo" + o: sel 2, known 5; was `late`, range 4,1.
              ("minhf ", "ddi uo", "o", "ngs ", 2, 5, "mình đi uống "),
              // "tua" + a: sel 3, known 7; was `late`, range 6,1.
              ("thuws ", "saus tua", "a", "nf ", 3, 7, "thứ sáu tuần "),
          ], [0.005, 0.02])
    func rightAnswerInBurst(_ word: (before: String, keys: String, key: String, rest: String, sel: Int, known: Int,
                                     expected: String), _ interval: TimeInterval) {
        var s = EditorSession()
        s.type(word.before, every: 0.1)
        s.type(word.keys, every: interval)
        s.type(word.key, every: interval)
        let attempt = s.outcomes.last?.attempt
        #expect(attempt?.selection.location == word.sel)
        #expect(attempt?.known == word.known)
        #expect(s.outcomes.last?.kind == .replace)
        s.type(word.rest, every: interval)
        #expect(s.doc.text == word.expected)
        #expect(s.doc.dropped == 0)
        #expect(s.overCalls == 0)
    }

    // MARK: The app is behind (group 2 of the runs): not fixed

    /// Words that came out wrong only at nominal 5 ms, not in every run: Cursor's answer
    /// was stale across a word boundary (the page had not applied the space, or the
    /// letters after it). A stale position is in the coordinates of a word the page has
    /// left, or of a word it has not filled yet, and the page applies the range in the
    /// coordinates it has when it gets to it: neither the answer nor the followed
    /// position (which counts from an earlier word) is where the word is. The code from
    /// before M6, which took the answer as it was, gives the same wrong words in this
    /// model (run in a copy of 4695eae, not in this repo).
    ///
    /// Each case replays keys of the logs: `before` at 100 ms, `keys` 10 ms apart on
    /// time, each key of `late` with the answer `lags` edits behind (`sel` is the answer
    /// at the last of them), `rest` on time. `measured` is the text of the log, which
    /// the model must give; `right` is what a fix must give.
    @Test("known limit, words of the Cursor logs with a stale answer across a word boundary: wrong as measured",
          arguments: [
              // pilot-5 key 19: sel 4 (the page has "anh"), replaced at 3,1: dropped.
              ("anh ", "co", "s", [3], " ", 4, "anh co ", "anh có "),
              // c-5-1 of 10:04, key 19: sel 1 (the page has the space), replaced at 0,1.
              ("anh ", "co", "s", [2], " ", 1, "anh óo ", "anh có "),
              // c-5-1 of 10:04, key 39: sel 2 (the page has "m"): mismatch.
              ("ranhr ", "minh", "f", [3], " ", 2, "rảnh minhf ", "rảnh mình "),
              // c-5-2 of 09:46, keys 147, 148: sel 6 (the page has "email"), range 5,1: dropped.
              ("email ", "ve", "ef", [3, 4], " ", 6, "email ve ", "email về "),
              // c-5-1 of 10:04, key 96: sel 1 (the page has the space), replaced at 0,1.
              ("nayf ", "la", "f", [2], " ", 1, "này àa ", "này là "),
              // c-5-1 of 10:04, key 79: sel 2 (the page has "c"), replaced at 0,2.
              ("anh ", "cua", "r", [2], " ", 2, "anh ủaa ", "anh của "),
              // pilot-5 key 159: sel 5 (the page has "buổi"), `late`, range dropped.
              ("buooir ", "me", "e", [3], "ting ", 5, "buổi meting ", "buổi meeting "),
          ])
    func staleAnswerAcrossWords(_ word: (before: String, keys: String, late: String, lags: [Int], rest: String,
                                         sel: Int, measured: String, right: String)) {
        var s = EditorSession()
        s.type(word.before, every: 0.1)
        s.type(word.keys, every: 0.01)
        for (route, lag) in zip(routes(word.late), word.lags) { s.key(route, after: 0.01, lag: lag) }
        #expect(s.outcomes.last?.attempt?.selection.location == word.sel)
        s.type(word.rest, every: 0.01)
        #expect(s.doc.text == word.measured)
        withKnownIssue("Cursor's editor answers late across a word boundary (group 2, not fixed)") {
            #expect(s.doc.text == word.right)
        }
        #expect(s.overCalls == 0)
    }

    // MARK: After a word of one letter (run of 11:44)

    /// The run c100-short of 11:44 (Cursor 3.29.15, Dấu Debug dc71b7f, 100 ms between
    /// keys; build/load/fix2-20261110-114446, not committed): "owr ddaau, uwf cos. anh
    /// ddi " gave "ở dâu, ừ co. anh đi ". Cursor's answer was right at both keys; after
    /// a replaced word of one letter the followed position is two past it, within
    /// `CursorTracker.lateLimit`, where the text of the app was not compared with the
    /// text typed:
    /// - "d" + d (sel 1, known 3, was `late`, range 2,1): the text read, "d", with the
    ///   last two edits replayed gave "d d", whose word is the engine's, though "ở d"
    ///   was typed there. Then `resync` at the second a.
    /// - "co" + s (sel 2, known 4, was `late`, range 3,1): "co" is the text typed, "ừ co",
    ///   with its two first units missing, which the cache of a late Chromium page
    ///   never shows.
    ///
    /// The log's kinds from the first key of the string (after the confirm step); at
    /// each replacement of the log checked here, the answer and the followed position (the
    /// first replacement of the run, not checked, had known -1 in the log and has 1 here:
    /// the log does not say why the first key did not anchor the position).
    @Test("the 100 ms run of the Cursor log after one-letter words, the app on time: every word right")
    func afterOneLetterWord() {
        var s = EditorSession()
        s.type("owr ddaau, uwf cos. anh ddi ", every: 0.1)
        #expect(s.doc.text == "ở đâu, ừ có. anh đi ")
        // The log: seed_none replace replace pass pass late pass resync pass … late …
        let odd = s.kinds.enumerated().filter { ![.pass, .replace, .seedNone].contains($0.element) }
        #expect(odd.isEmpty, "\(odd.map { "key \($0.offset + 1) \($0.element.rawValue)" })")
        // (key of the string, sel, known) of the log's diag lines; known 11 at key 26 followed the
        // wrong "co" (9 once that word is replaced at the answer).
        for (key, sel, known) in [(6, 1, 3), (13, 1, 6), (18, 2, 4), (26, 1, 9)] {
            let attempt = s.outcomes[key - 1].attempt
            #expect(attempt?.selection.location == sel, "key \(key)")
            #expect(attempt?.known == known, "key \(key)")
        }
        #expect(s.doc.dropped == 0)
        #expect(s.overCalls == 0)
    }

    /// The run c20-short of 11:44: "anh ddi owr ddaau " at 20 ms gave "anh đi ở dâu",
    /// `late` at "d" + d (sel 1, known 3), `resync` at the second a. `before` at 100 ms
    /// stands for the start of that run, where the position was not followed (known -1
    /// at the first replacement).
    @Test("after a one-letter word with the keys in a burst, the app on time: every word right")
    func afterOneLetterWordInBurst() {
        var s = EditorSession()
        s.type("anh ddi ", every: 0.1)
        s.type("owr dd", every: 0.02)
        #expect(s.outcomes.last?.attempt?.selection.location == 1)
        #expect(s.outcomes.last?.attempt?.known == 3)
        #expect(s.outcomes.last?.kind == .replace)
        s.type("aau ", every: 0.02)
        #expect(s.doc.text == "anh đi ở đâu ")
        #expect(s.doc.dropped == 0)
        #expect(s.overCalls == 0)
    }

    // MARK: Predicted by the model, not seen in a run

    /// The same mistake as group 1 (a right answer taken for a late one) when every key
    /// since the position was anchored at the start of the app's text came in one burst
    /// (`CursorTracker.typedHere`, the first word of a new document): in this app every
    /// word starts at 0, so the answer of an app that is on time is the answer
    /// Chromium's cache gives when the page has applied none of the keys.
    ///
    /// Not seen in Cursor: in the run c20-short of 11:44 "anh ddi" at 20 ms came out
    /// right; the log has known -1 at that key (the position was not anchored at the
    /// first key of the string), so the condition of this case was not met there. Kept
    /// as what the model gives; the code is not changed for it.
    @Test("predicted by the model, not seen in a run: a burst from a position anchored at 0, a right answer taken for a late one",
          arguments: [
              ("anh ddi ", "anh đi "),
              ("chieeuf nay anh cos ", "chiều nay anh có "),
          ])
    func burstFromAnchorTakenForLate(_ keys: String, _ expected: String) {
        var s = EditorSession()
        s.type(keys, every: 0.02)
        #expect(s.kinds.contains(.late))
        withKnownIssue("a right answer of a word-origin app taken for a late one (model only)") {
            #expect(s.doc.text == expected)
        }
        #expect(s.overCalls == 0)
    }

    // MARK: Simulation table

    /// Cursor's editor with a page that applies keys late. The times are not measured:
    /// chosen so the page falls some keys behind at 5 ms and keeps up from 10 ms (in the
    /// runs the stale answers of group 2 came only at nominal 5 ms, where the keys were
    /// in fact 2 to 20 ms apart).
    static let cursor = AppModel(name: "cursor", cache: .chromium, replace: .keepSelection, work: 1.0...8.0,
                                 origin: .word)

    static let speeds: [Double] = [5, 10, 20, 100]

    struct Cell {
        var wrong = 0, late = 0, guess = 0, mismatch = 0, dropped = 0, over = 0, bad = 0, behind = 0
        var example: RapidKeysTests.Run?
    }

    static func cell(_ keys: String, _ model: AppModel, ms: Double) -> Cell {
        var cell = Cell()
        for seed in 1...UInt64(RapidKeysTests.seeds) {
            let run = RapidKeysTests.simulate(keys, model, ms: ms, seed: seed)
            if !run.ok { cell.wrong += 1; if cell.example == nil { cell.example = run } }
            cell.late += run.kinds.filter { $0 == .late }.count
            cell.guess += run.kinds.filter { $0 == .lateGuess }.count
            cell.mismatch += run.kinds.filter { $0 == .mismatch }.count
            cell.dropped += run.dropped
            cell.over += run.overCalls
            cell.bad += run.badRanges
            cell.behind = max(cell.behind, run.behind)
        }
        return cell
    }

    /// The four models at 5, 10, 20, 100 ms (lines starting with CURSOR are the table of
    /// the report). Chrome, VS Code, Firefox: no wrong run, as `RapidKeysTests.burstTable`.
    /// Cursor: no wrong run where the page of the model keeps up (10, 20, 100 ms); at 5 ms
    /// it is behind and answers in the coordinates of another word (group 2 of the runs,
    /// not fixed: `staleAnswerAcrossWords`), recorded only.
    @Test("load-test strings at 5, 10, 20, 100 ms in Chrome, VS Code, Firefox and Cursor models")
    func table() {
        var lines: [String] = []
        var failures = 0
        for model in [AppModel.chrome, .vscode, .firefox, Self.cursor] {
            for ms in Self.speeds {
                var cells: [String] = []
                for (name, keys) in RapidKeysTests.strings {
                    let cell = Self.cell(keys, model, ms: ms)
                    let n = RapidKeysTests.seeds
                    let isCursor = model.name == Self.cursor.name
                    failures += cell.over + cell.bad + (isCursor && ms < 10 ? 0 : cell.wrong)
                    cells.append("\(name) \(cell.wrong)/\(n) wrong, behind ≤ \(cell.behind), late \(cell.late), "
                        + "guess \(cell.guess), mismatch \(cell.mismatch), dropped \(cell.dropped), over \(cell.over), bad \(cell.bad)")
                    if let example = cell.example {
                        lines.append("  e.g. \(model) \(Int(ms)) ms \(name): \(example.text) ≠ \(example.reference)")
                    }
                }
                lines.append("CURSOR \(model) \(Int(ms)) ms: " + cells.joined(separator: "; "))
            }
        }
        print(lines.joined(separator: "\n"))
        #expect(failures == 0)
    }
}
