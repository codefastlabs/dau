import AppKit
import Testing
@testable import SnapshotSettings

/// The add-rule sheet's search and selection: "Thêm" (and Return) add only an app that
/// is on screen, so a query that hides the selected app clears the selection.
@MainActor
@Suite("Add-rule sheet search")
struct AddAppRuleSheetTests {
    static let candidates = [
        AppCandidate(bundleID: "com.google.Chrome", name: "Google Chrome", icon: NSImage()),
        AppCandidate(bundleID: "com.microsoft.VSCode", name: "Visual Studio Code", icon: NSImage(), suggested: true),
        AppCandidate(bundleID: "com.apple.TextEdit", name: "TextEdit", icon: NSImage()),
        AppCandidate(bundleID: "vn.example.tiengviet", name: "Tiếng Việt", icon: NSImage()),
    ]

    @Test("name or bundle ID, ignoring case and diacritics; all for an empty query")
    func matching() {
        let c = Self.candidates
        #expect(AppCandidate.matching(c, query: "").map(\.id) == c.map(\.id))
        #expect(AppCandidate.matching(c, query: "  ").map(\.id) == c.map(\.id))
        #expect(AppCandidate.matching(c, query: "chrome").map(\.id) == ["com.google.Chrome"])
        #expect(AppCandidate.matching(c, query: "vscode").map(\.id) == ["com.microsoft.VSCode"])
        #expect(AppCandidate.matching(c, query: "tieng viet").map(\.id) == ["vn.example.tiengviet"])
        #expect(AppCandidate.matching(c, query: "zzz").isEmpty)
    }

    @Test("the selection stays while visible and is cleared when the search hides it")
    func selection() {
        let c = Self.candidates
        let chrome = "com.google.Chrome"
        // Selected, then a query that keeps it on screen.
        #expect(AppCandidate.selection(chrome, among: AppCandidate.matching(c, query: "goo")) == chrome)
        // Selected app A, then a query that hides A: nothing selected, "Thêm" off.
        #expect(AppCandidate.selection(chrome, among: AppCandidate.matching(c, query: "TextEdit")) == nil)
        #expect(AppCandidate.selection(chrome, among: AppCandidate.matching(c, query: "zzz")) == nil)
        #expect(AppCandidate.selection(nil, among: c) == nil)
        // Clearing the query brings the list back, not a hidden selection.
        let cleared = AppCandidate.selection(chrome, among: AppCandidate.matching(c, query: "TextEdit"))
        #expect(AppCandidate.selection(cleared, among: AppCandidate.matching(c, query: "")) == nil)
    }
}
