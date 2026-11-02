import AppKit
import os

/// Finds the host app (Dấu, the Settings app) for the input menu's "Cài đặt Dấu…".
///
/// Not "whatever LaunchServices returns for the bundle ID": on a development machine
/// LaunchServices may know many old copies (DerivedData, temporary builds), and
/// `urlForApplication(withBundleIdentifier:)` can pick any of them. The order is:
///
/// 1. A running copy of the host app: the user already has it; activate that one.
/// 2. The app this bundle is nested in (`Dau.app/Contents/Library/Input Methods/`), when
///    the input method runs from inside the app.
/// 3. The installed input method is a copy made by the host app (M5), so a matching host
///    app has the same version: among the copies LaunchServices knows, keep those whose
///    CFBundleShortVersionString and CFBundleVersion equal the input method's, preferring
///    one in an Applications folder. No match: nothing is opened (logged by the caller),
///    rather than an older or newer app.
///    The input method's sandbox can read Info.plist of copies in /Applications but not
///    in a home folder (measured 02/11/2026: `deny file-read-data` for a DerivedData
///    copy), so a build that is neither running nor in /Applications is never chosen.
///
/// TODO(M5): the installer can record the host app's path in the shared settings; use it
/// first once it exists.
enum HostApp {
    /// Info.plist key of the input method holding the host app's bundle ID
    /// (`$(BUNDLE_ID_PREFIX)` in project.yml), so the ID is never written in code.
    static let bundleIDInfoKey = "DauHostAppBundleIdentifier"

    /// Why `url` chose the app it returned (for the log).
    enum Reason: String {
        case running
        case enclosing
        case sameVersion = "same-version"
    }

    /// The host app to open and why, or nil if none fits.
    static func url(bundle: Bundle = .main, workspace: NSWorkspace = .shared) -> (url: URL, reason: Reason)? {
        guard let hostID = bundle.object(forInfoDictionaryKey: bundleIDInfoKey) as? String,
              !hostID.isEmpty, !hostID.contains("$(") else { return nil }

        if let running = NSRunningApplication.runningApplications(withBundleIdentifier: hostID)
            .first(where: { $0.bundleURL != nil && !$0.isTerminated }),
           let url = running.bundleURL {
            return (url, .running)
        }
        if let parent = enclosingApp(of: bundle.bundleURL),
           Bundle(url: parent)?.bundleIdentifier == hostID {
            return (parent, .enclosing)
        }
        let candidates = workspace.urlsForApplications(withBundleIdentifier: hostID)
            .filter { Version(bundle: Bundle(url: $0)) == Version(bundle: bundle) }
        if let url = preferred(candidates) {
            return (url, .sameVersion)
        }
        return nil
    }

    /// Opens and activates the host app found by `url`, logging under `logger` (D8:
    /// reason and path only). `completion` runs on the main thread with whether the
    /// app opened (false if none fits or opening failed).
    @MainActor
    static func open(logger: Logger, completion: (@MainActor @Sendable (Bool) -> Void)? = nil) {
        guard let (url, reason) = url() else {
            let known = (Bundle.main.object(forInfoDictionaryKey: bundleIDInfoKey) as? String)
                .map { NSWorkspace.shared.urlsForApplications(withBundleIdentifier: $0) } ?? []
            let readable = known.filter { Version(bundle: Bundle(url: $0)).short != nil }.count
            logger.error("event=host-app-not-found known=\(known.count, privacy: .public) readable=\(readable, privacy: .public)")
            completion?(false)
            return
        }
        logger.notice("event=host-app-open reason=\(reason.rawValue, privacy: .public) path=\(url.path, privacy: .public)")
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
            if let error {
                logger.error("event=host-app-open-failed error=\(String(describing: error), privacy: .public)")
            } else {
                logger.notice("event=host-app-opened")
            }
            let opened = error == nil
            DispatchQueue.main.async { MainActor.assumeIsolated { completion?(opened) } }
        }
    }

    /// `X.app` for `X.app/Contents/Library/Input Methods/<bundle>`, else nil.
    static func enclosingApp(of bundleURL: URL) -> URL? {
        let inputMethods = bundleURL.deletingLastPathComponent()
        let library = inputMethods.deletingLastPathComponent()
        let contents = library.deletingLastPathComponent()
        let app = contents.deletingLastPathComponent()
        guard inputMethods.lastPathComponent == "Input Methods",
              library.lastPathComponent == "Library",
              contents.lastPathComponent == "Contents",
              app.pathExtension == "app" else { return nil }
        return app
    }

    /// First copy inside an Applications folder (/Applications, ~/Applications), else the
    /// first candidate.
    static func preferred(_ candidates: [URL]) -> URL? {
        candidates.first { $0.pathComponents.dropLast().contains("Applications") } ?? candidates.first
    }

    /// Marketing version + build number; nil parts never match.
    struct Version: Equatable {
        var short: String?
        var build: String?

        init(short: String?, build: String?) {
            self.short = short
            self.build = build
        }

        init(bundle: Bundle?) {
            short = bundle?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            build = bundle?.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        }

        static func == (a: Version, b: Version) -> Bool {
            guard let aShort = a.short, let aBuild = a.build else { return false }
            return aShort == b.short && aBuild == b.build
        }
    }
}
