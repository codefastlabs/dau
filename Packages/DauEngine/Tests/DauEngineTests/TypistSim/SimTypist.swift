// The simulated typist: types sentences word by word with the keys of its profile, makes
// mistakes and corrects them the way people do, looking at the screen (TypistSimTests).
import Foundation
import DauEngine

/// A word of a corpus sentence.
struct SimToken: Sendable {
    var core: [Unicode.Scalar]
    /// Punctuation typed after the word (ends it, D4).
    var trail: [Unicode.Scalar]
    var word: SimWord
    /// An English or code word: ASCII and not a Vietnamese syllable (D31).
    var english: Bool
    var text: String {
        var v = String.UnicodeScalarView()
        v.append(contentsOf: core + trail)
        return String(v)
    }

    static let punctuation = Set(".,?!:;".unicodeScalars)

    static func tokenize(_ sentence: String) -> [SimToken] {
        sentence.split(separator: " ").map { piece in
            var core = Array(String(piece).precomposedStringWithCanonicalMapping.unicodeScalars)
            var trail: [Unicode.Scalar] = []
            while let last = core.last, punctuation.contains(last) { trail.insert(core.removeLast(), at: 0) }
            guard let word = SimWord.parse(core) else { fatalError("corpus word not parsable: \(piece)") }
            let english = core.allSatisfy(\.isASCII)
                && !ExternalCasesTests.validSyllable(core[...], allowZFWJ: false)
            return SimToken(core: core, trail: trail, word: word, english: english)
        }
    }
}

/// What happened to one word.
struct SimEpisode: Sendable {
    var token: SimToken
    var error: SimError?
    var correction: SimCorrection?
    var style: SimFixStyle?
    /// The mistake left no trace on screen (nothing to correct).
    var absorbed = false
    /// The typist's natural fix did not give the intended word.
    var deadEnd = false
    var deadEndPattern = ""
    var deadEndScreen = ""
    var retyped = false
    /// Retyping the whole word after a dead end still did not give the word.
    var retypeFailed = false
    /// Keys of this word from its first key up to the failed fix, in Typist notation.
    var deadEndScript: [Unicode.Scalar] = []
    /// Keys pressed for this word (letters, marks, ⌫, punctuation, space), and the least
    /// the word needs in the typist's order.
    var keysTyped = 0
    var minKeys = 0
    /// Needs the input method to read the word back (⌫ over the space, D20).
    var outOfScope = false
    /// On an ideal input method, where every correction works: right unless left.
    var ideal = true
    /// Clean keys (no mistake) in the profile's order did not give the word.
    var orderFellBack = false
    /// An English or code word the engine changes even when typed without a mistake
    /// (D4 (Từ nước ngoài), D26 (Gõ đúp phím dấu)): not a correction failure.
    var alteredAnyway = false
    /// The sentence came out with a different number of words, so this one is counted wrong.
    var misaligned = false
    /// Final text of the field at this word is the intended word.
    var correct = false
}

/// Which typing orders give each word without mistakes (English words: their letters as
/// they are); cached per run.
struct SimOrderCache {
    var works: [String: Bool] = [:]
    var failures: [String] = []

    mutating func works(_ token: SimToken, _ order: SimOrder, _ options: EngineOptions) -> Bool {
        let id = "\(options.inputMethod)|\(order.rawValue)|\(token.word.plain)|\(token.text)"
        if let known = works[id] { return known }
        let keys = token.english ? SimKeys.literal(token.word) : SimKeys.keys(token.word, order, options.inputMethod)
        var f = EngineField(options)
        for k in keys { f.press(k.key) }
        f.press(" ")
        let ok = SimTypist<EngineField>.matches(f.text.dropLast(), token)
        works[id] = ok
        if !ok && !token.english {
            var v = String.UnicodeScalarView()
            v.append(contentsOf: keys.map(\.key))
            var out = String.UnicodeScalarView()
            out.append(contentsOf: f.text.dropLast())
            failures.append("\(order.label): \(String(v)) → \(String(out)) (muốn \(token.text))")
        }
        return ok
    }
}

struct SimTypist<F: SimField> {
    let profile: SimProfile
    let options: EngineOptions
    var field: F
    var script: [Unicode.Scalar] = []

    init(_ profile: SimProfile, _ options: EngineOptions) {
        self.profile = profile
        self.options = options
        field = F(options)
    }

    var method: EngineOptions.InputMethod { options.inputMethod }

    mutating func press(_ key: Unicode.Scalar) {
        field.press(key)
        script.append(key)
    }

    mutating func press(_ keys: [SimKey]) { for k in keys { press(k.key) } }

    /// The word right before the caret (after the last space).
    var screen: ArraySlice<Unicode.Scalar> {
        let text = field.text
        let start = text.lastIndex(of: " ").map { $0 + 1 } ?? 0
        return text[start...]
    }

    var screenWord: SimWord? { SimWord.parse(screen) }

    mutating func deleteScreenWord() {
        for _ in 0..<screen.count { press("⌫") }
    }

    // MARK: Sentence

    /// Types one sentence into a fresh field. `sentence` seeds every random choice, so the
    /// engine-only and the mirror field get the same mistakes and reactions.
    static func run(_ tokens: [SimToken], profile: SimProfile, options: EngineOptions,
                    seed: UInt64, sentence: Int, cache: inout SimOrderCache) -> [SimEpisode] {
        var t = SimTypist<F>(profile, options)
        var r = SplitMix(seed: seed, index: UInt64(sentence) &* 1024)
        let order = r.weighted(profile.orders)
        var episodes: [SimEpisode] = []
        for (i, token) in tokens.enumerated() {
            var wr = SplitMix(seed: seed, index: UInt64(sentence) &* 1024 &+ UInt64(i) &+ 1)
            episodes.append(t.typeWord(token, order: order, &wr, cache: &cache))
        }
        // Final check, word by word.
        let out = t.field.text.split(separator: " ", omittingEmptySubsequences: true)
        for i in episodes.indices {
            guard out.count == episodes.count else { episodes[i].misaligned = true; continue }
            let token = episodes[i].token
            let piece = Array(out[i])
            if piece == token.core + token.trail {
                episodes[i].correct = true
            } else if piece.count >= token.trail.count, Array(piece.suffix(token.trail.count)) == token.trail {
                episodes[i].correct = SimWord.parse(piece.dropLast(token.trail.count)) == token.word
                    && !token.english
            }
        }
        return episodes
    }

    // MARK: Word

    mutating func typeWord(_ token: SimToken, order chosen: SimOrder, _ r: inout SplitMix,
                           cache: inout SimOrderCache) -> SimEpisode {
        script = []
        var e = SimEpisode(token: token)
        var order = chosen
        if token.english {
            e.alteredAnyway = !cache.works(token, order, options)
        } else if !cache.works(token, order, options) {
            e.orderFellBack = true
            order = .standard
        }
        let clean = token.english ? SimKeys.literal(token.word) : SimKeys.keys(token.word, order, method)
        let trail = token.trail.map { SimKey(key: $0, role: .letter(-1)) }
        e.minKeys = clean.count + trail.count + 1
        let modsAtEnd = order == .modifierAtEnd

        // Every draw happens whatever the screen shows, so both fields stay in step.
        let hasError = r.percent(profile.errorPercent)
        let kind = r.weighted(profile.errors)
        let correction = r.weighted(profile.corrections)
        let style: SimFixStyle = r.chance(profile.markKeysPercent) ? .markKeys : .backspaceToError
        let atOnce = r.chance(profile.noticeAtOncePercent)
        let retype = r.chance(profile.retypeAfterDeadEndPercent)
        var er = SplitMix(seed: r.next(), index: 0)

        guard hasError, let (bad, errorEnd) = Self.inject(kind, clean, token, method, &er) else {
            press(clean)
            press(trail)
            press(" ")
            e.keysTyped = script.count
            return e
        }
        e.error = kind
        e.correction = correction

        // A mistake that leaves no trace once the word ends needs no fix.
        var probe = EngineField(options)
        for k in bad { probe.press(k.key) }
        probe.press(" ")
        if Self.matches(probe.text.dropLast(), token) {
            e.absorbed = true
            press(bad)
            press(trail)
            press(" ")
            e.keysTyped = script.count
            return e
        }

        // Tone mistakes are seen at the end of the word; letter mistakes at once or there.
        let toneMistake = kind == .missingTone || kind == .wrongTone || kind == .doubleTone
        let noticed = Array(bad.prefix(toneMistake || !atOnce ? bad.count : errorEnd))
        switch correction {
        case .giveUp:
            e.ideal = false
            press(bad)
        case .retypeWord:
            press(noticed)
            deleteScreenWord()
            press(clean)
            if !endsRight(token) && !e.alteredAnyway {
                e.deadEnd = true
                e.retypeFailed = true
                noteDeadEnd(&e, Self.pattern(kind, correction, nil, wordAtEnd, token))
            }
        case .immediate, .afterSpace:
            e.style = style
            if correction == .immediate {
                press(noticed)
            } else {
                e.outOfScope = true
                press(bad)
                press(trail)
                press(" ")
                for _ in 0...trail.count { press("⌫") }
            }
            repair(token, style: style, modsAtEnd: modsAtEnd)
            if !endsRight(token) && !e.alteredAnyway {
                e.deadEnd = true
                noteDeadEnd(&e, Self.pattern(kind, correction, style, wordAtEnd, token))
                if retype {
                    e.retyped = true
                    deleteScreenWord()
                    press(clean)
                    if !endsRight(token) { e.retypeFailed = true }
                }
            }
        }
        press(trail)
        press(" ")
        e.keysTyped = script.count
        return e
    }

    mutating func noteDeadEnd(_ e: inout SimEpisode, _ pattern: String) {
        e.deadEndPattern = pattern
        e.deadEndScript = script
        var v = String.UnicodeScalarView()
        v.append(contentsOf: wordAtEndScalars)
        e.deadEndScreen = String(v)
    }

    /// The word before the caret as it will be once the word ends (D4 may restore it):
    /// what the typist sees after the next space.
    var wordAtEndScalars: ArraySlice<Unicode.Scalar> {
        var copy = field
        copy.press(" ")
        let text = copy.text.dropLast()
        let start = text.lastIndex(of: " ").map { $0 + 1 } ?? text.startIndex
        return text[start...]
    }

    var wordAtEnd: SimWord? { SimWord.parse(wordAtEndScalars) }

    func endsRight(_ token: SimToken) -> Bool { Self.matches(wordAtEndScalars, token) }

    static func matches(_ screen: ArraySlice<Unicode.Scalar>, _ token: SimToken) -> Bool {
        if token.english { return Array(screen) == token.core }
        return SimWord.parse(screen) == token.word
    }

    // MARK: Correction

    /// Whether what is on screen can stay while fixing toward `want`.
    static func acceptable(_ s: SimWord, _ want: SimWord, _ style: SimFixStyle) -> Bool {
        guard s.letters.count <= want.letters.count else { return false }
        for (a, b) in zip(s.letters, want.letters) {
            guard a.base == b.base else { return false }
            switch style {
            case .backspaceToError:
                if a.mod != b.mod { return false }
            case .markKeys:
                let vowelMods: [SimMod] = [.hat, .breve, .horn]
                let ok = a.mod == b.mod || a.mod == .none
                    || (vowelMods.contains(a.mod) && vowelMods.contains(b.mod))
                if !ok { return false }
            }
        }
        if style == .backspaceToError && s.tone != .none && s.tone != want.tone { return false }
        return true
    }

    /// The fix a person makes on the word before the caret: delete what is wrong, type the
    /// missing letters, then the missing modifier and tone keys (D28 lets them go anywhere).
    mutating func repair(_ token: SimToken, style: SimFixStyle, modsAtEnd: Bool) {
        let want = token.word
        var guardCount = 0
        while !screen.isEmpty && guardCount < 40 {
            if let s = screenWord, token.english ? Array(screen) == Array(token.core.prefix(screen.count))
                : Self.acceptable(s, want, style) { break }
            press("⌫")
            guardCount += 1
        }
        let have = screen.isEmpty ? 0 : (screenWord?.letters.count ?? 0)
        if token.english {
            press(SimKeys.literal(want).dropFirst(have).map { $0 })
            return
        }
        press(SimKeys.letterKeys(want, from: have, modsAtEnd: modsAtEnd, method))
        if let s = screenWord, s.letters.count == want.letters.count {
            var j = 0
            while j < want.letters.count {
                let a = s.letters[j], b = want.letters[j]
                if a.mod != b.mod && b.mod != .none {
                    press(SimKeys.modKey(b, b.mod, method))
                    // One horn key covers "ươ" and "ưu".
                    if b.mod == .horn, j + 1 < want.letters.count, want.letters[j + 1].mod == .horn,
                       s.letters[j + 1].mod != .horn { j += 1 }
                }
                j += 1
            }
        }
        if let s = screenWord, s.letters == want.letters, s.tone != want.tone {
            press(SimKeys.toneKey(want.tone, method))
        }
    }

    static func pattern(_ kind: SimError, _ c: SimCorrection, _ style: SimFixStyle?,
                        _ s: SimWord?, _ token: SimToken) -> String {
        let want = token.word
        var outcome = "sai chữ"
        if let s {
            let bases = s.letters.map(\.base), wantBases = want.letters.map(\.base)
            if s.letters == want.letters {
                outcome = s.tone == .none ? "mất dấu thanh" : "sai dấu thanh"
            } else if bases == wantBases {
                outcome = "sai dấu phụ"
            } else if bases.count == wantBases.count + 1 && Array(bases.prefix(wantBases.count)) == wantBases {
                outcome = "thừa chữ cuối"
            }
        } else {
            outcome = "không còn là chữ"
        }
        let how = style.map { "\(c.label), \($0.label)" } ?? c.label
        return "\(kind.label) · \(how) → \(outcome)\(token.english ? " (từ tiếng Anh)" : "")"
    }

    // MARK: Mistakes

    /// The keys with one mistake, and how many keys it takes to have made it; nil when the
    /// mistake does not apply to the word.
    static func inject(_ kind: SimError, _ clean: [SimKey], _ token: SimToken,
                       _ method: EngineOptions.InputMethod, _ r: inout SplitMix) -> ([SimKey], Int)? {
        if token.english && !kind.appliesToEnglish { return nil }
        var keys = clean
        let letterIdx = keys.indices.filter {
            if case .letter = keys[$0].role { return keys[$0].key.properties.isAlphabetic }
            return false
        }
        let toneIdx = keys.firstIndex { $0.role == .tone && token.word.tone != .none }
        switch kind {
        case .missingTone:
            guard let i = toneIdx else { return nil }
            keys.remove(at: i)
            return (keys, keys.count)
        case .wrongTone:
            guard let i = toneIdx else { return nil }
            var other = SimTone(rawValue: 1 + r.below(5))!
            if other == token.word.tone { other = SimTone(rawValue: other.rawValue % 5 + 1)! }
            keys[i].key = SimKeys.toneKey(other, method)
            return (keys, i + 1)
        case .doubleTone:
            guard let i = toneIdx else { return nil }
            keys.insert(keys[i], at: i + 1)
            return (keys, i + 2)
        case .wrongModifier:
            let candidates = keys.indices.filter {
                guard case .mod(let l) = keys[$0].role else { return false }
                let letter = token.word.letters[l]
                let base = letter.base.value | 0x20
                return (base == 0x61 || base == 0x6F) && letter.mod != .bar
            }
            guard !candidates.isEmpty else { return nil }
            let i = candidates[r.below(candidates.count)]
            guard case .mod(let l) = keys[i].role else { return nil }
            let letter = token.word.letters[l]
            let isA = letter.base.value | 0x20 == 0x61
            let other: SimMod = letter.mod == .hat ? (isA ? .breve : .horn) : .hat
            keys[i].key = SimKeys.modKey(letter, other, method)
            return (keys, i + 1)
        case .adjacentKey:
            guard !letterIdx.isEmpty else { return nil }
            let i = letterIdx[r.below(letterIdx.count)]
            let n = SimKeys.neighbour(keys[i].key, &r)
            guard n != keys[i].key else { return nil }
            keys[i].key = n
            return (keys, i + 1)
        case .extraLetter:
            guard !letterIdx.isEmpty else { return nil }
            let i = letterIdx[r.below(letterIdx.count)]
            let extra = r.chance(50) ? keys[i].key : SimKeys.neighbour(keys[i].key, &r)
            keys.insert(SimKey(key: extra, role: keys[i].role), at: i + 1)
            return (keys, i + 2)
        case .missingLetter:
            guard letterIdx.count >= 2 else { return nil }
            let i = letterIdx[r.below(letterIdx.count)]
            keys.remove(at: i)
            return (keys, min(i + 1, keys.count))
        case .transposed:
            let pairs = letterIdx.filter { letterIdx.contains($0 + 1) && keys[$0].key != keys[$0 + 1].key }
            guard !pairs.isEmpty else { return nil }
            let i = pairs[r.below(pairs.count)]
            keys.swapAt(i, i + 1)
            return (keys, i + 2)
        }
    }
}
