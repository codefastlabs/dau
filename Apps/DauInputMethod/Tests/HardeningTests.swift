import Foundation
import DauEngine
import DauShared
import Testing

// D18 (Phòng thủ với IMK): odd client answers, notifications any process can post, calls
// that come back into the controller during a key, and host app candidates that claim
// the host's bundle ID.

/// A client whose `selectedRange` answers whatever the test sets; records every call.
final class OddClient: InPlaceClient {
    var selection: NSRange
    var selectedRangeCalls = 0
    var reads: [NSRange] = []
    var inserts: [(String, NSRange)] = []
    /// Called inside `insertText` (a client calling back into the input method).
    var onInsert: (() -> Void)?

    init(selection: NSRange) {
        self.selection = selection
    }

    func selectedRange() -> NSRange {
        selectedRangeCalls += 1
        return selection
    }

    func text(in range: NSRange) -> String? {
        reads.append(range)
        return "to"
    }

    func insertText(_ text: String, replacementRange: NSRange) {
        inserts.append((text, replacementRange))
        onInsert?()
    }

    /// Insertions with a replacement range (anything but NSNotFound).
    var rangedInserts: [NSRange] { inserts.map(\.1).filter { $0.location != NSNotFound } }
}

@Suite("Client ranges past the limit (D18: no overflow trap)")
struct ClientRangeTests {
    let notFound = NSRange(location: NSNotFound, length: NSNotFound)

    @Test("negative, huge and NSNotFound answers are no document access; the limit itself is usable")
    func sanitized() {
        let limit = ClientRange.limit
        #expect(ClientRange.sanitized(NSRange(location: 5, length: 0)) == NSRange(location: 5, length: 0))
        #expect(ClientRange.sanitized(NSRange(location: limit, length: 0)) == NSRange(location: limit, length: 0))
        #expect(ClientRange.sanitized(NSRange(location: limit - 3, length: 3)) == NSRange(location: limit - 3, length: 3))
        for odd in [NSRange(location: limit, length: 1), NSRange(location: limit + 1, length: 0),
                    NSRange(location: 5, length: Int.max - 1), NSRange(location: 5, length: Int.max - 3),
                    NSRange(location: Int.max - 1, length: 0), NSRange(location: -1, length: 0),
                    NSRange(location: 3, length: -1), NSRange(location: Int.min, length: Int.max),
                    NSRange(location: NSNotFound, length: 0), NSRange(location: 0, length: NSNotFound)] {
            #expect(ClientRange.sanitized(odd) == notFound)
        }
    }

    @Test("saturating arithmetic clamps instead of trapping")
    func saturating() {
        #expect(Int.max.addingSaturated(1) == .max)
        #expect(Int.min.addingSaturated(-1) == .min)
        #expect(Int.min.subtractingSaturated(1) == .min)
        #expect(Int.max.subtractingSaturated(-1) == .max)
        #expect(5.addingSaturated(-7) == -2)
        #expect(5.subtractingSaturated(7) == -2)
    }

    @Test("plan: {5, Int.max-1} with deleteCount 2 is unsupported, not a trap")
    func hugeLength() {
        let t = CursorTracker()
        #expect(t.plan(selection: NSRange(location: 5, length: Int.max - 1), deleteCount: 2) == .unsupported)
        #expect(t.plan(selection: NSRange(location: 5, length: Int.max - 3), deleteCount: 1) == .unsupported)
        #expect(t.plan(selection: NSRange(location: Int.max - 1, length: 0), deleteCount: 1) == .unsupported)
        #expect(t.plan(selection: NSRange(location: -4, length: 0), deleteCount: 1) == .unsupported)
        // At the limit the arithmetic is still exact.
        let limit = ClientRange.limit
        #expect(t.plan(selection: NSRange(location: limit, length: 0), deleteCount: 2)
                == .replace(NSRange(location: limit - 2, length: 2)))
    }

    @Test("didReplace with {5, Int.max-3} forgets the position instead of trapping")
    func didReplaceHuge() {
        var t = CursorTracker()
        t.anchor(at: 5)
        t.didReplace(NSRange(location: 5, length: Int.max - 3), text: "â")
        #expect(t.known == nil && t.expected == nil && t.edits.isEmpty)
        t.didReplace(NSRange(location: 2, length: 1), text: "a", cursor: Int.max)
        #expect(t.known == nil)
    }

    @Test("anchor at {Int.max-1} then two units typed: no trap, no position")
    func anchorHuge() {
        var t = CursorTracker()
        t.anchor(at: Int.max - 1)
        #expect(t.known == nil)
        t.passedThrough("a")
        t.passedThrough("b")
        #expect(t.known == nil && t.expected == nil)
    }

    @Test("a position pushed past the limit by an insertion is forgotten")
    func pastLimit() {
        var t = CursorTracker()
        let limit = ClientRange.limit
        guard case .replace(let range) = t.plan(selection: NSRange(location: limit, length: 0), deleteCount: 1) else {
            Issue.record("expected a replacement at the limit")
            return
        }
        t.didReplace(range, text: "ôô")
        #expect(t.known == nil)
        #expect(t.expected == nil)
        t.didInsertAtCursor("abc")
        #expect(t.expected == nil && t.known == nil)
    }

    @Test("rebuild with a huge answer proves nothing")
    func rebuildHuge() {
        var t = CursorTracker()
        t.anchor(at: 3)
        t.passedThrough("a")
        #expect(t.rebuild(Array("to".utf16), at: NSRange(location: Int.max - 1, length: 0), accept: { _ in true }) == nil)
        #expect(t.rebuild(Array("to".utf16), at: NSRange(location: Int.min, length: 0), accept: { _ in true }) == nil)
    }
}

@Suite("In-place mode with a client that answers huge ranges (D18)")
struct InPlaceOddRangeTests {
    static let odd = [NSRange(location: 5, length: Int.max - 1), NSRange(location: 5, length: Int.max - 3),
                      NSRange(location: Int.max - 1, length: 0), NSRange(location: -3, length: 0)]

    @Test("replacement path: the key that replaces asks once, replaces nothing, does not trap",
          arguments: odd)
    func replacement(_ selection: NSRange) {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        composer.addMarksEnabled = false  // no D20 read: the replacement path only
        let client = OddClient(selection: selection)
        var time = 1.0
        for c in "too".unicodeScalars {
            time += 0.2
            _ = composer.handle(.character(c), time: time, engine: &engine, client: client)
        }
        #expect(client.selectedRangeCalls == 1)
        #expect(client.rangedInserts.isEmpty)
        #expect(client.reads.isEmpty)
        #expect(composer.tracker.known == nil)
    }

    @Test("D20 path: a mark key with no word asks once, reads nothing, does not trap",
          arguments: odd)
    func addMarks(_ selection: NSRange) {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        let client = OddClient(selection: selection)
        let outcome = composer.handle(.character("s"), time: 1.0, engine: &engine, client: client)
        #expect(client.selectedRangeCalls == 1)
        #expect(client.reads.isEmpty)
        #expect(client.rangedInserts.isEmpty)
        #expect(composer.tracker.known == nil)
        #expect(!outcome.consumed)
        // Later keys in the session keep working without a trap.
        for (i, c) in "aas ".unicodeScalars.enumerated() {
            _ = composer.handle(.character(c), time: 1.2 + Double(i) * 0.2, engine: &engine, client: client)
        }
        #expect(client.rangedInserts.isEmpty)
    }

    @Test("checked word path (D11 on a locked word): a huge answer is not read")
    func lockedWord() {
        var engine = VietEngine()
        var composer = InPlaceComposer()
        composer.addMarksEnabled = false
        let client = OddClient(selection: NSRange(location: 10, length: 0))
        var time = 1.0
        // "tk" is locked by spelling (D30); the next mark key checks the word once.
        for c in "tk".unicodeScalars {
            time += 0.2
            _ = composer.handle(.character(c), time: time, engine: &engine, client: client)
        }
        client.selection = NSRange(location: Int.max - 1, length: 0)
        #expect(engine.isSpellingLocked)
        time += 0.2
        _ = composer.handle(.character("s"), time: time, engine: &engine, client: client)
        #expect(client.reads.isEmpty)
        #expect(client.rangedInserts.isEmpty)
    }
}

@Suite("Input source change notifications (D4, any process can post them)")
struct InputSourceChangeTests {
    let own = "com.example.inputmethod.Dau"
    let dau = "com.example.inputmethod.Dau.vi"
    let us = "com.apple.keylayout.US"

    @Test("a notification with the same source still selected keeps the word")
    func spoofed() {
        #expect(!InputSourceChange.endsWord(previous: dau, current: dau, ownBundleID: own))
    }

    @Test("a real switch away ends the word, and so does the switch back")
    func realSwitch() {
        #expect(InputSourceChange.endsWord(previous: dau, current: us, ownBundleID: own))
        #expect(InputSourceChange.endsWord(previous: us, current: dau, ownBundleID: own))
    }

    @Test("when nothing can be told, the word ends as before")
    func unknown() {
        #expect(InputSourceChange.endsWord(previous: dau, current: nil, ownBundleID: own))
        #expect(InputSourceChange.endsWord(previous: nil, current: dau, ownBundleID: own))
        #expect(InputSourceChange.endsWord(previous: dau, current: dau, ownBundleID: nil))
    }

    @Test("Dấu is the bundle ID or one of its modes, not a lookalike prefix")
    func ownSource() {
        #expect(InputSourceChange.isOwn(dau, bundleID: own))
        #expect(InputSourceChange.isOwn(own, bundleID: own))
        #expect(!InputSourceChange.isOwn(own + "Other.vi", bundleID: own))
        #expect(!InputSourceChange.isOwn(us, bundleID: own))
        #expect(!InputSourceChange.isOwn(dau, bundleID: ""))
    }
}

@Suite("Calls back into the controller during a key or a reset (D18, KeyReentry)")
struct KeyReentryTests {
    @Test("idle: a call runs at once; busy: it runs after the body, in order, never nested")
    func deferral() {
        let r = KeyReentry()
        var order: [String] = []
        r.run { order.append("idle") }
        #expect(order == ["idle"] && !r.isBusy)
        r.run {
            order.append("outer")
            r.run {
                order.append("first")
                r.run { order.append("third") }  // kept by a kept call: after "second"
                order.append("first-end")
            }
            r.run { order.append("second") }
            #expect(r.key({ true }) == nil)  // a key inside: not handled
            order.append("outer-end")
        }
        #expect(order == ["idle", "outer", "outer-end", "first", "first-end", "second", "third"])
        #expect(!r.isBusy)
        #expect(r.key({ true }) == true)
    }

    /// `DauInputController`'s pattern with the real composers and the real `KeyReentry`:
    /// `handle` through `reentry.key`, every other entry point through `run`
    /// (`outsideKey`), `resetComposition` committing the underlined word. The controller
    /// itself is an `IMKInputController` that IMK creates for an `IMKServer` connection;
    /// it is not in the test target (logic tests only, project.yml), so this copies its
    /// three methods.
    final class Controller {
        var engine = VietEngine()
        var inPlace = InPlaceComposer()
        var composer = MarkedComposer()
        let reentry = KeyReentry()
        var underline = false
        var resets = 0

        func handle(_ route: KeyRoute, client: OddClient, time: TimeInterval) -> Bool {
            guard let consumed = reentry.key({
                underline ? composer.handle(route, engine: &engine, client: client).consumed
                          : inPlace.handle(route, time: time, engine: &engine, client: client).consumed
            }) else {
                reentry.run { [self] in resetComposition(client: client) }
                return false
            }
            return consumed
        }

        /// `commitComposition`, `deactivateServer`.
        func commit(client: OddClient) {
            reentry.run { [self] in resetComposition(client: client) }
        }

        private func resetComposition(client: OddClient) {
            resets += 1
            inPlace.reset(engine: &engine)
            if composer.isComposing {
                _ = composer.commit(engine: &engine, client: client)  // insertText
            } else {
                composer.abandon(engine: &engine)
            }
        }
    }

    @Test("in-place: a client that commits from inside insertText; the reset runs after the key")
    func commitDuringInsert() {
        let controller = Controller()
        controller.inPlace.addMarksEnabled = false
        let client = OddClient(selection: NSRange(location: 0, length: 0))
        var calledBack = 0
        var time = 1.0
        for c in "to".unicodeScalars {
            time += 0.2
            _ = controller.handle(.character(c), client: client, time: time)
        }
        client.selection = NSRange(location: 2, length: 0)
        client.onInsert = {
            calledBack += 1
            controller.commit(client: client)
            #expect(controller.resets == 0)  // held back: the engine is borrowed
        }
        time += 0.2
        _ = controller.handle(.character("o"), client: client, time: time)  // "tô": one insertText
        #expect(calledBack == 1)
        #expect(controller.resets == 1)
        #expect(!controller.engine.isComposing)
        client.onInsert = nil
        controller.commit(client: client)  // idle: at once
        #expect(controller.resets == 2)
    }

    @Test("underline: a reset commits the word, and the client commits and deactivates from inside that insertText")
    func commitDuringResetCommit() {
        let controller = Controller()
        controller.underline = true
        let client = OddClient(selection: NSRange(location: NSNotFound, length: NSNotFound))
        for c in "vieet".unicodeScalars {
            _ = controller.handle(.character(c), client: client, time: 1.0)
        }
        #expect(controller.composer.isComposing)
        var calledBack = 0
        client.onInsert = {
            calledBack += 1
            controller.commit(client: client)  // commitComposition
            controller.commit(client: client)  // deactivateServer
            #expect(controller.resets == 1)  // only the reset that is committing
        }
        controller.commit(client: client)  // e.g. a click: commits "viêt" with insertText
        #expect(calledBack == 1)  // the nested resets had nothing left to commit
        #expect(controller.resets == 3)
        #expect(client.inserts.map(\.0) == ["viêt"])
        #expect(!controller.composer.isComposing && !controller.engine.isComposing)
        #expect(!controller.reentry.isBusy)
    }

    @Test("underline: a key typed by the client while a reset commits is not handled")
    func keyDuringResetCommit() {
        let controller = Controller()
        controller.underline = true
        let client = OddClient(selection: NSRange(location: NSNotFound, length: NSNotFound))
        for c in "ddi".unicodeScalars {
            _ = controller.handle(.character(c), client: client, time: 1.0)
        }
        var nested: Bool?
        client.onInsert = {
            client.onInsert = nil
            nested = controller.handle(.character("a"), client: client, time: 1.1)
        }
        controller.commit(client: client)
        #expect(nested == false)
        #expect(client.inserts.map(\.0) == ["đi"])
        #expect(controller.resets == 2)  // the commit, then the reset kept for the nested key
    }
}

@Suite("Settings change notifications in a burst (ChangeCoalescer)")
struct ChangeCoalescerTests {
    @Test("a burst schedules one reload; a change after the reload starts schedules another")
    func burst() {
        var c = ChangeCoalescer()
        let first = c.noteChange()
        #expect(first)
        var later = 0
        for _ in 0..<1000 where c.noteChange() { later += 1 }
        #expect(later == 0)
        c.willReload()
        let next = c.noteChange()
        #expect(next)
        #expect(c.isScheduled)
    }
}

@Suite("Host app candidates and their signature (HostApp.accepts, HostAppSignature)")
struct HostAppTrustTests {
    let a = URL(fileURLWithPath: "/Applications/Dau.app")
    let b = URL(fileURLWithPath: "/Applications/Dau copy.app")
    let home = URL(fileURLWithPath: "/Users/someone/build/Dau.app")

    @Test("unchecked copies open only when running or enclosing; untrusted never")
    func policy() {
        for reason in [HostApp.Reason.running, .enclosing, .sameVersion, .applicationsFolder, .userApplications, .onlyKnown] {
            #expect(HostApp.accepts(.trusted, reason: reason))
            #expect(!HostApp.accepts(.untrusted, reason: reason))
        }
        #expect(HostApp.accepts(.unknown, reason: .running))
        #expect(HostApp.accepts(.unknown, reason: .enclosing))
        #expect(HostApp.accepts(.unknown, reason: .userApplications))  // choose checks /Applications first
        #expect(!HostApp.accepts(.unknown, reason: .sameVersion))
        #expect(!HostApp.accepts(.unknown, reason: .applicationsFolder))
        #expect(!HostApp.accepts(.unknown, reason: .onlyKnown))
    }

    func candidates(running: [URL] = [], enclosing: URL? = nil, sameVersion: [URL] = [],
                    scanned: [URL] = [], known: [URL] = []) -> HostApp.Candidates {
        HostApp.Candidates(running: running, enclosing: enclosing, sameVersion: sameVersion,
                           scanned: { accept in scanned.first(where: accept) }, known: known,
                           systemFolder: URL(fileURLWithPath: "/Applications"),
                           userFolder: URL(fileURLWithPath: "/Users/someone/Applications"))
    }

    @Test("an untrusted running copy is skipped for the next trusted candidate")
    func skipUntrusted() {
        let verify: (URL) -> HostApp.Trust = { $0 == self.a ? .untrusted : .trusted }
        let chosen = HostApp.choose(candidates(running: [a, b]), verify: verify)
        #expect(chosen?.url == b && chosen?.reason == .running)
        let next = HostApp.choose(candidates(running: [a], sameVersion: [a, b]), verify: verify)
        #expect(next?.url == b && next?.reason == .sameVersion)
    }

    @Test("a copy that cannot be checked opens only as running or enclosing")
    func unknownCopies() {
        let verify: (URL) -> HostApp.Trust = { _ in .unknown }
        #expect(HostApp.choose(candidates(running: [home]), verify: verify)?.reason == .running)
        #expect(HostApp.choose(candidates(enclosing: home), verify: verify)?.reason == .enclosing)
        #expect(HostApp.choose(candidates(sameVersion: [a], scanned: [a], known: [home]), verify: verify) == nil)
    }

    @Test("the scan and the only known copy also need a trusted signature")
    func scanAndOnlyKnown() {
        let trusted: (URL) -> HostApp.Trust = { $0 == self.b ? .trusted : .untrusted }
        #expect(HostApp.choose(candidates(scanned: [a, b]), verify: trusted)?.url == b)
        #expect(HostApp.choose(candidates(known: [a]), verify: trusted) == nil)
        #expect(HostApp.choose(candidates(known: [b]), verify: trusted)?.reason == .onlyKnown)
    }

    @Test("signature check: unreadable is unknown, an unsigned bundle is untrusted, no team is unknown")
    func signature() throws {
        let missing = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString)/Dau.app")
        #expect(HostAppSignature.trust(missing, hostID: "com.example.dau", teamID: "ABCDE12345") == .unknown)
        let dir = try HostAppScanTests.folder([("Dau.app", "com.example.dau", "0.1.0", "1")])
        defer { try? FileManager.default.removeItem(at: dir) }
        let fake = dir.appendingPathComponent("Dau.app")
        #expect(HostAppSignature.trust(fake, hostID: "com.example.dau", teamID: "ABCDE12345") == .untrusted)
        #expect(HostAppSignature.trust(fake, hostID: "com.example.dau", teamID: nil) == .unknown)
    }

    @Test("requirement text refuses values that cannot be quoted")
    func requirementText() {
        #expect(HostAppSignature.requirementText(identifier: "com.example.dau", teamID: "ABCDE12345")
                == "anchor apple generic and identifier \"com.example.dau\" and certificate leaf[subject.OU] = \"ABCDE12345\"")
        #expect(HostAppSignature.requirementText(identifier: "a\" or anchor trusted", teamID: "X") == nil)
        #expect(HostAppSignature.requirementText(identifier: "com.example.dau", teamID: "") == nil)
    }

    @Test("the Security check accepts a signed system app for its signer, refuses another team")
    func systemApp() throws {
        let calculator = URL(fileURLWithPath: "/System/Applications/Calculator.app")
        try #require(FileManager.default.fileExists(atPath: calculator.path))
        #expect(HostAppSignature.isValid(calculator, requirement: "anchor apple and identifier \"com.apple.calculator\""))
        #expect(!HostAppSignature.isValid(calculator, requirement: HostAppSignature.requirementText(
            identifier: "com.apple.calculator", teamID: "ABCDE12345")!))
        #expect(HostAppSignature.trust(calculator, hostID: "com.apple.calculator", teamID: "ABCDE12345") == .untrusted)
    }
}

/// A plain text document, cursor at the end: `selectedRange`, `text(in:)` and
/// `insertText` act on it; a key the composer does not consume is typed at the cursor.
final class PlainDocument: InPlaceClient {
    private(set) var units: [UInt16]
    private(set) var rangedInserts = 0
    private(set) var reads = 0

    init(_ text: String) { units = Array(text.utf16) }

    var text: String { String(decoding: units, as: UTF16.self) }

    func selectedRange() -> NSRange { NSRange(location: units.count, length: 0) }

    func text(in range: NSRange) -> String? {
        reads += 1
        guard range.location >= 0, range.length >= 0, range.location + range.length <= units.count else { return nil }
        return String(decoding: units[range.location..<(range.location + range.length)], as: UTF16.self)
    }

    func insertText(_ string: String, replacementRange: NSRange) {
        var range = NSRange(location: units.count, length: 0)
        if replacementRange.location != NSNotFound {
            rangedInserts += 1
            range = replacementRange
        }
        units.replaceSubrange(range.location..<(range.location + range.length), with: Array(string.utf16))
    }

    /// The app types a key the input method let through.
    func type(_ scalar: Unicode.Scalar) {
        insertText(String(Character(scalar)), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
    }
}

@Suite("D20 on a decomposed (NFD) foreign word before the cursor (exception b)")
struct DecomposedForeignWordTests {
    /// (text before the cursor, key): the key goes to the app unchanged and the text
    /// before it is not rewritten.
    static let cases: [(String, Unicode.Scalar)] = [
        ("mai\u{302}tre", "s"),
        ("i\u{302}le", "s"),
        ("du\u{302}", "t"),
        ("hodiau\u{306}", "n"),
        ("u\u{306}", "s"),
    ]

    @Test("the key passes through and the word read is left as it is", arguments: cases)
    func passes(_ text: String, _ key: Unicode.Scalar) {
        var engine = VietEngine(options: DauSettings.defaults.engineOptions)
        var composer = InPlaceComposer()
        composer.addMarksEnabled = DauSettings.defaults.addMarksToTypedWords
        #expect(composer.addMarksEnabled)  // D20 on (D15 default)
        let doc = PlainDocument(text)
        let outcome = composer.handle(.character(key), time: 1.0, engine: &engine, client: doc)
        if !outcome.consumed { doc.type(key) }
        #expect(!outcome.consumed)
        #expect(outcome.kind == .seedPass)  // read, then D20 (b): the key joins the foreign word
        #expect(doc.reads == 1)
        #expect(doc.rangedInserts == 0)
        #expect(doc.text.unicodeScalars.elementsEqual((text + String(Character(key))).unicodeScalars))
    }
}

extension OddClient: MarkedTextClient {
    func setMarkedText(_ text: String, selectionRange: NSRange, replacementRange: NSRange) {}
}

@Suite("Host app in ~/Applications (D37: the host when /Applications has none)")
struct HostAppUserFolderTests {
    let system = URL(fileURLWithPath: "/Applications/Dau.app")
    let user = URL(fileURLWithPath: "/Users/someone/Applications/Dau.app")
    let nested = URL(fileURLWithPath: "/Users/someone/Applications/Old/Dau.app")
    let build = URL(fileURLWithPath: "/Users/someone/build/Dau.app")

    func candidates(known: [URL]) -> HostApp.Candidates {
        HostApp.Candidates(running: [], enclosing: nil, sameVersion: [], scanned: { _ in nil }, known: known,
                           systemFolder: URL(fileURLWithPath: "/Applications"),
                           userFolder: URL(fileURLWithPath: "/Users/someone/Applications"))
    }

    /// The sandbox reads /Applications, not the home folder.
    func sandboxed(systemTrust: HostApp.Trust) -> (URL) -> HostApp.Trust {
        { $0.path.hasPrefix("/Applications/") ? systemTrust : .unknown }
    }

    @Test("unreadable copy directly in ~/Applications opens when /Applications has none")
    func opens() {
        let chosen = HostApp.choose(candidates(known: [build, user]), verify: sandboxed(systemTrust: .trusted))
        #expect(chosen?.url == user && chosen?.reason == .userApplications)
    }

    @Test("not when /Applications has a copy that passes (of any version)")
    func systemWins() {
        // The /Applications copy is of another version (steps 3 and 4 skip it): it is
        // still the host, so the ~/Applications copy is not.
        #expect(HostApp.choose(candidates(known: [system, user]), verify: sandboxed(systemTrust: .trusted)) == nil)
    }

    @Test("a failing /Applications copy does not block it; a failing ~/Applications copy never opens")
    func failing() {
        let chosen = HostApp.choose(candidates(known: [system, user]), verify: sandboxed(systemTrust: .untrusted))
        #expect(chosen?.url == user)
        let readFailed: (URL) -> HostApp.Trust = { _ in .untrusted }
        #expect(HostApp.choose(candidates(known: [user]), verify: readFailed) == nil)
    }

    @Test("only directly inside ~/Applications, not deeper or elsewhere in the home folder")
    func directly() {
        #expect(HostApp.choose(candidates(known: [nested, build]), verify: sandboxed(systemTrust: .trusted)) == nil)
        #expect(HostApp.isDirectly(user, in: URL(fileURLWithPath: "/Users/someone/Applications")))
        #expect(!HostApp.isDirectly(nested, in: URL(fileURLWithPath: "/Users/someone/Applications")))
    }

    @Test("the user folder is in the real home folder, not a sandbox container")
    func realHome() throws {
        let folder = try #require(HostApp.userApplicationsFolder())
        #expect(folder.lastPathComponent == "Applications")
        #expect(!folder.path.contains("/Library/Containers/"))
        #expect(folder.deletingLastPathComponent().path == NSHomeDirectoryForUser(NSUserName()))
    }
}
