// Typist profiles for the simulator (TypistSimTests).
//
// Every number below is an assumption ("giả định") until it is replaced by a sourced
// value from docs/research/EditingTypedText.md (typist profiles). To replace one, change
// the value in the profile and its comment; nothing else in the simulator holds numbers
// about people.

/// The order in which a typist puts the keys of a Vietnamese word (D28 (Bỏ dấu tự do)).
enum SimOrder: Int, CaseIterable, Sendable {
    /// Modifier right after its vowel, tone after the last vowel of the word, before the
    /// final consonants ("hoafng", "nguwowif", "tieesng").
    case standard
    /// Modifier right after its vowel, tone key at the end of the word ("tieengs").
    case toneAtEnd
    /// Tone key right after the vowel that carries it ("tieesng", "hofa").
    case toneAfterVowel
    /// Base letters first, vowel modifiers at the end, then the tone ("tuongw", "tienges";
    /// VNI also puts 9 for đ at the end: "duoc795"). Telex keeps "dd" at the start.
    case modifierAtEnd

    var label: String {
        switch self {
        case .standard: "chuẩn"
        case .toneAtEnd: "dấu cuối từ"
        case .toneAfterVowel: "dấu sau nguyên âm"
        case .modifierAtEnd: "biến đổi cuối từ"
        }
    }
}

/// One mistake injected into a word.
enum SimError: Int, CaseIterable, Sendable {
    case missingTone, wrongTone, wrongModifier, adjacentKey, extraLetter, missingLetter
    case transposed, doubleTone

    var label: String {
        switch self {
        case .missingTone: "thiếu dấu thanh"
        case .wrongTone: "sai dấu thanh"
        case .wrongModifier: "sai dấu phụ (oo/ow)"
        case .adjacentKey: "gõ nhầm phím bên cạnh"
        case .extraLetter: "thừa chữ"
        case .missingLetter: "thiếu chữ"
        case .transposed: "đảo hai chữ"
        case .doubleTone: "lỡ gõ đúp phím dấu"
        }
    }

    /// Only letter mistakes happen on English and code words.
    var appliesToEnglish: Bool {
        switch self {
        case .adjacentKey, .extraLetter, .missingLetter, .transposed: true
        default: false
        }
    }
}

/// What the typist does about a mistake.
enum SimCorrection: Int, CaseIterable, Sendable {
    /// Notices inside the word and fixes it there (⌫ or a mark key, see `SimFixStyle`).
    case immediate
    /// Notices after the space, ⌫ back over it and fixes the word. Needs the input method
    /// to read the word back (D20 (Thêm dấu cho từ đã gõ)): outside the engine's scope.
    case afterSpace
    /// Notices later or never, and leaves the mistake.
    case giveUp
    /// Notices inside the word, deletes the whole word and types it again.
    case retypeWord

    var label: String {
        switch self {
        case .immediate: "sửa ngay trong từ"
        case .afterSpace: "sửa sau dấu cách"
        case .giveUp: "bỏ qua"
        case .retypeWord: "xoá cả từ gõ lại"
        }
    }
}

/// How a typist fixes a word they are still in.
enum SimFixStyle: Int, CaseIterable, Sendable {
    /// Keeps the letters that are right and types the missing or right mark key where the
    /// caret is (D28: "hoc" + j, "tơ" + o → "tô").
    case markKeys
    /// Deletes back until everything on screen is right (D32 moves the tone while
    /// deleting), then types the rest of the word again.
    case backspaceToError

    var label: String {
        switch self {
        case .markKeys: "phím dấu tại chỗ"
        case .backspaceToError: "⌫ tới chỗ sai"
        }
    }
}

/// One simulated kind of typist. All weights are relative; percentages are 0–100.
struct SimProfile: Sendable {
    var name: String
    /// Share of each typing order, chosen per sentence (one person keeps one habit).
    var orders: [(SimOrder, Int)]
    /// Percentage of words that get one mistake.
    var errorPercent: Double
    /// Share of each mistake among the words that get one.
    var errors: [(SimError, Int)]
    /// Share of each reaction to a mistake.
    var corrections: [(SimCorrection, Int)]
    /// Percentage of in-word fixes made with mark keys rather than ⌫ to the mistake.
    var markKeysPercent: Int
    /// Percentage of letter mistakes noticed on the next key rather than at the word's end.
    var noticeAtOncePercent: Int
    /// Percentage of failed fixes after which the typist deletes and retypes the word.
    var retypeAfterDeadEndPercent: Int
    /// Percentage of fixes made from the keys the typist remembers typing rather than from
    /// the word on screen. After the space: ⌫ over it, then the fix they would have made
    /// inside the word ("ddep␣⌫j" for a forgotten tone, though D4 shows "ddep"). Inside an
    /// English or code word, whose letters Telex shows changed until it ends ("ưith"): one
    /// ⌫ per key typed since the mistake, then the right keys ("withq⌫"). The rest delete
    /// back to what is right on screen first.
    var byKeysPercent: Int = 50

    static let all: [SimProfile] = [.beginner, .ordinary, .skilled, .veryFast]

    /// Người mới tập gõ. Giả định: chưa có nguồn.
    static let beginner = SimProfile(
        name: "người mới",
        orders: [(.toneAfterVowel, 50), (.standard, 30), (.toneAtEnd, 20)],   // giả định
        errorPercent: 15,                                                      // giả định
        errors: [(.missingTone, 20), (.wrongTone, 15), (.wrongModifier, 15), (.adjacentKey, 15),
                 (.extraLetter, 10), (.missingLetter, 10), (.transposed, 5), (.doubleTone, 10)],  // giả định
        corrections: [(.immediate, 50), (.afterSpace, 20), (.giveUp, 15), (.retypeWord, 15)],  // giả định
        markKeysPercent: 30,               // giả định
        noticeAtOncePercent: 60,           // giả định
        retypeAfterDeadEndPercent: 80,     // giả định
        byKeysPercent: 50        // giả định
    )

    /// Người gõ bình thường. Giả định: chưa có nguồn.
    static let ordinary = SimProfile(
        name: "bình thường",
        orders: [(.standard, 40), (.toneAtEnd, 40), (.toneAfterVowel, 15), (.modifierAtEnd, 5)],  // giả định
        errorPercent: 8,                                                       // giả định
        errors: [(.missingTone, 15), (.wrongTone, 10), (.wrongModifier, 10), (.adjacentKey, 25),
                 (.extraLetter, 15), (.missingLetter, 10), (.transposed, 10), (.doubleTone, 5)],  // giả định
        corrections: [(.immediate, 55), (.afterSpace, 20), (.giveUp, 15), (.retypeWord, 10)],  // giả định
        markKeysPercent: 50,               // giả định
        noticeAtOncePercent: 50,           // giả định
        retypeAfterDeadEndPercent: 70,     // giả định
        byKeysPercent: 50        // giả định
    )

    /// Người gõ thạo. Giả định: chưa có nguồn.
    static let skilled = SimProfile(
        name: "thạo",
        orders: [(.toneAtEnd, 60), (.standard, 20), (.modifierAtEnd, 20)],    // giả định
        errorPercent: 4,                                                       // giả định
        errors: [(.missingTone, 10), (.wrongTone, 10), (.wrongModifier, 5), (.adjacentKey, 30),
                 (.extraLetter, 15), (.missingLetter, 10), (.transposed, 15), (.doubleTone, 5)],  // giả định
        corrections: [(.immediate, 65), (.afterSpace, 20), (.giveUp, 5), (.retypeWord, 10)],   // giả định
        markKeysPercent: 80,               // giả định
        noticeAtOncePercent: 70,           // giả định
        retypeAfterDeadEndPercent: 90,     // giả định
        byKeysPercent: 50        // giả định
    )

    /// Người gõ rất nhanh. Giả định: chưa có nguồn.
    static let veryFast = SimProfile(
        name: "rất nhanh",
        orders: [(.toneAtEnd, 60), (.modifierAtEnd, 30), (.standard, 10)],    // giả định
        errorPercent: 10,                                                      // giả định
        errors: [(.missingTone, 10), (.wrongTone, 5), (.wrongModifier, 5), (.adjacentKey, 25),
                 (.extraLetter, 15), (.missingLetter, 15), (.transposed, 20), (.doubleTone, 5)],  // giả định
        corrections: [(.immediate, 40), (.afterSpace, 30), (.giveUp, 20), (.retypeWord, 10)],  // giả định
        markKeysPercent: 80,               // giả định
        noticeAtOncePercent: 40,           // giả định
        retypeAfterDeadEndPercent: 60,     // giả định
        byKeysPercent: 50        // giả định
    )
}
