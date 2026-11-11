// Short fuzz run of VietEngine with a fixed seed, so every `swift test` sees the same
// cases. Longer runs: set DAU_FUZZ_CASES (number of cases, default below) and
// optionally DAU_FUZZ_SEED (base seed), e.g.
//   DAU_FUZZ_CASES=200000 swift test --package-path Packages/DauEngine --filter Fuzz
import Foundation
import Testing
@testable import DauEngine

/// Group 8 — robustness (D18): random operations in every configuration.
///
/// Invariants checked after every operation:
/// - no crash (a trap ends the test run);
/// - a replacement never deletes more than the engine has written for the current
///   word, and the word the engine believes is shown is exactly the tail of the
///   simulated document;
/// - after a successful `seed`, the engine's reading of the text renders to a text
///   canonically equivalent to it (D20: nothing the user did not touch is rewritten).
@Suite("8. Độ bền (D18)")
struct FuzzTests {
    static let defaultCases = 15_000
    static let defaultSeed: UInt64 = 20_261_111

    @Test func randomOperationsKeepTheInvariants() {
        let env = ProcessInfo.processInfo.environment
        let cases = env["DAU_FUZZ_CASES"].flatMap { Int($0) } ?? FuzzTests.defaultCases
        let seed = env["DAU_FUZZ_SEED"].flatMap { UInt64($0) } ?? FuzzTests.defaultSeed
        let configs = FuzzTests.allConfigs
        var failures = 0
        for index in 0..<cases {
            var random = SplitMix(seed: seed, index: UInt64(index))
            let options = configs[index % configs.count]
            let ops = Fuzz.generate(&random, options)
            if let problem = Fuzz.run(ops, options) {
                failures += 1
                if failures <= 5 {
                    Issue.record("""
                        case \(index) (seed \(seed)), \(options): \(problem)
                        ops: \(ops.map(\.description).joined(separator: " "))
                        """)
                }
            }
        }
        #expect(failures == 0, "\(failures) of \(cases) cases broke an invariant")
    }

    /// Input method × free marking × auto restore × advanced × tone placement.
    static let allConfigs: [EngineOptions] = {
        var all: [EngineOptions] = []
        for method in [EngineOptions.InputMethod.telex, .simpleTelex, .vni] {
            for free in [true, false] {
                for restore in [true, false] {
                    for advanced in [EngineOptions.Advanced.off, .consonantShortcuts, .allowZFWJ] {
                        for tone in [EngineOptions.TonePlacement.modern, .classic] {
                            all.append(EngineOptions(
                                inputMethod: method, tonePlacement: tone, freeMarking: free,
                                autoRestore: restore, advanced: advanced))
                        }
                    }
                }
            }
        }
        return all
    }()
}

/// SplitMix64: small, fast, and the same on every machine.
struct SplitMix {
    var state: UInt64
    init(seed: UInt64, index: UInt64) {
        state = seed &* 0x9E37_79B9_7F4A_7C15 &+ index &* 0xBF58_476D_1CE4_E5B9
    }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
    mutating func below(_ n: Int) -> Int { Int(next() % UInt64(n)) }
    mutating func chance(_ percent: Int) -> Bool { below(100) < percent }
    mutating func pick<T>(_ items: [T]) -> T { items[below(items.count)] }
}

enum Fuzz {
    enum Op: CustomStringConvertible {
        case key(Unicode.Scalar)
        case backspace, endWord, reset
        case seed([Unicode.Scalar])
        case seedOverflow(Int)

        var description: String {
            switch self {
            case .key(let k): return escaped([k])
            case .backspace: return "⌫"
            case .endWord: return "⏎"
            case .reset: return "←"
            case .seed(let text): return "<seed:\(escaped(text))>"
            case .seedOverflow(let n): return "<overflow:\(n)>"
            }
        }
    }

    // MARK: Alphabets

    static func scalars(_ s: String) -> [Unicode.Scalar] { Array(s.unicodeScalars) }

    static let telexKeys = scalars("aaaeeeiiooouuuyddwwsfrxjzbcghklmnpqtv")
    static let vniKeys = scalars("aaaeeeiiooouuuydd1234567890bcghklmnpqtv")
    static let letters = scalars("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    static let boundaries = scalars(" \t\n\r.,;:!?-'\"()[]/@#_")
    static let precomposed: [Unicode.Scalar] = {
        var all = scalars("đĐ")
        for v in Letters.composed {
            all.append(Unicode.Scalar(v)!)
            all.append(Unicode.Scalar(Letters.uppercased(v))!)
        }
        return all
    }()
    /// Vietnamese combining marks plus a few foreign ones.
    static let marks: [Unicode.Scalar] = [
        0x300, 0x301, 0x302, 0x303, 0x306, 0x309, 0x31B, 0x323, 0x340, 0x341, 0x308, 0x327,
    ].map { Unicode.Scalar(UInt32($0))! }
    /// Controls, emoji, private use (function keys), foreign letters, specials.
    static let hostile: [Unicode.Scalar] = [
        0x0, 0x1, 0x1B, 0x7F, 0xA0, 0xC4, 0xD7, 0xDF, 0x101, 0x131, 0x200B, 0x200D, 0xFE0F,
        0xFEFF, 0xF700, 0xF8FF, 0xFFFD, 0x1F600, 0x1F1FB, 0x10FFFF, 0x4E2D, 0x0E01,
    ].map { Unicode.Scalar(UInt32($0))! }
    static let words = [
        "việt", "nghiêng", "người", "được", "thuở", "khuỷu", "quyền", "giá", "hoà", "hòa",
        "ĐẮK", "Hà", "cả", "tiê", "q", "d", "đ", "ă", "â", "ươ", "uơ", "qu", "gi", "ngh",
        "foo", "keyboard", "iPhone", "maître", "dû", "naïve", "ŭ", "õ", "a1", "hoc", "viet",
    ]

    // MARK: Generation

    static func key(_ r: inout SplitMix, _ options: EngineOptions, hostileBias: Int) -> Unicode.Scalar {
        let x = r.below(100)
        if x < hostileBias {
            switch r.below(4) {
            case 0: return r.pick(hostile)
            case 1: return r.pick(marks)
            case 2: return r.pick(precomposed)
            default: return r.pick(boundaries)
            }
        }
        if x < hostileBias + 8 { return r.pick(Array(boundaries.prefix(6))) }
        if x < hostileBias + 16 { return r.pick(letters) }
        if x < hostileBias + 20 { return r.pick(precomposed) }
        return r.pick(options.inputMethod == .vni ? vniKeys : telexKeys)
    }

    /// Text as an app could show it before the cursor: NFC, NFD, letters with odd
    /// marks, or random scalars; cut to the last 16 UTF-16 units like the IMK read
    /// (D20), sometimes starting inside a decomposed letter.
    static func seedText(_ r: inout SplitMix) -> [Unicode.Scalar] {
        var text: [Unicode.Scalar]
        switch r.below(5) {
        case 0: text = scalars(r.pick(words))
        case 1: text = scalars(r.pick(words).decomposedStringWithCanonicalMapping)
        case 2:
            text = []
            for _ in 0..<(1 + r.below(6)) {
                text.append(r.chance(70) ? r.pick(scalars("aeiouydAEIOUYnhtcg")) : r.pick(precomposed))
                while r.chance(45) { text.append(r.pick(marks)) }
            }
        case 3:
            text = []
            for _ in 0..<r.below(12) {
                switch r.below(4) {
                case 0: text.append(r.pick(hostile))
                case 1: text.append(r.pick(marks))
                case 2: text.append(r.pick(precomposed))
                default: text.append(r.pick(letters))
                }
            }
        default:
            text = scalars(r.pick(words).decomposedStringWithCanonicalMapping)
                + scalars(r.pick(words))
        }
        if r.chance(25) && !text.isEmpty { text.removeFirst(r.below(text.count)) }
        var units = 0
        var start = text.count
        while start > 0 {
            let width = text[start - 1].utf16.count
            if units + width > 16 { break }
            units += width
            start -= 1
        }
        return Array(text[start...])
    }

    static func generate(_ r: inout SplitMix, _ options: EngineOptions) -> [Op] {
        let length = 1 + r.below(40)
        let hostileBias = r.pick([2, 6, 40])
        var ops: [Op] = []
        if r.chance(20) { ops.append(.seed(seedText(&r))) }
        while ops.count < length {
            let x = r.below(100)
            if x < 9 {
                ops.append(.backspace)
            } else if x < 11 {
                ops.append(.endWord)
            } else if x < 13 {
                ops.append(.reset)
            } else if x < 19 {
                ops.append(.seed(seedText(&r)))
            } else if x < 20 {
                ops.append(.seedOverflow(r.pick([Int.min, -1, 0, 1, 3, 8, 16, Int.max])))
            } else {
                ops.append(.key(key(&r, options, hostileBias: hostileBias)))
            }
        }
        return ops
    }

    // MARK: Model and invariants

    /// Plays `ops` against a simulated document. Returns the first broken invariant.
    static func run(_ ops: [Op], _ options: EngineOptions) -> String? {
        var engine = VietEngine(options: options)
        var doc: [Unicode.Scalar] = []
        /// Where the word the engine tracks starts in `doc`.
        var wordStart = 0

        for (step, op) in ops.enumerated() {
            var action = Action.passThrough
            var typed: Unicode.Scalar?
            switch op {
            case .reset:
                engine.reset()
            case .seedOverflow(let n):
                engine.seedOverflow(shown: n)
                wordStart = doc.count
            case .seed(let text):
                doc.append(contentsOf: text)
                if engine.seed(displayed: text) {
                    wordStart = doc.count - text.count
                    let rendered = Array(engine.render(engine.word))
                    if nfc(rendered) != nfc(text) {
                        return "step \(step): seed read \(escaped(text)) as \(escaped(rendered))"
                    }
                }
            case .backspace:
                let wasTracking = engine.isComposing && !engine.overflow
                action = engine.backspace()
                if case .replace = action, !wasTracking {
                    return "step \(step): ⌫ replaced text outside a tracked word"
                }
                if case .passThrough = action, !doc.isEmpty {
                    // The engine's contract: the app's Delete removes `lastShown`.
                    doc.removeLast()
                }
            case .endWord:
                action = engine.endWord()
            case .key(let k):
                typed = k
                if !engine.isComposing { wordStart = doc.count }
                action = engine.handle(k)
            }
            switch action {
            case .passThrough:
                if let typed { doc.append(typed) }
            case .replace(let deleteCount, let insert):
                if deleteCount < 0 || deleteCount > doc.count - wordStart {
                    return "step \(step): deletes \(deleteCount), the word has \(doc.count - wordStart)"
                }
                doc.removeLast(deleteCount)
                doc.append(contentsOf: insert)
            }
            if wordStart > doc.count { wordStart = doc.count }
            if engine.isComposing && !engine.overflow {
                if engine.shown != Array(doc[wordStart...]) {
                    return "step \(step): engine shows \(escaped(engine.shown)), document word is \(escaped(Array(doc[wordStart...])))"
                }
            } else if !engine.isComposing {
                wordStart = doc.count
            }
        }
        return nil
    }
}
