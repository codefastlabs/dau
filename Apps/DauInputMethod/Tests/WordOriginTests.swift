import Foundation
import DauEngine
import DauShared
import Testing

/// Keys → composer → a `LateDocument` that behaves as the word-origin model
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
        if doc.selections > 1 + (outcome.backspaceWait?.asks ?? 0) || doc.reads > 1 || doc.inserts > 1 { overCalls += 1 }
        outcomes.append(outcome)
        if leftToApp(route, outcome) { doc.typed(route) }
    }

    /// `lag`: edits the app's answers are behind by.
    mutating func type(_ keys: String, every interval: TimeInterval, lag: Int = 0) {
        for route in routes(keys) { key(route, after: interval, lag: lag) }
    }
}

/// The word-origin model (from Cursor 3.29.15 logs): the app answers `selectedRange` from
/// the start of the word being typed. The editor of Cursor 3.30.14 answers this way in
/// some runs (`docs/Compatibility.md` 5.4). `LateDocument.Origin.word`; the runs are in
/// `docs/history/LogM6.md`.
@Suite("In-place mode in an app that counts positions from the start of the word (the word-origin model)")
struct WordOriginTests {
    // MARK: The app is on time

    /// Milliseconds between the keys of a Cursor run at a nominal 20 ms (`ev_ns` of the
    /// perf log): about 30 ms, and near 90 ms every eighth key.
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

    /// The Cursor run replayed with its own key times and an app that is on time. The
    /// words that could go wrong are "uongs" and "tuanf": taken as `late` at keys 47
    /// ("uo" + o, sel 2, known 5, range 4,1) and 112 ("tua" + a, sel 3, known 7, range
    /// 6,1), then `mismatch` at the next mark key of each word.
    ///
    /// The answer is right at both keys. The keys since the previous replacement come in
    /// one burst, and the answer happens to be the caret that replacement had (a position
    /// in its own word), so the text read, with that replacement replayed over it, comes
    /// out as the text the tracker typed: the replacement's removed text is not known (it
    /// was made at the app's answer, away from the followed position), so it fits any
    /// text. Taken for an app that has applied none of those keys, the key would replace
    /// at the followed position, a range the app drops.
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

    /// The two words with the positions seen in Cursor, the keys of the burst 5 and 20 ms
    /// apart. `before` is typed at 100 ms: the word whose replacement the app's answer
    /// could be taken for ("ddi" and "saus" are replaced at the app's answer, which is
    /// not the followed position).
    @Test("words of the Cursor logs: the answer is right, the keys since the last replacement came in a burst",
          arguments: [
              // "uo" + o: sel 2, known 5; not `late` (range 4,1 would be dropped).
              ("minhf ", "ddi uo", "o", "ngs ", 2, 5, "mình đi uống "),
              // "tua" + a: sel 3, known 7; not `late` (range 6,1 would be dropped).
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
        #expect(attempt?.followedCaret == word.known)
        #expect(s.outcomes.last?.kind == .replace)
        s.type(word.rest, every: interval)
        #expect(s.doc.text == word.expected)
        #expect(s.doc.dropped == 0)
        #expect(s.overCalls == 0)
    }

    // MARK: After a word of one letter

    /// Cursor 3.29.15, 100 ms between keys: "owr ddaau, uwf cos. anh ddi " must give
    /// "ở dâu, ừ có. anh đi " (the app's answer is right at both keys below, but could be
    /// taken for `late`). After a replaced word of one letter the followed position is
    /// two past it, within `CursorTracker.LatenessBudget.humanPaceEdits`, where the text of the app must be
    /// compared with the text typed:
    /// - "d" + d (sel 1, known 3, range 2,1): the text read, "d", with the last two edits
    ///   replayed gives "d d", whose word is the engine's, though "ở d" was typed there.
    ///   Then `resync` at the second a.
    /// - "co" + s (sel 2, known 4, range 3,1): "co" is the text typed, "ừ co", with its
    ///   two first units missing, which the cache of a late Chromium page never shows.
    ///
    /// The kinds are those of the Cursor run from the first key of the string (after the
    /// confirm step); at each replacement checked here, the answer and the followed
    /// position. The first replacement of the run is not checked: its followed position is
    /// -1 in Cursor and 1 here.
    @Test("the 100 ms run of the Cursor log after one-letter words, the app on time: every word right")
    func afterOneLetterWord() {
        var s = EditorSession()
        s.type("owr ddaau, uwf cos. anh ddi ", every: 0.1)
        #expect(s.doc.text == "ở đâu, ừ có. anh đi ")
        // Only `pass`, `replace` and `seedNone`: no `late`, `resync` or other kind.
        let odd = s.kinds.enumerated().filter { ![.pass, .replace, .seedNone].contains($0.element) }
        #expect(odd.isEmpty, "\(odd.map { "key \($0.offset + 1) \($0.element.rawValue)" })")
        // (key of the string, sel, known) as seen in Cursor; known 11 at key 26 would follow
        // the wrong "co" (9 once that word is replaced at the answer).
        for (key, sel, known) in [(6, 1, 3), (13, 1, 6), (18, 2, 4), (26, 1, 9)] {
            let attempt = s.outcomes[key - 1].attempt
            #expect(attempt?.selection.location == sel, "key \(key)")
            #expect(attempt?.followedCaret == known, "key \(key)")
        }
        #expect(s.doc.dropped == 0)
        #expect(s.overCalls == 0)
    }

    /// "anh ddi owr ddaau " at 20 ms must give "anh đi ở dâu": not `late` at "d" + d (sel
    /// 1, known 3), no `resync` at the second a. `before` at 100 ms stands for the start
    /// of the run, where the position is not followed (known -1 at the first replacement).
    @Test("after a one-letter word with the keys in a burst, the app on time: every word right")
    func afterOneLetterWordInBurst() {
        var s = EditorSession()
        s.type("anh ddi ", every: 0.1)
        s.type("owr dd", every: 0.02)
        #expect(s.outcomes.last?.attempt?.selection.location == 1)
        #expect(s.outcomes.last?.attempt?.followedCaret == 3)
        #expect(s.outcomes.last?.kind == .replace)
        s.type("aau ", every: 0.02)
        #expect(s.doc.text == "anh đi ở đâu ")
        #expect(s.doc.dropped == 0)
        #expect(s.overCalls == 0)
    }

    /// The model cannot be told from a late app with what the input method has: the
    /// same keys at the same times in a new document of an app that counts from the
    /// start of the document, uses Chromium's cache and has applied none of them (VS
    /// Code's new document, measured for the first word: sel 1, known 4, `late`,
    /// `RapidKeysTests.firstWordOfEmptyDocument`) give the same answer, the same text
    /// read and the same followed position. Replacing at the followed position is right
    /// there and dropped by the model; replacing at the answer is right in the model and
    /// replaces the first letter of the document there.
    @Test("a word-origin app on time and a late new document of a document-origin app: same answer, same text read, same followed position")
    func sameAnswerAsLateNewDocument() {
        var cursor = EditorSession()
        cursor.type("anh dd", every: 0.02)

        let doc = LateDocument()
        doc.cache = .chromium
        doc.replace = .caretAfterText
        var engine = VietEngine(options: DauSettings.defaults.engineOptions)
        var composer = InPlaceComposer()
        var now = 0.0
        var last = InPlaceComposer.Outcome()
        func type(_ keys: String, behind: Bool) {
            for route in routes(keys) {
                now += 0.02
                doc.lag = behind ? doc.states.count - 1 : 0
                last = composer.handle(route, time: now, engine: &engine, client: doc)
                if leftToApp(route, last) { doc.typed(route) }
            }
        }
        type("anh dd", behind: true)

        let here = cursor.outcomes[5]
        #expect(here.attempt?.selection == last.attempt?.selection)
        #expect(here.attempt?.followedCaret == last.attempt?.followedCaret)
        #expect(cursor.doc.lastRead == doc.lastRead)
        #expect(cursor.doc.lastRead == "d")
        #expect(here.kind == .late && last.kind == .late)
        type("i ", behind: false)
        #expect(doc.text == "anh đi ")
    }
}
