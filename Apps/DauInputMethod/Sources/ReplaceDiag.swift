#if DEBUG
import Foundation
import InputMethodKit
import os

/// Debug only: positions involved in one in-place replacement, logged in category
/// "diag" to find why some apps end up with wrong text (D11, `selectedRange` on every replacing key).
///
/// D8: numbers only (UTF-16 offsets and lengths) plus the client's bundle ID. Never the
/// text typed, inserted or read from the client.
struct ReplaceDiag {
    static let logger = Logger(subsystem: PerfLog.subsystem, category: "diag")

    var deleteCount: Int
    /// What `selectedRange()` returned before the replacement.
    var selection: NSRange
    /// Where the tracker expected the cursor (nil: unknown, first replacement of a word).
    var expected: Int?
    /// Where the tracker followed the cursor to across words (nil: unknown); differs from
    /// `selection` when the app answered late (kind `late`).
    var known: Int?
    /// UTF-16 length of the text inserted.
    var insertedLength: Int
    /// The `replacementRange` sent, or nil when nothing was sent (mismatch, unsupported).
    var replacement: NSRange?
    /// The late-answer proof's numbers (`InPlaceComposer.Attempt`).
    var proof: String

    init(_ attempt: InPlaceComposer.Attempt) {
        deleteCount = attempt.deleteCount
        selection = attempt.selection
        expected = attempt.predictedCaret
        known = attempt.followedCaret
        insertedLength = attempt.insertedLength
        replacement = attempt.replacement
        proof = "read=\(attempt.proofRead) tail=\(attempt.proofTail) edits=\(attempt.proofEdits) burst=\(attempt.proofBurst) rebuilt=\(attempt.proofRebuilt) word_at_answer=\(attempt.proofWordAtAnswer)"
    }

    /// Logs one line. Reads `selectedRange()` once more after the insertion to see where
    /// the client put the cursor; an extra client call, Debug only.
    static func log(_ diag: ReplaceDiag, kind: PerfLog.Kind, client: IMKTextInput, app: String) {
        let after = diag.replacement == nil ? NSRange(location: NSNotFound, length: 0) : client.selectedRange()
        let expectedAfter = diag.replacement.map { $0.location + diag.insertedLength } ?? -1
        logger.notice("""
            replace kind=\(kind.rawValue, privacy: .public) del=\(diag.deleteCount, privacy: .public) \
            sel=\(format(diag.selection), privacy: .public) expected=\(diag.expected ?? -1, privacy: .public) known=\(diag.known ?? -1, privacy: .public) \
            rep=\(diag.replacement.map(format) ?? "-", privacy: .public) ins_len=\(diag.insertedLength, privacy: .public) \
            after=\(format(after), privacy: .public) after_expected=\(expectedAfter, privacy: .public) \
            \(diag.proof, privacy: .public) \
            app=\(app, privacy: .public)
            """)
    }

    private static func format(_ range: NSRange) -> String {
        range.location == NSNotFound ? "notfound" : "\(range.location),\(range.length)"
    }
}
#endif
