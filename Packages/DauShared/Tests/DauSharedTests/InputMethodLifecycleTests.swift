import Foundation
import Testing
@testable import DauShared

@Suite("Input method quit request (D7, D16)")
struct InputMethodLifecycleTests {
    @Test("the name derives from the bundle ID, so it survives upgrades (D37)")
    func name() {
        #expect(InputMethodLifecycle.quitNotificationName(inputMethodBundleID: "com.codefastlabs.dau.inputmethod.Dau")
                == "com.codefastlabs.dau.inputmethod.Dau.quitRequested")
    }

    @Test("a posted request reaches the observer of that bundle ID only")
    func observe() throws {
        let id = "dau.tests.im." + UUID().uuidString
        let heard = DispatchSemaphore(value: 0)
        let other = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "dau.tests.quit")
        let observer = try #require(InputMethodLifecycle.observeQuitRequests(inputMethodBundleID: id, on: queue) {
            heard.signal()
        })
        let otherObserver = try #require(InputMethodLifecycle.observeQuitRequests(inputMethodBundleID: id + ".other", on: queue) {
            other.signal()
        })
        InputMethodLifecycle.requestQuit(inputMethodBundleID: id)
        #expect(heard.wait(timeout: .now() + 2) == .success)
        #expect(other.wait(timeout: .now() + 0.3) == .timedOut)
        withExtendedLifetime((observer, otherObserver)) {}
    }

    @Test("quit only when the bundle on disk is not the one launched (anyone can post)")
    func quitOnlyWhenBundleChanged() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("dau-tests-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let exe = dir.appendingPathComponent("DauInputMethod").path
        try Data("old".utf8).write(to: URL(fileURLWithPath: exe))
        let launch = InputMethodLifecycle.BundleFile.at(exe)
        #expect(launch != nil)
        // A request out of the blue: same file, ignored.
        #expect(!InputMethodLifecycle.shouldQuit(launchedFrom: launch, now: InputMethodLifecycle.BundleFile.at(exe)))
        // Upgrade: a new file renamed over the old one.
        let staged = dir.appendingPathComponent("staged").path
        try Data("new".utf8).write(to: URL(fileURLWithPath: staged))
        #expect(rename(staged, exe) == 0)
        #expect(InputMethodLifecycle.shouldQuit(launchedFrom: launch, now: InputMethodLifecycle.BundleFile.at(exe)))
        // Uninstall: gone from disk.
        try FileManager.default.removeItem(atPath: exe)
        #expect(InputMethodLifecycle.shouldQuit(launchedFrom: launch, now: InputMethodLifecycle.BundleFile.at(exe)))
        // Unknown at launch: honour the request.
        #expect(InputMethodLifecycle.shouldQuit(launchedFrom: nil, now: nil))
    }
}
