// Counts and tables of the typist simulator (TypistSimTests).
import Foundation

struct SimErrorStats: Sendable {
    var episodes = 0
    var correct = 0
    var extraKeys = 0
    var deadEnds = 0
    var left = 0
    var absorbed = 0
}

struct SimPattern: Sendable {
    var count = 0
    var script: [Unicode.Scalar] = []
    var screen = ""
    var intended = ""
}

/// Totals for one profile, input method and field.
struct SimStats: Sendable {
    var sentences = 0
    var words = 0
    var correct = 0
    var ideal = 0
    var inScope = 0
    var inScopeCorrect = 0
    var inScopeIdeal = 0
    /// In-scope English words wrong even though typed without a mistake (D4, D26).
    var inScopeAlteredAnyway = 0
    /// In-scope words with a mistake the typist corrected that still came out wrong.
    var inScopeFixFailed = 0
    /// In-scope words typed without a mistake that came out wrong, besides the above.
    var inScopeCleanWrong = 0
    var keys = 0
    var minKeys = 0
    var english = 0
    var englishAltered = 0
    var englishAlteredWords: [String: Int] = [:]
    var mistakes = 0
    var absorbed = 0
    var left = 0
    var deadEnds = 0
    var retyped = 0
    var retypeFailed = 0
    var outOfScope = 0
    var outOfScopeCorrect = 0
    var orderFallbacks = 0
    var misaligned = 0
    var perError: [SimError: SimErrorStats] = [:]
    var patterns: [String: SimPattern] = [:]
    /// Corrections after the space per mistake: (episodes, right at the end).
    var afterSpace: [SimError: (Int, Int)] = [:]

    mutating func add(_ episodes: [SimEpisode]) {
        sentences += 1
        for e in episodes {
            words += 1
            if e.correct { correct += 1 }
            if e.ideal { ideal += 1 }
            if e.outOfScope {
                outOfScope += 1
                if e.correct { outOfScopeCorrect += 1 }
            } else {
                inScope += 1
                if e.correct { inScopeCorrect += 1 }
                if e.ideal { inScopeIdeal += 1 }
                if e.alteredAnyway && !e.correct && e.ideal { inScopeAlteredAnyway += 1 }
                if e.error != nil && !e.absorbed && e.ideal && !e.correct && !e.alteredAnyway { inScopeFixFailed += 1 }
                if (e.error == nil || e.absorbed) && !e.correct && !e.alteredAnyway { inScopeCleanWrong += 1 }
            }
            keys += e.keysTyped
            minKeys += e.minKeys
            if e.orderFellBack { orderFallbacks += 1 }
            if e.misaligned { misaligned += 1 }
            if e.token.english {
                english += 1
                if !e.correct && e.ideal && !e.outOfScope {
                    englishAltered += 1
                    englishAlteredWords[e.token.text, default: 0] += 1
                }
            }
            guard let kind = e.error else { continue }
            mistakes += 1
            if e.absorbed { absorbed += 1 }
            if !e.ideal { left += 1 }
            if e.retyped { retyped += 1 }
            if e.retypeFailed { retypeFailed += 1 }
            if e.outOfScope {
                var a = afterSpace[kind] ?? (0, 0)
                a.0 += 1
                if e.correct { a.1 += 1 }
                afterSpace[kind] = a
                continue
            }
            var s = perError[kind, default: SimErrorStats()]
            s.episodes += 1
            if e.correct { s.correct += 1 }
            s.extraKeys += e.keysTyped - e.minKeys
            if e.deadEnd { s.deadEnds += 1 }
            if !e.ideal { s.left += 1 }
            if e.absorbed { s.absorbed += 1 }
            perError[kind] = s
            if e.deadEnd {
                deadEnds += 1
                record(e)
            }
        }
    }

    /// Dead ends of the corrections the mirror field ran (⌫ over the space).
    mutating func addOutOfScopeDeadEnds(_ episodes: [SimEpisode]) {
        for e in episodes where e.outOfScope && e.deadEnd {
            deadEnds += 1
            record(e)
        }
    }

    mutating func record(_ e: SimEpisode) {
        var p = patterns[e.deadEndPattern, default: SimPattern()]
        p.count += 1
        if p.script.isEmpty || e.deadEndScript.count < p.script.count {
            p.script = e.deadEndScript
            p.screen = e.deadEndScreen
            p.intended = e.token.text
        }
        patterns[e.deadEndPattern] = p
    }

    mutating func merge(_ o: SimStats) {
        sentences += o.sentences; words += o.words; correct += o.correct; ideal += o.ideal
        inScope += o.inScope; inScopeAlteredAnyway += o.inScopeAlteredAnyway; inScopeFixFailed += o.inScopeFixFailed; inScopeCleanWrong += o.inScopeCleanWrong; inScopeCorrect += o.inScopeCorrect; inScopeIdeal += o.inScopeIdeal
        keys += o.keys; minKeys += o.minKeys; english += o.english; englishAltered += o.englishAltered
        mistakes += o.mistakes; absorbed += o.absorbed; left += o.left; deadEnds += o.deadEnds
        retyped += o.retyped; retypeFailed += o.retypeFailed; outOfScope += o.outOfScope
        outOfScopeCorrect += o.outOfScopeCorrect; orderFallbacks += o.orderFallbacks
        misaligned += o.misaligned
        for (k, v) in o.englishAlteredWords { englishAlteredWords[k, default: 0] += v }
        for (k, v) in o.perError {
            var s = perError[k, default: SimErrorStats()]
            s.episodes += v.episodes; s.correct += v.correct; s.extraKeys += v.extraKeys
            s.deadEnds += v.deadEnds; s.left += v.left; s.absorbed += v.absorbed
            perError[k] = s
        }
        for (k, v) in o.afterSpace {
            let a = afterSpace[k] ?? (0, 0)
            afterSpace[k] = (a.0 + v.0, a.1 + v.1)
        }
        for (k, v) in o.patterns {
            var p = patterns[k, default: SimPattern()]
            p.count += v.count
            if p.script.isEmpty || (!v.script.isEmpty && v.script.count < p.script.count) {
                p.script = v.script; p.screen = v.screen; p.intended = v.intended
            }
            patterns[k] = p
        }
    }
}

enum SimReport {
    static func pct(_ a: Int, _ b: Int) -> String {
        b == 0 ? "–" : String(format: "%.2f", 100 * Double(a) / Double(b))
    }

    static func show(_ keys: [Unicode.Scalar]) -> String {
        var v = String.UnicodeScalarView()
        v.append(contentsOf: keys.map { $0 == " " ? "␣" : $0 })
        return String(v)
    }

    /// One row per profile: the engine field for everything in scope, the mirror field for
    /// the corrections after the space.
    static func profileTable(_ rows: [(String, SimStats, SimStats)]) -> String {
        var out = """
            | Hồ sơ | Từ | % đúng (engine, trong phạm vi) | % đúng lý tưởng | Phần của Dấu (điểm %) | trong đó: từ tiếng Anh gõ đúng phím vẫn bị đổi | trong đó: sửa lỗi không thành | trong đó: gõ không lỗi vẫn sai | Phần người gõ (điểm %) | Phím thừa / 100 từ | Phím thừa so với tối thiểu | Ngõ cụt / 1000 từ | Từ tiếng Anh bị đổi | Lỗi để lại | Ngoài phạm vi engine (đúng nhờ mô hình IMK) |
            |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

            """
        for (name, s, m) in rows {
            let actual = Double(s.inScopeCorrect) / Double(max(s.inScope, 1)) * 100
            let ideal = Double(s.inScopeIdeal) / Double(max(s.inScope, 1)) * 100
            let extra = m.keys - m.minKeys
            out += "| \(name) | \(s.words) | \(String(format: "%.2f", actual)) | \(String(format: "%.2f", ideal)) "
            let anyway = Double(s.inScopeAlteredAnyway) / Double(max(s.inScope, 1)) * 100
            out += "| \(String(format: "%.2f", ideal - actual)) | \(String(format: "%.2f", anyway)) "
            let fix = Double(s.inScopeFixFailed) / Double(max(s.inScope, 1)) * 100
            let cleanWrong = Double(s.inScopeCleanWrong) / Double(max(s.inScope, 1)) * 100
            out += "| \(String(format: "%.2f", fix)) | \(String(format: "%.2f", cleanWrong)) | \(String(format: "%.2f", 100 - ideal)) "
            out += "| \(String(format: "%.1f", 100 * Double(extra) / Double(max(s.words, 1)))) "
            out += "| \(pct(extra, m.minKeys))% "
            out += "| \(String(format: "%.2f", 1000 * Double(s.deadEnds) / Double(max(s.words, 1)))) "
            out += "| \(s.englishAltered)/\(s.english) "
            out += "| \(s.left) "
            out += "| \(m.outOfScope) (\(pct(m.outOfScopeCorrect, m.outOfScope))%) |\n"
        }
        return out
    }

    static func errorTable(_ s: SimStats, _ mirror: SimStats) -> String {
        var out = """
            | Lỗi | Lần (trong phạm vi) | % từ đúng cuối cùng | Phím thừa trung bình | Ngõ cụt | Để lại | Không để lại dấu vết | Sau dấu cách: lần (đúng nhờ mô hình IMK) |
            |---|---|---|---|---|---|---|---|

            """
        for kind in SimError.allCases {
            let e = s.perError[kind] ?? SimErrorStats()
            let after = mirror.afterSpace[kind] ?? (0, 0)
            out += "| \(kind.label) | \(e.episodes) | \(pct(e.correct, e.episodes)) "
            out += "| \(e.episodes == 0 ? "–" : String(format: "%.2f", Double(e.extraKeys) / Double(e.episodes))) "
            out += "| \(e.deadEnds) | \(e.left) | \(e.absorbed) | \(after.0) (\(pct(after.1, after.0))%) |\n"
        }
        return out
    }

    static func patternTable(_ s: SimStats, top: Int) -> String {
        var out = "| Mẫu ngõ cụt | Lần | Chuỗi phím ngắn nhất | Ra | Muốn |\n|---|---|---|---|---|\n"
        for (name, p) in s.patterns.sorted(by: { $0.value.count > $1.value.count }).prefix(top) {
            out += "| \(name) | \(p.count) | `\(show(p.script))` | \(p.screen) | \(p.intended) |\n"
        }
        return out
    }
}

