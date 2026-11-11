// Typist simulator: simulated people (beginner, ordinary, skilled, very fast) type the
// sentences of `SimCorpus` in Telex and VNI with their own key orders (D28 (Bỏ dấu tự
// do)), make mistakes and correct them. Measurement only: nothing here asserts a rate.
//
// Small fixed run: part of every `swift test`. Large run, with tables on stdout:
//   DAU_SIM=1 swift test --package-path Packages/DauEngine --filter TypistSim
// Optional: DAU_SIM_SENTENCES (per profile and method, default 3000), DAU_SIM_SEED.
//
// Profiles and their assumed numbers: TypistSim/SimProfiles.swift. Corrections after the
// space (⌫ over it, then fix) need the input method to read the word back (D20 (Thêm dấu
// cho từ đã gõ)); they are counted as outside the engine's scope, and run only on the
// test model of that read (`MirrorField`).
import Foundation
import Testing
import DauEngine

@Suite("Mô phỏng người gõ")
struct TypistSimTests {
    static let defaultSeed: UInt64 = 20_261_111
    static let tokens: [[SimToken]] = SimCorpus.sentences.map(SimToken.tokenize)
    static let methods: [(String, EngineOptions)] = [("Telex", EngineOptions()), ("VNI", EngineOptions(inputMethod: .vni))]

    struct Run {
        var engine = SimStats()
        var mirror = SimStats()
        var afterSpace = SimStats()
        var orderFailures: [String] = []
    }

    static func simulate(_ profile: SimProfile, profileIndex: Int, _ options: EngineOptions,
                         sentences: Int, seed: UInt64, step: Int = 1) -> Run {
        var run = Run()
        var cache = SimOrderCache()
        let runSeed = seed ^ (UInt64(profileIndex) << 32) ^ (options.inputMethod == .vni ? 0x5A5A : 0)
        for n in 0..<sentences {
            let words = tokens[(n * step) % tokens.count]
            let a = SimTypist<EngineField>.run(words, profile: profile, options: options,
                                               seed: runSeed, sentence: n, cache: &cache)
            let b = SimTypist<MirrorField>.run(words, profile: profile, options: options,
                                               seed: runSeed, sentence: n, cache: &cache)
            run.engine.add(a)
            run.mirror.add(b)
            run.afterSpace.addOutOfScopeDeadEnds(b)
        }
        run.orderFailures = cache.failures
        return run
    }

    /// Fast, fixed seed: every profile and both methods over every third sentence of the
    /// corpus (Vietnamese and mixed). Records only.
    @Test func smallFixedRun() {
        for (_, options) in Self.methods {
            for (i, profile) in SimProfile.all.enumerated() {
                let run = Self.simulate(profile, profileIndex: i, options, sentences: Self.tokens.count / 3,
                                        seed: Self.defaultSeed, step: 3)
                #expect(run.engine.words == run.mirror.words && run.engine.words > 0)
            }
        }
    }

    /// The corpus in every typing order without mistakes: which orders the engine does not
    /// take (D28) and which English words it changes (D4, D26). Records only.
    @Test func cleanOrders() {
        for (name, options) in Self.methods {
            var cache = SimOrderCache()
            for words in Self.tokens {
                for token in words where !token.english {
                    for order in SimOrder.allCases { _ = cache.works(token, order, options) }
                }
            }
            if ProcessInfo.processInfo.environment["DAU_SIM"] != nil {
                print("\n### \(name): thứ tự gõ không ra đúng chữ khi không có lỗi (\(cache.failures.count))\n")
                for f in cache.failures { print("- \(f)") }
            }
        }
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["DAU_SIM"] != nil))
    func largeRun() {
        let env = ProcessInfo.processInfo.environment
        let sentences = env["DAU_SIM_SENTENCES"].flatMap { Int($0) } ?? 3000
        let seed = env["DAU_SIM_SEED"].flatMap { UInt64($0) } ?? Self.defaultSeed
        let start = Date()
        var report = "\n# Mô phỏng người gõ: \(sentences) câu mỗi hồ sơ, seed \(seed)\n"
        for (name, options) in Self.methods {
            var rows: [(String, SimStats, SimStats)] = []
            var all = Run()
            for (i, profile) in SimProfile.all.enumerated() {
                let run = Self.simulate(profile, profileIndex: i, options, sentences: sentences, seed: seed)
                rows.append((profile.name, run.engine, run.mirror))
                all.engine.merge(run.engine)
                all.mirror.merge(run.mirror)
                all.afterSpace.merge(run.afterSpace)
                report += "\n### \(name) · \(profile.name): theo loại lỗi\n\n"
                report += SimReport.errorTable(run.engine, run.mirror)
            }
            report += "\n## \(name): theo hồ sơ\n\n" + SimReport.profileTable(rows)
            report += "\n## \(name): theo loại lỗi, mọi hồ sơ\n\n" + SimReport.errorTable(all.engine, all.mirror)
            report += "\n## \(name): ngõ cụt trong phạm vi engine (\(all.engine.deadEnds))\n\n"
            report += SimReport.patternTable(all.engine, top: 15)
            report += "\n## \(name): ngõ cụt khi sửa sau dấu cách, mô hình IMK (\(all.afterSpace.deadEnds))\n\n"
            report += SimReport.patternTable(all.afterSpace, top: 10)
            let english = all.engine.englishAlteredWords.sorted { $0.value > $1.value }
                .map { "\($0.key) (\($0.value))" }.joined(separator: ", ")
            report += "\n\(name): từ tiếng Anh bị đổi khi gõ đúng phím: \(english)\n"
            report += "\(name): từ dùng thứ tự chuẩn thay cho thứ tự của hồ sơ: \(all.engine.orderFallbacks)\n"
            report += "\(name): từ lệch hàng vì câu ra khác số từ: engine \(all.engine.misaligned), mô hình IMK \(all.mirror.misaligned)\n"
        }
        report += "\nThời gian: \(String(format: "%.1f", Date().timeIntervalSince(start))) s\n"
        print(report)
    }
}
