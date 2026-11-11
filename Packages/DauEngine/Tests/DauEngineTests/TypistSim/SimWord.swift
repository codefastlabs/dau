// Words as letters, and the keys a typist presses for them (TypistSimTests).
import Foundation
import DauEngine

enum SimMod: Equatable, Sendable { case none, hat, breve, horn, bar }

/// Tone marks in VNI digit order (1 sắc … 5 nặng).
enum SimTone: Int, Equatable, Sendable { case none = 0, acute, grave, hook, tilde, dot }

struct SimLetter: Equatable, Sendable {
    /// ASCII letter or digit, with its case.
    var base: Unicode.Scalar
    var mod: SimMod
    var isVowel: Bool { "aeiouyAEIOUY".unicodeScalars.contains(base) }
}

/// A word read as letters with modifiers and one tone. Two words are equal when their
/// letters and tone are equal, wherever the tone sits ("hoà" == "hòa"), like the scorer
/// of scripts/research/compare-ims/cases.swift.
struct SimWord: Equatable, Sendable {
    var letters: [SimLetter] = []
    var tone: SimTone = .none
    /// Letter carrying the tone, -1 for none.
    var toneIndex = -1

    static func == (a: SimWord, b: SimWord) -> Bool { a.letters == b.letters && a.tone == b.tone }

    /// Nil if `text` holds anything but letters and digits Vietnamese spelling knows.
    static func parse<S: Sequence>(_ text: S) -> SimWord? where S.Element == Unicode.Scalar {
        var w = SimWord()
        var view = String.UnicodeScalarView()
        view.append(contentsOf: text)
        for ch in String(view).decomposedStringWithCanonicalMapping.unicodeScalars {
            switch ch.value {
            case 0x302: guard !w.letters.isEmpty else { return nil }; w.letters[w.letters.count - 1].mod = .hat
            case 0x306: guard !w.letters.isEmpty else { return nil }; w.letters[w.letters.count - 1].mod = .breve
            case 0x31B: guard !w.letters.isEmpty else { return nil }; w.letters[w.letters.count - 1].mod = .horn
            case 0x301, 0x300, 0x309, 0x303, 0x323:
                guard !w.letters.isEmpty, w.tone == .none else { return nil }
                w.tone = [0x301: .acute, 0x300: .grave, 0x309: .hook, 0x303: .tilde, 0x323: .dot][ch.value]!
                w.toneIndex = w.letters.count - 1
            case 0x111: w.letters.append(SimLetter(base: "d", mod: .bar))
            case 0x110: w.letters.append(SimLetter(base: "D", mod: .bar))
            case 0x30...0x39, 0x41...0x5A, 0x61...0x7A: w.letters.append(SimLetter(base: ch, mod: .none))
            default: return nil
            }
        }
        return w.letters.isEmpty ? nil : w
    }

    var plain: String {
        var view = String.UnicodeScalarView()
        view.append(contentsOf: letters.map(\.base))
        return String(view)
    }
}

/// What a key is for, so mistakes can be put at the right place.
enum SimRole: Equatable, Sendable { case letter(Int), mod(Int), tone }

struct SimKey: Equatable, Sendable {
    var key: Unicode.Scalar
    var role: SimRole
}

enum SimKeys {
    typealias Method = EngineOptions.InputMethod

    static func modKey(_ letter: SimLetter, _ mod: SimMod, _ method: Method) -> Unicode.Scalar {
        if method == .vni {
            switch mod {
            case .hat: return "6"
            case .horn: return "7"
            case .breve: return "8"
            case .bar: return "9"
            case .none: return "0"
            }
        }
        switch mod {
        case .hat: return Unicode.Scalar(letter.base.value | 0x20)!   // aa ee oo, lower case
        case .breve, .horn: return "w"
        case .bar: return "d"
        case .none: return "z"
        }
    }

    static func toneKey(_ tone: SimTone, _ method: Method) -> Unicode.Scalar {
        if method == .vni { return Unicode.Scalar(UInt8(0x30 + tone.rawValue)) }
        return ["z", "s", "f", "r", "x", "j"][tone.rawValue]
    }

    /// Keys for letters `from...`, without the tone. Modifiers go right after their letter,
    /// or at the end when `modsAtEnd` (horn on "uo" and "uu" pairs takes one key there).
    static func letterKeys(_ w: SimWord, from start: Int, modsAtEnd: Bool, _ method: Method) -> [SimKey] {
        var keys: [SimKey] = []
        var tail: [SimKey] = []
        var i = start
        while i < w.letters.count {
            let l = w.letters[i]
            keys.append(SimKey(key: l.base, role: .letter(i)))
            if l.mod != .none {
                let k = SimKey(key: modKey(l, l.mod, method), role: .mod(i))
                // Telex users keep "dd" at the start even when the vowel marks go last.
                if modsAtEnd && !(l.mod == .bar && method != .vni) {
                    let pairedHorn = l.mod == .horn && i > start && w.letters[i - 1].mod == .horn
                    if !pairedHorn { tail.append(k) }
                } else {
                    keys.append(k)
                }
            }
            i += 1
        }
        return keys + tail
    }

    /// Clean keys for a whole word in `order`.
    static func keys(_ w: SimWord, _ order: SimOrder, _ method: Method) -> [SimKey] {
        var keys = letterKeys(w, from: 0, modsAtEnd: order == .modifierAtEnd, method)
        guard w.tone != .none else { return keys }
        let tone = SimKey(key: toneKey(w.tone, method), role: .tone)
        switch order {
        case .toneAtEnd, .modifierAtEnd:
            keys.append(tone)
        case .standard, .toneAfterVowel:
            let target = order == .standard
                ? (w.letters.lastIndex(where: \.isVowel) ?? w.letters.count - 1)
                : w.toneIndex
            // After the target letter and its modifier key.
            var at = keys.count
            if let i = keys.lastIndex(where: { $0.role == .letter(target) || $0.role == .mod(target) }) {
                at = i + 1
            }
            keys.insert(tone, at: at)
        }
        return keys
    }

    /// The letters a plain English or code word is typed with.
    static func literal(_ w: SimWord) -> [SimKey] {
        w.letters.enumerated().map { SimKey(key: $0.element.base, role: .letter($0.offset)) }
    }

    static let neighbours: [Unicode.Scalar: String] = [
        "q": "wa", "w": "qeas", "e": "wrsd", "r": "etdf", "t": "ryfg", "y": "tugh", "u": "yihj",
        "i": "uojk", "o": "ipkl", "p": "ol", "a": "qwsz", "s": "awedxz", "d": "serfcx",
        "f": "drtgvc", "g": "ftyhbv", "h": "gyujnb", "j": "huikmn", "k": "jiolm", "l": "kop",
        "z": "asx", "x": "zsdc", "c": "xdfv", "v": "cfgb", "b": "vghn", "n": "bhjm", "m": "njk",
    ]

    /// A key next to `key` on a QWERTY keyboard, same case; `key` itself for digits.
    static func neighbour(_ key: Unicode.Scalar, _ r: inout SplitMix) -> Unicode.Scalar {
        let upper = key.value >= 0x41 && key.value <= 0x5A
        let lower = Unicode.Scalar(key.value | (upper ? 0x20 : 0))!
        guard let options = neighbours[lower] else { return key }
        let pick = Array(options.unicodeScalars)[r.below(options.unicodeScalars.count)]
        return upper ? Unicode.Scalar(pick.value & ~0x20)! : pick
    }
}

extension SplitMix {
    mutating func weighted<T>(_ items: [(T, Int)]) -> T {
        let total = items.reduce(0) { $0 + $1.1 }
        var roll = below(max(total, 1))
        for (item, weight) in items {
            if roll < weight { return item }
            roll -= weight
        }
        return items[items.count - 1].0
    }

    mutating func percent(_ p: Double) -> Bool { Double(below(10_000)) < p * 100 }
}
