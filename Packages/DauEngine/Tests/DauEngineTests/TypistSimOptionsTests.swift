// Options for correcting typed text, measured in the typist simulator before anything is
// decided (docs/research/EditingTypedText.md, section 4). The options exist only in
// tests (`SimVariant`); nothing here asserts a rate.
//
// Always: `matrixRows` checks that the input method's model (`ImkField`) gives what the
// real `InPlaceComposer` gave on the scenario matrix of the note.
// With tables on stdout:
//   DAU_SIM=1 swift test --package-path Packages/DauEngine --filter TypistSimOptions
// Sensitivity of the dead-end causes to the profile numbers (slower):
//   DAU_SIM_SENS=1 swift test --package-path Packages/DauEngine --filter TypistSimOptions/sensitivity
// Optional: DAU_SIM_SENTENCES (per profile and method; default 3000, sensitivity 800).
import Foundation
import Testing
import DauEngine

@Suite("Mô phỏng người gõ: các phương án sửa chữ")
struct TypistSimOptionsTests {
    static let env = ProcessInfo.processInfo.environment
    static let telex = EngineOptions()
    static let vni = EngineOptions(inputMethod: .vni)

    static func string(_ s: [Unicode.Scalar]) -> String {
        var v = String.UnicodeScalarView()
        v.append(contentsOf: s)
        return String(v)
    }

    /// Types `keys` ("␣" is a space) into a fresh field; the text without trailing spaces.
    static func typed(_ keys: String, _ variant: SimVariant = [], _ options: EngineOptions = telex,
                      reads: Bool = true) -> String {
        var f = ImkField(options, variant: variant)
        f.reads = reads
        for k in keys.unicodeScalars { f.press(k == "␣" ? " " : k) }
        var s = string(f.text)
        while s.hasSuffix(" ") { s.removeLast() }
        return s
    }

    // MARK: - The model against the input method

    /// Rows of section 2 of the note with the result the real `InPlaceComposer` gave
    /// (synchronous fake client, D15 defaults); rows with arrows inside a word, ⌥⌫,
    /// timing or autocorrect are not modelled.
    static let matrix: [(String, String, String)] = [
        ("A8", "nhaq⌫f␣", "nhà"), ("A9", "ddeo⌫pj␣", "đẹp"), ("A10", "vieetk⌫j␣", "việt"),
        ("A11", "ddungsg⌫␣", "đúng"), ("A12", "nhuwngg⌫x␣", "những"), ("A14", "tieeng⌫⌫⌫eengs␣", "tiếng"),
        ("A16", "nhaamff⌫f␣", "nhâmf"), ("A17", "bass⌫s␣", "bas"), ("A18", "nghieengg⌫␣", "nghieeng"),
        ("A19", "bans⌫f␣", "bà"), ("A20", "windoes⌫⌫ws␣", "ưindows"), ("A21", "Sunrisr⌫e␣", "Sủnise"),
        ("B1", "ban␣⌫f␣", "bàn"), ("B2", "bans␣⌫f␣", "bàn"), ("B3", "bans␣⌫z␣", "ban"),
        ("B5", "ban.⌫f.", "bàn."), ("B7", "viet␣⌫ej␣", "việt"), ("B8", "cow␣⌫o␣", "cô"),
        ("B9", "nguoi␣⌫wf␣", "người"), ("B10", "duong␣⌫w␣", "dương"), ("B11", "thuongw␣⌫f␣", "thường"),
        ("B12", "vieejt␣⌫s␣", "viết"), ("B13", "khoongf␣⌫z␣", "không"), ("B14", "chaos␣⌫f␣", "chào"),
        ("B15", "nhaamff␣⌫⌫f␣", "nhầm"), ("B16", "duow␣⌫cj␣", "dược"), ("B17", "hoc␣⌫j␣", "học"),
        ("B18", "hocf␣⌫⌫j␣", "học"), ("B19", "muoon␣⌫s␣", "muốn"), ("B20", "cach␣⌫s␣", "cách"),
        ("B21", "nhanf␣⌫⌫␣", "nhà"), ("B22", "toi␣di␣hoc␣⌫j␣", "toi di học"), ("B23", "viet␣⌫j␣", "vietj"),
        ("B24", "ddep␣⌫j␣", "ddepj"), ("B25", "vieet␣⌫j␣", "vieetj"), ("B26", "toot␣⌫s␣", "toots"),
        ("B27", "dduwowc␣⌫j␣", "dduwowcj"), ("B28", "hocf␣⌫j␣", "hocfj"), ("B29", "ddungsg␣⌫⌫␣", "ddungs"),
        ("B30", "ddungsg␣⌫⌫s␣", "ddungss"), ("B31", "ddungsg␣⌫⌫⌫s␣", "ddungs"),
        ("B32", "nghieengg␣⌫⌫␣", "nghieeng"),
        ("C1", "ban␣awn␣⌫⌫⌫⌫f␣awn␣", "bàn ăn"),
        ("D3", "ddungsg␣⌫⌫⌫⌫⌫⌫⌫⌫ddungs␣", "đúng"), ("D4", "ddungsg␣⌫⌫⌫⌫⌫⌫ungs␣", "ddungs"),
        ("F1", "test␣", "tét"), ("F2", "tesst␣", "test"), ("F3", "test␣⌫⌫st␣", "test"),
        ("F4", "windoes␣⌫⌫⌫ws␣", "windows"), ("F5", "carr␣⌫s␣", "cars"), ("F6", "windows␣⌫⌫␣", "window"),
        ("F7", "bosss␣⌫y␣", "bossy"), ("F8", "teh␣⌫⌫⌫he␣", "the"), ("F10", "taxxi␣", "taxi"),
    ]

    /// Inputs the review of the note named, with what Dấu gives today (engine and model).
    static let reviewInputs: [(String, String, String)] = [
        ("đẹp gõ thừa q", "ddeq⌫p␣", "đep"), ("rồi thêm dấu", "ddeq⌫p␣⌫j␣", "đẹp"),
        ("boot", "boot␣⌫s␣", "boots"), ("Hasaki", "Hasak⌫i␣", "Hấi"), ("carr⌫r", "carr⌫r␣", "car"),
        ("tesst⌫s (D26)", "tesst⌫s␣", "tess"), ("withq⌫", "withq⌫␣", "ưith"),
    ]

    @Test func matrixRows() {
        for (id, keys, today) in Self.matrix + Self.reviewInputs {
            #expect(Self.typed(keys) == today, "\(id) \(keys)")
        }
        guard Self.env["DAU_SIM"] != nil else { return }
        var out = "\n## Ma trận: hôm nay và các phương án\n\n| Mã | Phím | " +
            SimVariant.options.map(\.label).joined(separator: " | ") + " |\n|---|---|" +
            SimVariant.options.map { _ in "---|" }.joined() + "\n"
        for (id, keys, _) in Self.matrix + Self.reviewInputs {
            let results = SimVariant.options.map { Self.typed(keys, $0) }
            guard Set(results).count > 1 else { continue }
            out += "| \(id) | `\(keys)` | " + results.joined(separator: " | ") + " |\n"
        }
        print(out)
    }

    // MARK: - Word lists

    /// docs/research/EditingTypedText.md, appendix.
    static let englishWords = """
        the be to of and a in that have it for not on with he as you do at this but his by from they we say her she or an will my one all would there their what so up out if about who get which go me when make can like time no just him know take people into year your good some could them see other than then now look only come its over think also back after use two how our work first well way even new want because any these give day most us is was are has had did does said made went got test tests best list post cost lost fast last past rest west east must trust boot boots root roots foot feet meet meets seat seats sheet street keep deep sleep need seed feed food goods cook book took hook door poor floor moon soon noon room cool pool tool fool school books cars car card cards carr star start part party art arts bar bars far jar war wars saw raw law draw shaw show snow how wow cow row bow low slow flow window windows sunrise sun run fun gun bus plus thus focus set sets net let bet yet wet met pet jet vet hot lot pot dot shot spot top stop shop drop hop cop tap map cap lap gap rap trap wrap sap app apps apple happy sorry worry carry marry error errors terror mirror coffee toffee office officer offer differ different difference effect effort affair staff stuff cliff off ask task mask desk risk disk dish fish wish rush push bush cash crash flash hash dash wash mesh fresh text next taxi tax box boxes fox mix fix six sex wax max relax index tex vex hex flex complex express press dress less mess guess pass mass class glass grass bass boss loss moss toss cross across process access success password assess possess mission session passion fashion lesson message massage passage bossy fussy messy jazz fuzz buzz quiz size zone zero lazy crazy easy busy quite quit quick quiet query quote equal sequence keyboard key keys kid kind king kiss kit kitchen kick knife known keen kept karma kansas hawk hawks tasks masks desks asks asked function return string struct enum var func self super init deinit import public private static final void int char bool true false null nil none data date type user users name names value values item items array map dict json html css java swift rust python ruby perl php sql api url http https www com org dev web site page code file files debug build release main master branch merge commit pull fetch clone diff log status reset revert rebase stash tag tags note notes view views model models controller service server client request response event events state states store props render hooks route router query mutation schema table column rows join where order group limit offset select insert update delete create alter grant begin
        """.split(separator: " ").map(String.init)

    /// The ten Vietnamese words the review named: (word, Telex keys without the tone, tone key).
    static let vietnameseTen: [(String, String, String)] = [
        ("đẹp", "ddep", "j"), ("việt", "vieet", "j"), ("tốt", "toot", "s"), ("được", "dduwowc", "j"),
        ("nước", "nuwowc", "s"), ("việc", "vieec", "j"), ("đất", "ddaat", "s"), ("nhất", "nhaat", "s"),
        ("phát", "phat", "s"), ("tiếp", "tieep", "s"),
    ]

    /// Vietnamese words of the corpus with a tone: (word, keys without the tone in the
    /// standard order, tone key), Telex.
    static let corpusWords: [(String, String, String)] = {
        var seen = Set<String>()
        var out: [(String, String, String)] = []
        for sentence in TypistSimTests.tokens {
            for t in sentence where !t.english && t.word.tone != .none {
                let w = string(t.core).lowercased()
                guard seen.insert(w).inserted, let parsed = SimWord.parse(w.unicodeScalars) else { continue }
                var plain = parsed
                plain.tone = .none
                let keys = SimKeys.keys(plain, .standard, .telex).map(\.key)
                out.append((w, string(keys), string([SimKeys.toneKey(parsed.tone, .telex)])))
            }
        }
        return out
    }()

    /// Forms of a Vietnamese word typed with a correction; each gives the word today
    /// unless noted.
    static func vietnameseForms(_ keys: String, _ tone: String) -> [(String, String)] {
        let k = Array(keys)
        let head = String(k.dropLast()), last = String(k.last!)
        return [
            ("quên dấu, sửa sau dấu cách", keys + "␣⌫" + tone + "␣"),
            ("thừa chữ rồi ⌫ trong từ", head + "q⌫" + last + tone + "␣"),
            ("thừa chữ rồi ⌫, quên dấu, sửa sau dấu cách", head + "q⌫" + last + "␣⌫" + tone + "␣"),
            ("lỡ gõ đúp dấu, ⌫, gõ lại dấu", keys + tone + tone + "⌫" + tone + "␣"),
            ("thừa chữ cuối, sửa sau dấu cách bằng ⌫", keys + tone + "q␣⌫⌫␣"),
        ]
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["DAU_SIM"] != nil))
    func wordLists() {
        var out = "\n## Danh sách từ: số từ ra đúng theo phương án\n\n"
        // English: words Dấu keeps when typed straight, with one extra letter and ⌫.
        let kept = Self.englishWords.filter { Self.typed($0 + "␣") == $0 }
        let restored = kept.filter { w in
            var e = VietEngine()
            for k in w.unicodeScalars { _ = e.handle(k) }
            return Self.string(e.shown) != w
        }
        out += "Tiếng Anh: \(Self.englishWords.count) từ, Dấu giữ nguyên \(kept.count), trong đó D4 khôi phục \(restored.count).\n\n"
        out += "| Dạng | Số từ | " + SimVariant.options.map(\.label).joined(separator: " | ") + " |\n|---|---|"
            + SimVariant.options.map { _ in "---|" }.joined() + "\n"
        var exampleLines: [String] = []
        func englishRow(_ name: String, _ words: [String], _ make: (String) -> String,
                        _ want: (String) -> String = { $0 }) {
            var cells: [String] = []
            var examples: [String: [String]] = [:]
            let today = words.map { Self.typed(make($0)) }
            for v in SimVariant.options {
                var right = 0
                for (i, w) in words.enumerated() {
                    let got = Self.typed(make(w), v)
                    if got == want(w) { right += 1 }
                    if got != today[i], examples[v.label, default: []].count < 4 {
                        examples[v.label, default: []].append("\(w): \(today[i]) → \(got)")
                    }
                }
                cells.append("\(right)")
            }
            out += "| \(name) | \(words.count) | " + cells.joined(separator: " | ") + " |\n"
            for v in SimVariant.options where examples[v.label] != nil {
                exampleLines.append("- \(name), \(v.label): " + examples[v.label]!.joined(separator: "; "))
            }
        }
        englishRow("thừa q cuối từ rồi ⌫", kept) { $0 + "q⌫␣" }
        englishRow("thừa q giữa từ rồi ⌫", kept) { w in
            let c = Array(w); let m = c.count / 2
            return String(c[..<m]) + "q⌫" + String(c[m...]) + "␣"
        }
        englishRow("sai chữ cuối, ⌫, gõ lại", kept) { w in String(w.dropLast()) + "q⌫" + String(w.last!) + "␣" }
        englishRow("từ D4 khôi phục, ⌫ qua dấu cách, thêm s", restored, { $0 + "␣⌫s␣" }, { $0 + "s" })
        englishRow("từ D4 khôi phục, ⌫ qua dấu cách, ⌫, gõ lại chữ cuối", restored,
                   { $0 + "␣⌫⌫" + String($0.last!) + "␣" })
        // Vietnamese: the ten words, then every toned word of the corpus.
        for (title, list) in [("10 từ của bản rà soát", Self.vietnameseTen), ("\(Self.corpusWords.count) từ có dấu thanh của kho câu", Self.corpusWords)] {
            out += "\n**Tiếng Việt, \(title)**\n\n| Dạng | Số từ | " + SimVariant.options.map(\.label).joined(separator: " | ")
                + " |\n|---|---|" + SimVariant.options.map { _ in "---|" }.joined() + "\n"
            for (fi, formName) in Self.vietnameseForms("ab", "s").map(\.0).enumerated() {
                var cells: [String] = []
                for v in SimVariant.options {
                    var right = 0
                    for (word, keys, tone) in list {
                        let input = Self.vietnameseForms(keys, tone)[fi].1
                        let got = Self.typed(input, v)
                        if got == word { right += 1 }
                    }
                    cells.append("\(right)")
                }
                out += "| \(formName) | \(list.count) | " + cells.joined(separator: " | ") + " |\n"
            }
            if list.count == 10 {
                for (word, keys, tone) in list {
                    for (form, input) in Self.vietnameseForms(keys, tone) {
                        let results = SimVariant.options.map { Self.typed(input, $0) }
                        if results.contains(where: { $0 != word }) {
                            exampleLines.append("- \(word), \(form) `\(input)`: " +
                                zip(SimVariant.options, results).map { "\($0.label) \($1)" }.joined(separator: ", "))
                        }
                    }
                }
            }
        }
        out += "\nVí dụ (hôm nay → phương án):\n\n" + exampleLines.joined(separator: "\n") + "\n"
        print(out)
    }

    // MARK: - Existing engine tests

    /// `Case("keys", "expected")` with ⌫ in the engine's tests, typed through the engine
    /// with each engine option (c, d), no D20 read, as `Typist` types them. Options per
    /// file: VNI for VNITests.swift, Telex otherwise; a case that does not pass today
    /// with that is skipped (its options are elsewhere).
    @Test(.enabled(if: ProcessInfo.processInfo.environment["DAU_SIM"] != nil))
    func existingCases() throws {
        let dir = ExternalCasesTests.repoRoot.appendingPathComponent("Packages/DauEngine/Tests/DauEngineTests")
        let files = try FileManager.default.contentsOfDirectory(atPath: dir.path).filter { $0.hasSuffix(".swift") }.sorted()
        let regex = try NSRegularExpression(pattern: #"(?:Case|expectTyped)\("([^"\\]*)", "([^"\\]*)"[,)]"#)
        var checked = 0, skipped = 0
        var failing: [String: [String]] = [:]
        for file in files where !file.hasPrefix("TypistSim") {
            let source = try String(contentsOf: dir.appendingPathComponent(file), encoding: .utf8)
            let options = file == "VNITests.swift" ? Self.vni : Self.telex
            for m in regex.matches(in: source, range: NSRange(source.startIndex..., in: source)) {
                let keys = String(source[Range(m.range(at: 1), in: source)!])
                let want = String(source[Range(m.range(at: 2), in: source)!])
                guard keys.contains("⌫") else { continue }
                func run(_ v: SimVariant) -> String {
                    var f = ImkField(options, variant: v)
                    f.reads = false
                    for k in keys.unicodeScalars { f.press(k) }
                    return Self.string(f.text)
                }
                guard run([]) == want else { skipped += 1; continue }
                checked += 1
                for v in SimVariant.options where !v.isEmpty {
                    let got = run(v)
                    if got != want { failing[v.label, default: []].append("\(file): \(keys) → \(got) (test: \(want))") }
                }
            }
        }
        var out = "\n## Test engine có ⌫ sẽ đỏ (\(checked) ca kiểm, \(skipped) ca bỏ qua vì tuỳ chọn khác)\n\n"
        for v in SimVariant.options where !v.isEmpty {
            out += "- \(v.label): \(failing[v.label]?.count ?? 0)" +
                (failing[v.label].map { ": " + $0.joined(separator: "; ") } ?? "") + "\n"
        }
        print(out)
    }

    // MARK: - Simulator

    struct Tally {
        var words = 0
        var deadEnds = 0
        var deadEndsInWord = 0
        var deadEndsAfterSpace = 0
        var wrong = 0
        var fixed = 0
        var brokenVi = 0
        var brokenEn = 0
        var brokenExamples: [String] = []
        var rewrites = 0
        var backspaceRewrites = 0
        var english = 0
        var englishWrong = 0
        /// Corrections after the space: [by screen, by keys] tried and right at the first try.
        var afterSpaceTried = [0, 0]
        var afterSpaceRight = [0, 0]
    }

    /// One profile and method, today and `variant` on the same mistakes and reactions.
    static func compare(_ profile: SimProfile, index: Int, _ options: EngineOptions, sentences: Int,
                        seed: UInt64, variant: SimVariant) -> Tally {
        var t = Tally()
        var cache = SimOrderCache()
        let runSeed = seed ^ (UInt64(index) << 32) ^ (options.inputMethod == .vni ? 0x5A5A : 0)
        for n in 0..<sentences {
            let words = TypistSimTests.tokens[n % TypistSimTests.tokens.count]
            let a = SimTypist<ImkField>.run(words, profile: profile, options: options, seed: runSeed,
                                            sentence: n, cache: &cache)
            let b = variant.isEmpty ? a : SimTypist<ImkField>.run(words, profile: profile, options: options,
                                                                   seed: runSeed, sentence: n, cache: &cache,
                                                                   variant: variant)
            for (x, y) in zip(a, b) {
                t.words += 1
                if y.token.english { t.english += 1; if !y.correct { t.englishWrong += 1 } }
                if y.deadEnd && !y.alteredAnyway {
                    t.deadEnds += 1
                    if y.outOfScope { t.deadEndsAfterSpace += 1 } else { t.deadEndsInWord += 1 }
                }
                if y.outOfScope, y.error != nil, !y.absorbed, !y.alteredAnyway {
                    let i = y.byKeys ? 1 : 0
                    t.afterSpaceTried[i] += 1
                    if !y.deadEnd { t.afterSpaceRight[i] += 1 }
                }
                if !y.correct { t.wrong += 1 }
                if !x.correct && y.correct { t.fixed += 1 }
                if x.correct && !y.correct {
                    if x.token.english { t.brokenEn += 1 } else { t.brokenVi += 1 }
                    if t.brokenExamples.count < 3 { t.brokenExamples.append(SimReport.show(y.deadEndScript) + " (\(x.token.text))") }
                }
            }
        }
        return t
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["DAU_SIM"] != nil))
    func optionsRun() {
        let sentences = Self.env["DAU_SIM_SENTENCES"].flatMap { Int($0) } ?? 3000
        let seed = Self.env["DAU_SIM_SEED"].flatMap { UInt64($0) } ?? TypistSimTests.defaultSeed
        var out = "\n## Phương án trong mô phỏng: \(sentences) câu mỗi hồ sơ và kiểu gõ, seed \(seed)\n\n"
        out += "Ngõ cụt / 1000 từ (trong từ + sau dấu cách), theo hồ sơ " +
            SimProfile.all.map(\.name).joined(separator: ", ") + ".\n\n"
        out += "| Phương án | Telex | VNI | Từ sai cuối cùng / 1000 từ (Telex; VNI) | Từ được sửa so với hôm nay | Từ Việt mới hỏng | Từ Anh mới hỏng |\n|---|---|---|---|---|---|---|\n"
        var afterSpace: [String] = []
        var examples: [String] = []
        for v in SimVariant.options {
            var cells: [String] = []
            var wrong: [String] = []
            var fixed = 0, brokenVi = 0, brokenEn = 0
            for options in [Self.telex, Self.vni] {
                var per: [String] = []
                var all = Tally()
                for (i, p) in SimProfile.all.enumerated() {
                    let t = Self.compare(p, index: i, options, sentences: sentences, seed: seed, variant: v)
                    per.append(String(format: "%.2f", 1000 * Double(t.deadEnds) / Double(t.words)))
                    all.words += t.words; all.wrong += t.wrong
                    for j in 0..<2 { all.afterSpaceTried[j] += t.afterSpaceTried[j]; all.afterSpaceRight[j] += t.afterSpaceRight[j] }
                    fixed += t.fixed; brokenVi += t.brokenVi; brokenEn += t.brokenEn
                    if !t.brokenExamples.isEmpty { examples.append("- \(v.label), \(p.name): " + t.brokenExamples.joined(separator: "; ")) }
                }
                cells.append(per.joined(separator: " / "))
                afterSpace.append("- \(v.label), \(options.inputMethod): sửa sau dấu cách đúng ngay lần đầu: theo màn hình \(all.afterSpaceRight[0])/\(all.afterSpaceTried[0]), theo phím \(all.afterSpaceRight[1])/\(all.afterSpaceTried[1])")
                wrong.append(String(format: "%.2f", 1000 * Double(all.wrong) / Double(all.words)))
            }
            out += "| \(v.label) | \(cells[0]) | \(cells[1]) | \(wrong.joined(separator: "; ")) | \(fixed) | \(brokenVi) | \(brokenEn) |\n"
        }
        out += "\n" + afterSpace.joined(separator: "\n") + "\n"
        out += "\nTừ mới hỏng (chuỗi phím tới lúc ngõ cụt, từ muốn):\n\n" + examples.joined(separator: "\n") + "\n"
        print(out)
    }

    // MARK: - Sensitivity

    /// What a dead end of today would need: replays its keys with each single option.
    enum Cause: String, CaseIterable {
        case doubleLock = "K4 khoá gõ đúp sau ⌫ (d sửa)"
        case restored = "K1 từ đã khôi phục (b′ sửa)"
        case baseline = "K3 mốc sau ⌫ (c sửa)"
        case other = "khác"
    }

    static func cause(_ e: SimEpisode, _ options: EngineOptions) -> Cause {
        func fixedBy(_ v: SimVariant) -> Bool {
            var f = ImkField(options, variant: v)
            for k in e.deadEndScript { f.press(k) }
            f.press(" ")
            let text = Array(f.text.dropLast())
            let start = text.lastIndex(of: " ").map { $0 + 1 } ?? 0
            return SimTypist<ImkField>.matches(text[start...], e.token)
        }
        if fixedBy([.releaseDouble]) { return .doubleLock }
        if fixedBy([.restoredKeys, .rewriteOnBackspace]) { return .restored }
        if fixedBy([.tailStraight]) { return .baseline }
        return .other
    }

    static func scaled(_ x: Int, _ f: Double) -> Int { min(100, max(0, Int((Double(x) * f).rounded()))) }

    static var configs: [(String, (inout SimProfile) -> Void)] {
        var c: [(String, (inout SimProfile) -> Void)] = [("gốc", { _ in })]
        for f in [0.5, 2.0] {
            let tag = f < 1 ? "×0,5" : "×2"
            c.append(("tỉ lệ lỗi \(tag)", { $0.errorPercent *= f }))
            for kind in SimError.allCases {
                c.append(("lỗi \(kind.label) \(tag)", { p in
                    p.errors = p.errors.map { $0.0 == kind ? ($0.0, Int((Double($0.1) * f).rounded())) : $0 } }))
            }
            for corr in SimCorrection.allCases {
                c.append(("\(corr.label) \(tag)", { p in
                    p.corrections = p.corrections.map { $0.0 == corr ? ($0.0, Int((Double($0.1) * f).rounded())) : $0 } }))
            }
            c.append(("phím dấu tại chỗ \(tag)", { $0.markKeysPercent = scaled($0.markKeysPercent, f) }))
            c.append(("thấy lỗi ngay \(tag)", { $0.noticeAtOncePercent = scaled($0.noticeAtOncePercent, f) }))
            c.append(("gõ lại sau ngõ cụt \(tag)", { $0.retypeAfterDeadEndPercent = scaled($0.retypeAfterDeadEndPercent, f) }))
        }
        c.append(("sửa theo màn hình (không theo phím)", { $0.byKeysPercent = 0 }))
        c.append(("luôn sửa theo phím đã gõ", { $0.byKeysPercent = 100 }))
        c.append(("chỉ sửa ngay trong từ", { $0.corrections = [(.immediate, 1)] }))
        c.append(("chỉ sửa sau dấu cách", { $0.corrections = [(.afterSpace, 1)] }))
        c.append(("chỉ xoá cả từ gõ lại", { $0.corrections = [(.retypeWord, 1)] }))
        c.append(("chỉ phím dấu tại chỗ", { $0.markKeysPercent = 100 }))
        c.append(("chỉ ⌫ tới chỗ sai", { $0.markKeysPercent = 0 }))
        c.append(("không lỡ gõ đúp dấu", { p in p.errors = p.errors.filter { $0.0 != .doubleTone } }))
        for order in SimOrder.allCases {
            c.append(("mọi người gõ thứ tự \(order.label)", { $0.orders = [(order, 1)] }))
        }
        return c
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["DAU_SIM_SENS"] != nil))
    func sensitivity() {
        let sentences = Self.env["DAU_SIM_SENTENCES"].flatMap { Int($0) } ?? 800
        let seed = Self.env["DAU_SIM_SEED"].flatMap { UInt64($0) } ?? TypistSimTests.defaultSeed
        var out = "\n## Độ nhạy: \(sentences) câu mỗi hồ sơ và kiểu gõ, seed \(seed); mọi hồ sơ cùng đổi\n\n"
        out += "| Cấu hình | Ngõ cụt / 1000 từ (Telex; VNI) | " + Cause.allCases.map(\.rawValue).joined(separator: " | ")
            + " | Đứng đầu Telex; VNI |\n|---|---|" + Cause.allCases.map { _ in "---|" }.joined() + "---|\n"
        var tops: [String: Int] = [:]
        for (name, change) in Self.configs {
            var counts: [Cause: Int] = [:]
            var rates: [String] = []
            var top: [String] = []
            for options in [Self.telex, Self.vni] {
                var words = 0, dead = 0
                var byMethod: [Cause: Int] = [:]
                for (i, base) in SimProfile.all.enumerated() {
                    var p = base
                    change(&p)
                    var cache = SimOrderCache()
                    let runSeed = seed ^ (UInt64(i) << 32) ^ (options.inputMethod == .vni ? 0x5A5A : 0)
                    for n in 0..<sentences {
                        let eps = SimTypist<ImkField>.run(TypistSimTests.tokens[n % TypistSimTests.tokens.count],
                                                          profile: p, options: options, seed: runSeed, sentence: n,
                                                          cache: &cache)
                        for e in eps {
                            words += 1
                            guard e.deadEnd, !e.alteredAnyway else { continue }
                            dead += 1
                            byMethod[Self.cause(e, options), default: 0] += 1
                        }
                    }
                }
                rates.append(String(format: "%.2f", 1000 * Double(dead) / Double(max(words, 1))))
                let best = byMethod.max { $0.value < $1.value }?.key
                top.append(best.map { String($0.rawValue.prefix(2)) } ?? "–")
                for (k, v) in byMethod { counts[k, default: 0] += v }
            }
            let total = counts.values.reduce(0, +)
            out += "| \(name) | \(rates.joined(separator: "; ")) | " + Cause.allCases.map {
                total == 0 ? "–" : String(format: "%.0f%%", 100 * Double(counts[$0] ?? 0) / Double(total))
            }.joined(separator: " | ") + " | \(top.joined(separator: "; ")) |\n"
            tops[top.joined(separator: "; "), default: 0] += 1
        }
        out += "\nĐứng đầu (Telex; VNI) theo số cấu hình: " + tops.sorted { $0.value > $1.value }
            .map { "\($0.key): \($0.value)" }.joined(separator: ", ") + "\n"
        print(out)
    }
}
