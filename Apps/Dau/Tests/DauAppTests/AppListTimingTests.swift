import AppKit
import Testing
import DauShared
@testable import Dau

// Measurement, not a check (CLAUDE.md "Đo trước khi tối ưu"): how long the "Add App
// Rule" sheet's app list takes to build on this Mac, stage by stage, with the real
// folders, bundles and icons (`AddAppRuleSheet.loadApps`, `AppListing.installed`). Off by
// default (it reads every app on the Mac and prints timings); run with
//   DAU_MEASURE_APP_LIST=1 swift test --package-path Apps/Dau/Tests --filter AppListTiming
// Repetition 1 is the first in this process (Bundle's cache empty); 2 and 3 are warm.
@MainActor
@Suite("App list timing (measurement)", .enabled(if: ProcessInfo.processInfo.environment["DAU_MEASURE_APP_LIST"] == "1"))
struct AppListTimingTests {
    @Test("stages of the add-rule sheet's app list, 3 repetitions")
    func stages() {
        let clock = ContinuousClock()
        func ms(_ d: Duration) -> String { String(format: "%7.1f ms", Double(d.components.attoseconds) / 1e15 + Double(d.components.seconds) * 1000) }
        for rep in 1...3 {
            var times: [(String, Duration)] = []
            var start = clock.now
            func lap(_ name: String) { let now = clock.now; times.append((name, now - start)); start = now }

            let running = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
            lap("running apps (list)")
            let runningListings = running.compactMap { app -> AppListing? in
                guard let id = app.bundleIdentifier, let url = app.bundleURL else { return nil }
                return AppListing(bundleID: id, name: AppDirectory.name(at: url), path: url.path)
            }
            lap("running apps (names)")

            var urls: [URL] = []
            for folder in AppListing.folders {
                for name in (try? FileManager.default.contentsOfDirectory(atPath: folder)) ?? [] where name.hasSuffix(".app") {
                    urls.append(URL(fileURLWithPath: folder).appendingPathComponent(name))
                }
            }
            lap("directory scan")
            let ids = urls.map { Bundle(url: $0)?.bundleIdentifier }
            lap("Bundle(url:).bundleIdentifier")
            let names = urls.map { AppDirectory.name(at: $0) }
            lap("displayName")
            var listings: [AppListing] = []
            for (i, url) in urls.enumerated() { if let id = ids[i] { listings.append(AppListing(bundleID: id, name: names[i], path: url.path)) } }
            var seen = Set<String>()
            let sorted = (listings + runningListings)
                .filter { seen.insert($0.bundleID).inserted }
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            lap("dedupe + sort")
            let icons = sorted.map { NSWorkspace.shared.icon(forFile: $0.path) }
            lap("icon(forFile:)")
            // What drawing a row does: the 24 pt image (Retina: 48 px) is rendered.
            var rect = NSRect(x: 0, y: 0, width: 24, height: 24)
            let drawn = icons.compactMap { $0.cgImage(forProposedRect: &rect, context: nil,
                                                       hints: [.ctm: NSAffineTransform(transform: AffineTransform(scale: 2))]) }
            lap("icon render 24 pt @2x")
            let list = CompatibilityList.bundled()
            _ = sorted.map { list.suggestion(for: $0.bundleID) != nil }
            lap("suggestion lookup")

            let total = times.reduce(Duration.zero) { $0 + $1.1 }
            print("APPLIST rep \(rep): \(urls.count) bundles in folders, \(running.count) running, \(sorted.count) rows, \(drawn.count) icons drawn")
            for (name, d) in times { print("APPLIST rep \(rep)   \(ms(d))  \(name)") }
            print("APPLIST rep \(rep)   \(ms(total))  total")
        }
    }
}
