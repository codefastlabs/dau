import Foundation

/// Sightings of a hidden-text field (D13 "Ô giấu chữ") in in-place mode: the client reports
/// the caret inside the word Dấu just typed, and neither D11's late-answer proof nor held
/// text explains it. Google Docs is one: it answers (1, 0) and shows one character.
///
/// The extra client calls are N3's exception "Ngoại lệ ô giấu chữ": none until a first
/// sighting (`InPlaceComposer.liesInsideTypedWord`, `InPlaceComposer.askAtWordEnd`).
public struct HiddenTextDetector: Equatable {
    /// Off while the app has a rule (D5) or the controller already underlines.
    public var isOn = false
    public private(set) var sightings = 0
    /// After the first sighting, the character that ends that word asks `selectedRange` once.
    public private(set) var asksAtWordEnd = false
    /// UTF-16 units of the word at its sighting: a D11 mismatch in it leaves the engine only
    /// the letters typed after, while the app still shows the whole word.
    private(set) var sightedWordUnits = 0

    static let sightingsToUnderline = 2

    public init() {}

    public var found: Bool { sightings >= Self.sightingsToUnderline }

    /// The answer is a caret inside a word of `wordUnits` UTF-16 units before the caret
    /// (1 ≤ location < length), which no client that counts positions from the start of the
    /// text or line gives. Engine letters are BMP scalars, so a word's scalars are its units.
    static func liesInside(_ answer: NSRange, wordUnits: Int) -> Bool {
        answer.length == 0 && wordUnits >= 2 && answer.location >= 1 && answer.location < wordUnits
    }

    mutating func sight(inWordOf units: Int) {
        sightings = min(sightings + 1, Self.sightingsToUnderline)
        asksAtWordEnd = sightings == 1
        sightedWordUnits = units
    }

    mutating func wordEnded() {
        asksAtWordEnd = false
        sightedWordUnits = 0
    }

    public mutating func forget() {
        sightings = 0
        wordEnded()
    }
}

/// What the hidden-text detector did on one in-place key (Debug perf log, tests).
public struct HiddenTextKey: Equatable {
    /// The `selectedRange` asked at the end of a sighted word.
    public internal(set) var asked = false
    /// The one-unit read before the answer, made when no caret is followed.
    public internal(set) var read = false
    public internal(set) var sighted = false

    /// Perf log fields, each with a leading space, only those set (numbers, D8).
    public var logFields: String {
        (asked ? " hidden_ask=1" : "") + (read ? " hidden_read=1" : "") + (sighted ? " hidden_sight=1" : "")
    }
}

/// Whether a controller types with underline (D13): the app's rule (D5), else the hidden-text
/// field this controller found itself, until the caret shows the field takes in-place text.
///
/// The state lives in the controller of the field: Chrome gives each tab its own controller,
/// so the other tabs keep replacing in place.
public struct AutoUnderline: Equatable {
    /// The app's rule, as D13 orders it: "Underline" always underlines and never returns,
    /// "No underline" turns detection off, no rule detects.
    public enum Rule: Equatable {
        case detect
        case underline
        case noUnderline
    }

    public enum Change: Equatable {
        case on
        case off(OffReason)
    }

    public enum OffReason: String {
        /// The caret grew by exactly the units committed, `exactGrowthsToReturn` commits in a row.
        case caretFollowsCommits = "follows"
        /// The app got a rule.
        case rule
    }

    public private(set) var rule = Rule.detect
    /// This controller underlines because it found a hidden-text field.
    public private(set) var isOn = false
    private var commitChecksLeft = 0
    /// The caret the client gave at the last check, before that key's commit; nil: no baseline.
    private var caretAfterLastCheck: Int?
    /// UTF-16 units inserted since that check (the commit of the checking key included).
    private var unitsSinceLastCheck = 0
    private var exactGrowths = 0

    /// A misdetected field shows itself in the first few words; asking at every word would
    /// cost a call per word and may block on a busy page (D13).
    public static let checkedCommits = 8
    static let exactGrowthsToReturn = 2

    public init() {}

    public var underlines: Bool { rule == .underline || (rule == .detect && isOn) }
    public var detects: Bool { rule == .detect && !isOn }
    /// The next word commit asks `selectedRange` before it is sent (N3 "Ngoại lệ ô giấu chữ").
    public var checksCommits: Bool { rule == .detect && isOn && commitChecksLeft > 0 }

    /// Sets the app's rule. Returns `.off(.rule)` when a rule ends auto underline.
    public mutating func setRule(_ new: Rule) -> Change? {
        rule = new
        guard new != .detect, isOn else { return nil }
        isOn = false
        return .off(.rule)
    }

    /// After an in-place key: underline starts once the detector found the field and the
    /// word ended, so the next word is the first underlined.
    public mutating func afterInPlaceKey(detector: HiddenTextDetector, wordOpen: Bool) -> Change? {
        guard detects, detector.found, !wordOpen else { return nil }
        isOn = true
        commitChecksLeft = Self.checkedCommits
        forgetBaseline()
        return .on
    }

    /// Right before the `insertText` that commits a word with the character that ended it,
    /// during the first `checkedCommits` commits: one `selectedRange`. Asked before the
    /// commit, the page has nothing of this key to apply yet; Safari answers right after an
    /// `insertText` only once the page applied it. Returns whether it asked.
    @discardableResult
    public mutating func beforeWordCommit(client: some InPlaceClient) -> Bool {
        guard checksCommits else { return false }
        commitChecksLeft -= 1
        noteCaret(InPlaceComposer.selectedRange(of: client))
        return true
    }

    /// After an underline-mode key: counts the units it inserted, and returns to in place
    /// once the caret followed them `exactGrowthsToReturn` checks in a row. A key left to
    /// the app moves the caret by an amount Dấu does not know, so the count starts over.
    public mutating func afterMarkedKey(_ outcome: MarkedComposer.Outcome) -> Change? {
        guard rule == .detect, isOn else { return nil }
        guard outcome.consumed else {
            forgetBaseline()
            return nil
        }
        unitsSinceLastCheck += outcome.insertedUnits
        guard exactGrowths >= Self.exactGrowthsToReturn else { return nil }
        isOn = false
        return .off(.caretFollowsCommits)
    }

    /// A reset event (click, activation, client or settings change): the caret may have moved.
    public mutating func textMovedUnseen() {
        forgetBaseline()
    }

    private mutating func noteCaret(_ answer: NSRange) {
        guard answer.location != NSNotFound, answer.length == 0 else {
            forgetBaseline()
            return
        }
        if let last = caretAfterLastCheck, answer.location - last == unitsSinceLastCheck {
            exactGrowths += 1
        } else {
            exactGrowths = 0
        }
        caretAfterLastCheck = answer.location
        unitsSinceLastCheck = 0
    }

    private mutating func forgetBaseline() {
        caretAfterLastCheck = nil
        unitsSinceLastCheck = 0
        exactGrowths = 0
    }
}
