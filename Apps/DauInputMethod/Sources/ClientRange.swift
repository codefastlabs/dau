import Foundation

/// Bounds every range and position a client answers before any arithmetic (D18).
///
/// A client may answer NSNotFound, a negative value, or one so large that `location + length`
/// would trap. Anything outside 0...`limit` is taken as no document access: nothing is
/// replaced or read at it, and the key starts a word on its own (D11).
enum ClientRange {
    /// Largest location, length or end accepted from a client: far beyond any text field,
    /// and low enough that a position at the limit plus anything this module adds to it
    /// stays far from Int.max.
    static let limit = Int(Int32.max)

    /// The answer "no document access".
    static let notFound = NSRange(location: NSNotFound, length: NSNotFound)

    /// `range` when it is usable, `notFound` otherwise.
    static func sanitized(_ range: NSRange) -> NSRange {
        isUsable(range) ? range : notFound
    }

    /// Location, length and end are all in 0...`limit`.
    static func isUsable(_ range: NSRange) -> Bool {
        let location = range.location, length = range.length
        guard location >= 0, length >= 0, location <= limit, length <= limit else { return false }
        return location + length <= limit  // both are at most Int32.max: no overflow
    }

    static func isUsable(position: Int) -> Bool {
        position >= 0 && position <= limit
    }
}

extension Int {
    /// `self + other`, clamped instead of trapping (D18).
    func addingSaturated(_ other: Int) -> Int {
        let (sum, overflow) = addingReportingOverflow(other)
        guard overflow else { return sum }
        return other > 0 ? .max : .min
    }

    /// `self - other`, clamped instead of trapping (D18).
    func subtractingSaturated(_ other: Int) -> Int {
        let (difference, overflow) = subtractingReportingOverflow(other)
        guard overflow else { return difference }
        return other < 0 ? .max : .min
    }
}
