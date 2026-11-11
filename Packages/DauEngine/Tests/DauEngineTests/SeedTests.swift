import Foundation
import Testing
@testable import DauEngine

/// Group 6 — "Thêm dấu cho từ đã gõ" (D20): the engine is seeded from the text shown
/// in the app (read as letters), then the key is handled.
@Suite("6. Thêm dấu cho từ đã gõ (D20)")
struct SeedTests {
    struct SeedCase: Sendable, CustomTestStringConvertible {
        let displayed: String
        let keys: String
        let expected: String
        init(_ displayed: String, _ keys: String, _ expected: String) {
            self.displayed = displayed
            self.keys = keys
            self.expected = expected
        }
        var testDescription: String { "\(displayed) + \(keys) → \(expected)" }
    }

    /// D20 × D31 "Chữ cái đứng một mình": a letter already in the app plus a transform
    /// key gives a one-letter word, kept at the boundary like the typed one.
    @Test(arguments: [
        SeedCase("a", "a ", "â "), SeedCase("a", "w ", "ă "), SeedCase("d", "d ", "đ "),
        SeedCase("A", "a ", "Â "), SeedCase("D", "d.", "Đ."),
        SeedCase("â", "s ", "ấ "), SeedCase("ă", "f ", "ằ "), SeedCase("a", "as ", "ấ "),
        SeedCase("â", " ", "â "), SeedCase("đ", " ", "đ "),
        SeedCase("â", "a ", "aa "),         // D26 on a seeded word: the double undoes
        SeedCase("đ", "d ", "dd "),
        SeedCase("tr", "aw ", "traw "),     // longer words are restored as before
    ])
    func loneLetters(_ c: SeedCase) {
        var t = Typist()
        do { let result = t.seed(c.displayed); #expect(result) }
        t.type(c.keys)
        #expect(t.text.map(\.value) == scalars(c.expected), "gave \"\(t.string)\"")
    }

    @Test(arguments: [
        SeedCase("hoc", "j", "học"),
        SeedCase("dep", "j", "dẹp"),        // not "đẹp": no transform is added (D20)
        SeedCase("car", "s", "cars"),       // "cár" is invalid → the key goes straight
        SeedCase("viet", "j", "vietj"),     // "viẹt" is invalid
        SeedCase("viet", "ej", "việt"),     // "viêt" first, then j
        SeedCase("Viet", "ej", "Việt"),
        SeedCase("tuong", "w", "tương"),
        SeedCase("di", "d", "đi"),
        SeedCase("hoa", "f", "hoà"),
        SeedCase("học", "z", "hoc"),
        SeedCase("học", "s", "hóc"),
        SeedCase("hòa", "s", "hoá"),        // re-placed in the current (modern) style
        SeedCase("nha", "fk ", "nhafk "),   // D4: baseline = seeded text + keys typed after
        SeedCase("nha", "f ", "nhà "),
        SeedCase("tra", "w", "tră"),        // valid start of a syllable (D20 uses the D30 prefix level)
        SeedCase("viet", "e", "viêt"),
        SeedCase("cả", "r", "car"),         // D20 + D26: a double key undoes the tone
        SeedCase("cả", "r ", "car "),       // D4: the baseline after the double is the text shown
        SeedCase("cả", "rs", "cars"),       // D26: locked until the word ends
        SeedCase("hoc", "f", "hòc"),        // D30 prefix: the tone can still change…
        SeedCase("hoc", "f ", "hocf "),     // …but "hòc" is not a syllable at the boundary (D31)
        SeedCase("tra", "w ", "traw "),     // …but not a syllable at the boundary
    ])
    func seeded(_ c: SeedCase) {
        var t = Typist()
        do { let result = t.seed(c.displayed); #expect(result) }
        t.type(c.keys)
        #expect(t.text.map(\.value) == scalars(c.expected), "got \"\(t.string)\"")
    }

    /// Text read from an app may be decomposed (NFD); output is always NFC (D3) and
    /// the replacement covers the decomposed scalars.
    @Test func decomposedInput() {
        var t = Typist()
        do { let result = t.seed("vie\u{0302}t"); #expect(result) }
        t.type("j")
        #expect(t.text.map(\.value) == scalars("việt"))

        var u = Typist()
        do { let result = u.seed("ho\u{0323}c"); #expect(result) }
        u.type("s")
        #expect(u.text.map(\.value) == scalars("hóc"))
    }

    /// D20 exception (b) + D33: a word the engine cannot seed (here 8 letters) takes the
    /// keys typed after it unchanged until it ends, like an over-long word typed here.
    @Test func seedOverflowPassesTheRestOfTheWord() {
        var t = Typist()
        t.text.append(contentsOf: "keyboard".unicodeScalars)
        t.engine.seedOverflow(shown: 8)
        #expect(t.engine.isComposing && t.engine.lastShown == nil && !t.engine.isSpellingLocked)
        t.type("bars ")
        #expect(t.string == "keyboardbars ")
        #expect(!t.engine.isComposing)
        // The next word is Vietnamese again.
        t.type("vieetj")
        #expect(t.string == "keyboardbars việt")

        // ⌫ over the whole word (8 shown + 1 typed) ends the state; less keeps it.
        var u = Typist()
        u.text.append(contentsOf: "keyboard".unicodeScalars)
        u.engine.seedOverflow(shown: 8)
        u.type("b⌫⌫")
        #expect(u.engine.isComposing)
        u.type("⌫⌫⌫⌫⌫⌫⌫")
        #expect(!u.engine.isComposing)
        u.type("vieetj")
        #expect(u.string == "việt")

        var e = VietEngine()
        e.seedOverflow(shown: 0)
        #expect(!e.isComposing)
    }

    @Test func rejectsWhatCannotBeAWord() {
        var engine = VietEngine()
        do { let result = engine.seed(displayed: "Sunrisee".unicodeScalars); #expect(!result) }   // 8 letters (D33)
        do { let result = engine.seed(displayed: "a-b".unicodeScalars); #expect(!result) }
        do { let result = engine.seed(displayed: "".unicodeScalars); #expect(!result) }
        do { let result = engine.seed(displayed: "\u{0301}a".unicodeScalars); #expect(!result) }
        #expect(!engine.isComposing)
    }

    /// D20 exception (b): a combining modifier mark the engine cannot place in a
    /// Vietnamese letter (circumflex only on a/e/o, breve only on a, horn only on o/u)
    /// is a letter the engine does not know. Seeding fails and the key goes straight,
    /// as with the precomposed "maître" + s.
    @Test(arguments: [
        SeedCase("mai\u{302}tre", "s", "mai\u{302}tres"),
        SeedCase("maître", "s", "maîtres"),
        SeedCase("i\u{302}le", "s", "i\u{302}les"),
        SeedCase("du\u{302}", "t", "du\u{302}t"),
        SeedCase("hodiau\u{306}", "n", "hodiau\u{306}n"),
        SeedCase("u\u{306}", "s", "u\u{306}s"),
        SeedCase("bo\u{306}", "s", "bo\u{306}s"),
        SeedCase("a\u{31B}", "n", "a\u{31B}n"),
        SeedCase("E\u{31B}", "s", "E\u{31B}s"),
        SeedCase("y\u{302}", "s", "y\u{302}s"),
        // A circumflex or breve written after a tone mark above the same letter is
        // not canonically "ấ" (both have combining class 230).
        SeedCase("a\u{301}\u{302}", "f", "a\u{301}\u{302}f"),
        SeedCase("á\u{306}", "f", "á\u{306}f"),
    ])
    func rejectsMarksNotInVietnamese(_ c: SeedCase) {
        var t = Typist()
        do { let result = t.seed(c.displayed); #expect(!result) }
        #expect(!t.engine.isComposing)
        t.type(c.keys)
        #expect(t.text.map(\.value) == scalars(c.expected), "got \"\(t.string)\"")
    }

    /// The marks in their Vietnamese pairs still seed, in either canonical order.
    @Test(arguments: [
        SeedCase("a\u{302}", "s", "ấ"), SeedCase("e\u{302}", "s", "ế"), SeedCase("O\u{302}", "s", "Ố"),
        SeedCase("a\u{306}", "n", "ăn"), SeedCase("A\u{306}", "f", "Ằ"),
        SeedCase("o\u{31B}", "s", "ớ"), SeedCase("u\u{31B}", "s", "ứ"), SeedCase("U\u{31B}", "f", "Ừ"),
        SeedCase("a\u{302}\u{301}", "f", "ầ"),          // NFD order of "ấ"
        SeedCase("a\u{323}\u{302}", "n", "ận"),         // NFD order of "ậ": dot below first
        SeedCase("o\u{31B}\u{323}", "i", "ợi"),         // NFD order of "ợ"
        SeedCase("o\u{301}\u{31B}", "f", "ờ"),          // horn after the tone reorders
        SeedCase("ọ\u{302}", "i", "ội"),                // precomposed ọ + circumflex = ộ
        SeedCase("ó\u{31B}", "f", "ờ"),                 // precomposed ó + horn = ớ
    ])
    func acceptsVietnameseMarks(_ c: SeedCase) {
        var t = Typist()
        do { let result = t.seed(c.displayed); #expect(result) }
        t.type(c.keys)
        #expect(t.text.map(\.value) == scalars(c.expected), "got \"\(t.string)\"")
    }

    /// Invariant: when `seed` accepts a text, the word it builds renders to a text
    /// canonically equivalent to it. Otherwise the next key would rewrite letters the
    /// user never touched.
    @Test(arguments: [
        "việt", "nghiêng", "người", "được", "thuở", "khuỷu", "quyền", "ĐẮK", "Hà", "cả",
        "ươ", "uơ", "ưo", "gi", "qu", "ă", "â", "đ", "a1", "U23",
        "maître", "dû", "naïve", "über", "ŭ", "õ", "ỹ", "î", "ô", "Ô", "ç", "ñ", "keyboard",
    ])
    func seededWordRendersAsTheText(_ word: String) {
        for text in [word, word.decomposedStringWithCanonicalMapping] {
            let input = Array(text.unicodeScalars)
            var e = VietEngine()
            guard e.seed(displayed: input) else { continue }
            let rendered = Array(e.render(e.word))
            #expect(nfc(rendered) == nfc(input), "\(escaped(input)) read as \(escaped(rendered))")
        }
    }

    /// D18: an absurd count from the IMK layer cannot overflow the counter; it is
    /// clamped, so typing and deleting stay well defined.
    @Test func seedOverflowClampsTheCount() {
        for shown in [Int.max, Int.max - 1, VietEngine.overflowShownLimit, VietEngine.overflowShownLimit + 1] {
            var t = Typist()
            t.engine.seedOverflow(shown: shown)
            #expect(t.engine.overflowShown == VietEngine.overflowShownLimit)
            t.type("abc")
            #expect(t.engine.overflowShown == VietEngine.overflowShownLimit)
            t.type("⌫")
            #expect(t.engine.isComposing && t.string == "ab")
            t.type(" ")
            #expect(!t.engine.isComposing)
        }
        for shown in [Int.min, -1, 0] {
            var e = VietEngine()
            e.seedOverflow(shown: shown)
            #expect(!e.isComposing)
            #expect(e.handle("a") == .passThrough)
        }
    }

    /// The table above, with expected acceptance, so the invariant is not vacuous.
    @Test func seedAcceptance() {
        for (text, accepted) in [
            ("vie\u{302}\u{323}t", true), ("ngu\u{31B}o\u{31B}\u{300}i", true), ("I\u{302}", false),
            ("du\u{302}", false), ("u\u{306}", false), ("a\u{31B}", false), ("na\u{308}ive", false),
            ("ü", false), ("c\u{327}a", false), ("o\u{303}", true),
        ] {
            var e = VietEngine()
            #expect(e.seed(displayed: text.unicodeScalars) == accepted, "\(escaped(Array(text.unicodeScalars)))")
        }
    }
}

/// NFC of a scalar list (tests only: the engine itself has no Foundation, D10).
func nfc(_ text: [Unicode.Scalar]) -> [Unicode.Scalar] {
    var view = String.UnicodeScalarView()
    view.append(contentsOf: text)
    return Array(String(view).precomposedStringWithCanonicalMapping.unicodeScalars)
}

/// Scalars with everything outside printable ASCII written as \u{…}, for messages.
func escaped(_ text: [Unicode.Scalar]) -> String {
    var out = ""
    for s in text {
        if s.value >= 0x21 && s.value < 0x7F { out.unicodeScalars.append(s) }
        else { out += "\\u{" + String(s.value, radix: 16, uppercase: true) + "}" }
    }
    return out
}
