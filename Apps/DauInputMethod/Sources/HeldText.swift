/// The text a field that holds only the word before the caret gives the input method, as
/// the input method works it out from the text it knows before the caret (D11 "Ô chỉ giữ
/// từ trước con trỏ"; `docs/research/MonacoInput.md`, sections 2 and 6).
///
/// The rule is Monaco's for its hidden textarea when its screen reader mode is off (the
/// editor of Cursor): the word right before the caret, stopped by `editor.wordSeparators`
/// (default value), whitespace or the start of the line, at most `limit` units; with no
/// word there, the one character before the caret. The caret is at the end of that text,
/// so its length is the position the field answers and the end of every range it takes.
struct HeldText: Equatable {
    /// UTF-16 units the field holds: where its caret is.
    var length: Int
    /// The last units of that text the input method knows, oldest first; all of it when
    /// `isWhole`.
    var known: [UInt16]

    var isWhole: Bool { known.count == length }

    /// Monaco stops looking back for the word after 50 units, so the word holds one more.
    static let limit = 51

    /// What precedes the text the input method knows.
    enum Head: Equatable {
        /// Nothing known: the word may go on before it.
        case unknown
        /// The start of a line: nothing before.
        case lineStart
        /// A unit that is not part of a word, or the start of a line.
        case boundary
        /// This many units of a word, unknown, then a boundary.
        case wordUnits(Int)
    }

    /// The text held after `known` (the text right before the caret, oldest first) with
    /// `head` before it; nil when it depends on what the input method does not know.
    static func held(after known: [UInt16], head: Head) -> HeldText? {
        var run = 0
        while run < known.count, run < limit, isWordUnit(known[known.count - 1 - run]) { run += 1 }
        if run == limit { return HeldText(length: limit, known: Array(known.suffix(limit))) }
        if run < known.count {
            if run > 0 { return HeldText(length: run, known: Array(known.suffix(run))) }
            // No word: the one character before the caret, unless it is half of a pair.
            let last = known[known.count - 1]
            return UTF16.isLeadSurrogate(last) ? HeldText(length: 0, known: []) : HeldText(length: 1, known: [last])
        }
        // Every unit known is part of the word: what came before decides.
        switch head {
        case .unknown:
            return nil
        case .lineStart:
            return HeldText(length: run, known: known)
        case .boundary:
            return run > 0 ? HeldText(length: run, known: known) : nil
        case .wordUnits(let units):
            if units <= 0 { return run > 0 ? HeldText(length: run, known: known) : nil }
            return HeldText(length: min(units + run, limit), known: Array(known.suffix(min(run, limit))))
        }
    }

    /// The default value of Monaco's `editor.wordSeparators`. With whitespace and line
    /// breaks, these end a word; every other unit is part of one (letters with marks,
    /// digits, `_`, typographic quotes and dashes).
    private static let separators = Set("`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?".utf16)

    static func isWordUnit(_ unit: UInt16) -> Bool {
        switch unit {
        case 0x20, 0x09, 0x0A, 0x0D: return false
        default: return !separators.contains(unit)
        }
    }

    /// `read`, the text before `location` a field holding the text before its caret gave,
    /// as known text and what precedes it; nil when it cannot be such a text (the read
    /// gives fewer units than that position and some of them are not part of a word).
    static func anchored(read: [UInt16], at location: Int) -> (known: [UInt16], head: Head)? {
        guard location >= 0, read.count <= location else { return nil }
        if location == 0 { return ([], .lineStart) }
        let word = read.allSatisfy(isWordUnit)
        if read.count == location {
            // The whole of it: a word, shorter than `limit`, so a boundary is before it; or
            // the one character before the caret.
            if word { return (read, .boundary) }
            return read.count == 1 ? (read, .unknown) : nil
        }
        return word ? (read, .wordUnits(location - read.count)) : nil
    }
}
