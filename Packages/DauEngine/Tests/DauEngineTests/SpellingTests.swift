import Testing
import DauEngine

/// Group 4 — syllable spelling (D31) and stopping transforms on misspelled words (D30).
@Suite("4. Chính tả âm tiết (D30, D31)")
struct SpellingTests {
    /// D31 c/k/q, g/gh, ng/ngh distribution: misspelled words stop transforming (D30)
    /// and are restored as typed (D4).
    @Test(arguments: [
        Case("ce ", "ce "), Case("ces", "ces"), Case("cis", "cis"),
        // D31 place names: k may stand before any vowel (Kon Tum, Bắc Kạn).
        Case("ka ", "ka "), Case("kas", "ká"), Case("kis", "kí"), Case("kys", "ký"),
        Case("ghu ", "ghu "), Case("ghus", "ghus"), Case("ghis", "ghí"), Case("ghees", "ghế"),
        Case("ngi ", "ngi "), Case("ngif", "ngif"), Case("nghix", "nghĩ"),
        Case("ges", "ges"), Case("gaf", "gà"),
        Case("qa ", "qa "), Case("qas", "qas"), Case("quas", "quá"),
    ])
    func initialDistribution(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31: "p" is an initial (pin, pa-tê).
    @Test(arguments: [Case("pin ", "pin "), Case("pins ", "pín "), Case("pa ", "pa ")])
    func initialP(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31: stop finals p, t, c, ch take only sắc or nặng; without a tone they are not
    /// valid either. While typing only the prefix matters (D30), so the tone shows;
    /// the full rule applies at the boundary.
    @Test(arguments: [
        Case("catf", "càt"), Case("catf ", "catf "), Case("capf ", "capf "),
        Case("cacr ", "cacr "), Case("cachx ", "cachx "),
        Case("bak ", "bak "), Case("bach ", "bach "), Case("hoc ", "hoc "),
        Case("vieet ", "vieet "),  // "viêt" without a tone is not a syllable.
        Case("cats ", "cát "), Case("hocj ", "học "), Case("cachs ", "cách "),
        Case("carcs", "các"),      // tone typed before the final, changed later
    ])
    func stopFinals(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31: ă and â do not end a syllable; D30: they are fine while typing. A word
    /// longer than one letter that ends in ă or â is still restored (D4).
    @Test(arguments: [
        Case("traw", "tră"), Case("traw ", "traw "), Case("trawngf ", "trằng "),
        Case("caan ", "cân "), Case("traa ", "traa "), Case("hoaw ", "hoaw "),
        Case("uaa ", "uaa "), Case("ddaa ", "ddaa "), Case("ddaw.", "ddaw."),
        Case("aab ", "aab "), Case("aaz ", "aaz "), Case("dds ", "dds "),
    ])
    func breveAndCircumflexNeedFinal(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31 "Chữ cái đứng một mình": a word that is exactly one letter ă or â (with or
    /// without a tone) or đ is kept at the boundary, upper or lower case.
    @Test(arguments: [
        Case("aw ", "ă "), Case("aa ", "â "), Case("dd ", "đ "),
        Case("aas ", "ấ "), Case("aws ", "ắ "),
        Case("aaf ", "ầ "), Case("aar ", "ẩ "), Case("aax ", "ẫ "), Case("aaj ", "ậ "),
        Case("awf ", "ằ "), Case("awr ", "ẳ "), Case("awx ", "ẵ "), Case("awj ", "ặ "),
        Case("asa ", "ấ "), Case("afw ", "ằ "),      // tone first (D28)
        Case("aasz ", "â "),                          // z removes the tone, the letter stays
        Case("AW, AA, DD. ", "Ă, Â, Đ. "), Case("Aa ", "Â "), Case("AAS ", "Ấ "),
        Case("aA ", "â "), Case("Dd ", "Đ "), Case("dD ", "đ "), Case("aW ", "ă "),   // D34
        Case("aw, aa, dd, ee, oo, ow, uw. ", "ă, â, đ, ê, ô, ơ, ư. "),
        Case("DD/c ", "Đ/c "), Case("dd.", "đ."), Case("DD.", "Đ."),
        Case("a, aw, aa, b, c, d, dd, e, ee ", "a, ă, â, b, c, d, đ, e, ê "),
    ])
    func loneLetters(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31 lone letters: every printed boundary (D4) and `endWord()` keep them.
    @Test(arguments: [",", ".", "!", "?", "(", ")", "\"", ";", ":", "'", "-", "/", "[", "]", "\t", "\n"])
    func loneLettersAtEveryBoundary(_ boundary: String) {
        expectTyped("aw" + boundary, "ă" + boundary)
        expectTyped("aa" + boundary, "â" + boundary)
        expectTyped("dd" + boundary, "đ" + boundary)
        expectTyped("AAS" + boundary, "Ấ" + boundary)
    }

    @Test func loneLettersThroughEndWord() {
        expectTyped("aw⏎", "ă\n")
        expectTyped("dd⏎", "đ\n")
        expectTyped("aas⏎", "ấ\n")
    }

    /// D31 lone letters × D26: a double key gives the keys back, and the lock holds while
    /// the double key's letter is shown.
    @Test(arguments: [
        Case("aaa ", "aa "), Case("ddd ", "dd "), Case("AAA ", "AA "), Case("DDD ", "DD "),
        Case("aww ", "aw "), Case("AWW ", "AW "),
        Case("aaas ", "aas "), Case("ddda ", "dda "), Case("awws ", "aws "), Case("dddd ", "ddd "),
        Case("aass ", "âs "),                 // D26 baseline: the text shown after the double
        Case("aaa⌫ ", "a "), Case("aaa⌫a ", "â "), Case("ddd⌫d ", "đ "),   // ⌫ of the letter releases it
        Case("aaas⌫ ", "aa "), Case("aaas⌫s ", "aas "),                    // the letter is still shown
        Case("aaa⌫⌫aa ", "â "),              // word deleted: the lock is gone
    ])
    func loneLettersAndDoubleKeys(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31 lone letters × D32: after ⌫ the rule looks at the letters left.
    @Test(arguments: [
        Case("aa⌫ ", " "), Case("dd⌫ ", " "), Case("aas⌫ ", " "),
        Case("aab⌫ ", "â "), Case("dda⌫ ", "đ "), Case("awn⌫, ", "ă, "), Case("aasn⌫ ", "ấ "),
        Case("aa⌫aa ", "â "), Case("dd⌫d ", "d "), Case("da⌫d ", "đ "),
    ])
    func loneLettersAndBackspace(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31 lone letters: the plain letters and the other single vowels are as before.
    @Test(arguments: [
        Case("a ", "a "), Case("d ", "d "), Case("A ", "A "), Case("D ", "D "),
        Case("ee ", "ê "), Case("oo ", "ô "), Case("ow ", "ơ "), Case("uw ", "ư "), Case("w ", "ư "),
        Case("banana ", "banana "), Case("windows ", "windows "), Case("dda ", "đa "),
    ])
    func loneLettersLeaveTheRestAlone(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31 lone letters with the other input methods and options.
    @Test func loneLettersAcrossOptions() {
        for options in [simpleTelex, noFreeMarking, classic, shortcuts, zfwj] {
            expectTyped("aw, aa, dd. ", "ă, â, đ. ", options)
            expectTyped("AW AA DD/c ", "Ă Â Đ/c ", options)
            expectTyped("aas aws ", "ấ ắ ", options)
            expectTyped("aaa ddd aww ", "aa dd aw ", options)
            expectTyped("traw traa ", "traw traa ", options)
        }
        expectTyped("w ", "w ", simpleTelex)
        // autoRestore off: nothing was restored before either.
        expectTyped("aw aa dd traw ", "ă â đ tră ", noRestore)
    }

    /// D30: once the word cannot become a syllable, later keys are plain letters.
    @Test(arguments: [
        Case("Sunrise", "Sủnise"), Case("windows", "ưindows"), Case("banana", "bânna"),
        Case("banana ", "banana "), Case("lazy ", "lazy "), Case("fanf", "fanf"),
        Case("jas", "jas"), Case("zas", "zas"),
    ])
    func stopTransforming(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31: iê without an initial is written yê; yê after a consonant needs the u of
    /// uyê (or qu); c never takes oa, oă, oe, uy, uê, uâ (written qu). Misspelled forms
    /// stop transforming and are restored; the valid spellings next to them stay.
    @Test(arguments: [
        Case("ieen ", "ieen "), Case("ieeu ", "ieeu "), Case("ieens", "ieens"),
        Case("tyeen ", "tyeen "), Case("tyeens", "tyeens"),
        Case("coa ", "coa "), Case("coas", "coas"), Case("coan ", "coan "), Case("coawn ", "coawn "),
        Case("coe ", "coe "), Case("cuy ", "cuy "), Case("cuys", "cuys"), Case("cuee ", "cuee "),
        Case("cuaan ", "cuaan "),
    ])
    func misspelledRhymes(_ c: Case) { expectTyped(c.keys, c.expected) }

    @Test(arguments: [
        Case("yeen ", "yên "), Case("yeeu ", "yêu "), Case("khuyeen ", "khuyên "),
        Case("tuyeets ", "tuyết "), Case("quyeenr ", "quyển "), Case("quar ", "quả "),
        Case("quy ", "quy "), Case("hoa ", "hoa "), Case("khoer ", "khoẻ "), Case("cuar ", "của "),
        Case("cuoons ", "cuốn "), Case("cuowps ", "cướp "), Case("kieens ", "kiến "),
        Case("ia ", "ia "), Case("uyeen ", "uyên "), Case("gieets ", "giết "),
    ])
    func validCounterparts(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31, place names: k before any vowel, the initial "kr", and final k after ă.
    @Test(arguments: [
        Case("DDawks Lawks", "Đắk Lắk"), Case("DDawks Lawks ", "Đắk Lắk "),
        Case("Bawsc Kajn ", "Bắc Kạn "), Case("Kroong Pawsc ", "Krông Pắc "),
        Case("Kow Tu ", "Kơ Tu "), Case("Kon Tum ", "Kon Tum "),
        Case("lawk ", "lawk "),   // "ăk" is a stop rhyme: without sắc/nặng it is restored
    ])
    func placeNames(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// Accepted consequences of the D31 place-name rules (measured on a 428-word list):
    /// these English words now spell a valid syllable, or start one, so Vietnamese wins
    /// (D4) or a later key counts as a double (D26).
    @Test(arguments: [
        Case("karma ", "kẩm "), Case("Kansas ", "Kâns "), Case("Kris ", "Krí "),
        Case("hawks ", "hắk "), Case("gawks ", "gắk "), Case("awkward ", "akward "),
    ])
    func placeNameSideEffects(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// Final k is not accepted elsewhere, so these stay as typed.
    @Test(arguments: [
        Case("ask ", "ask "), Case("task ", "task "), Case("desk ", "desk "), Case("hawk ", "hawk "),
        Case("back ", "back "), Case("tracks ", "tracks "), Case("squawk ", "squawk "),
        Case("Jack ", "Jack "), Case("risks ", "risks "),
    ])
    func englishWordsWithK(_ c: Case) { expectTyped(c.keys, c.expected) }

    /// D31: final k is accepted only when ă already stands before it; a later breve
    /// does not turn "ak" into "ăk", so these stay as typed.
    @Test func breveMustPrecedeFinalK() {
        expectTyped("lakws ", "lakws ")
        expectTyped("lak81 ", "lak81 ", vni)
        expectTyped("Lawks ", "Lắk ")
        expectTyped("asks ", "asks ")
        expectTyped("tasks ", "tasks ")
    }

    /// Rhyme table spot checks: valid rhymes stay, invalid clusters are restored.
    @Test(arguments: [
        Case("khuyas ", "khuýa "), Case("oangf ", "oàng "), Case("hoawcj ", "hoặc "),
        Case("ngoeos ", "ngoéo "), Case("yeeu ", "yêu "), Case("uoongs ", "uống "),
        Case("ooa ", "ooa "), Case("aoa ", "aoa "), Case("ieu ", "ieu "),
        Case("thuowr ", "thuở "), Case("huow ", "huơ "),
    ])
    func rhymes(_ c: Case) { expectTyped(c.keys, c.expected) }
}
