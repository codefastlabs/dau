import AppKit
import os
import Security

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
///    copy), so a build that is neither running nor in /Applications never matches.
/// 4. Not registered: an app copied into /Applications without Finder (`ditto`, `cp`, a
///    package manager) may be unknown to LaunchServices for a while (measured 05/11/2026:
///    after `ditto` into /Applications only the DerivedData copies were known, and the
///    menu item opened nothing). So the Applications folder is scanned for a bundle with
///    the host's ID and the same version, like step 3.
/// 5. The copy directly in ~/Applications, when /Applications has no copy that passes the
///    signature check: then it is the host (D37). LaunchServices must know it.
/// 6. LaunchServices knows exactly one copy (any version): open it if its signature
///    passes. A copy whose Info.plist cannot be read (a development build in the home
///    folder) used to open here; it cannot be checked, so it no longer does (`accepts`).
///
/// At every step a copy is opened only if its signature passes (`accepts`,
/// `HostAppSignature`): signed by this input method's team, with the host's bundle ID.
/// Any app can claim the bundle ID. Steps 1, 2 and 5 also open a copy the sandbox does
/// not let the input method check.
enum HostApp {
    /// Info.plist key of the input method holding the host app's bundle ID
    /// (`$(BUNDLE_ID_PREFIX)` in project.yml), so the ID is never written in code.
    static let bundleIDInfoKey = "DauHostAppBundleIdentifier"

    /// Why `url` chose the app it returned (for the log).
    enum Reason: String {
        case running
        case enclosing
        case sameVersion = "same-version"
        case applicationsFolder = "applications-folder"
        case userApplications = "user-applications"
        case onlyKnown = "only-known"
    }

    /// The host app to open and why, or nil if none fits. Every candidate must pass
    /// `verify` (`accepts`): any app can claim the host's bundle ID, and the menu item
    /// must not open one that is not Dấu.
    static func url(bundle: Bundle = .main, workspace: NSWorkspace = .shared,
                    folders: [URL] = applicationFolders(),
                    verify: ((URL, String) -> Trust)? = nil) -> (url: URL, reason: Reason)? {
        guard let hostID = bundle.object(forInfoDictionaryKey: bundleIDInfoKey) as? String,
              !hostID.isEmpty, !hostID.contains("$(") else { return nil }
        let check: (URL) -> Trust = { url in (verify ?? HostAppSignature.trust(_:hostID:))(url, hostID) }
        let version = Version(bundle: bundle)
        let known = workspace.urlsForApplications(withBundleIdentifier: hostID)
        let candidates = Candidates(
            running: NSRunningApplication.runningApplications(withBundleIdentifier: hostID)
                .filter { !$0.isTerminated }.compactMap(\.bundleURL),
            enclosing: enclosingApp(of: bundle.bundleURL).flatMap { Bundle(url: $0)?.bundleIdentifier == hostID ? $0 : nil },
            sameVersion: known.filter { Version(bundle: Bundle(url: $0)) == version },
            scanned: { accept in scan(folders, hostID: hostID, version: version, accept: accept) },
            known: known,
            systemFolder: folders.first,
            userFolder: userApplicationsFolder())
        return choose(candidates, verify: check)
    }

    /// The copies `url` chooses from, in its order (see the type's comment).
    struct Candidates {
        /// Running copies of the host app.
        var running: [URL]
        /// The app this bundle is nested in, if it has the host's bundle ID.
        var enclosing: URL?
        /// Copies LaunchServices knows with the input method's version.
        var sameVersion: [URL]
        /// The first copy in the Applications folder with the host's ID and version that
        /// the closure accepts (read only when the steps before found nothing).
        var scanned: ((URL) -> Bool) -> URL?
        /// Every copy LaunchServices knows.
        var known: [URL]
        /// /Applications.
        var systemFolder: URL?
        /// ~/Applications in the user's real home folder (`userApplicationsFolder`).
        var userFolder: URL?
    }

    /// The first candidate, in the order of the type's comment, that `verify` accepts
    /// for its reason (`accepts`).
    static func choose(_ c: Candidates, verify: (URL) -> Trust) -> (url: URL, reason: Reason)? {
        func ok(_ url: URL, _ reason: Reason) -> Bool { accepts(verify(url), reason: reason) }
        if let url = c.running.first(where: { ok($0, .running) }) { return (url, .running) }
        if let url = c.enclosing, ok(url, .enclosing) { return (url, .enclosing) }
        if let url = preferred(c.sameVersion.filter { ok($0, .sameVersion) }) { return (url, .sameVersion) }
        if let url = c.scanned({ ok($0, .applicationsFolder) }) { return (url, .applicationsFolder) }
        // D37: with no Dấu.app in /Applications that passes, the copy directly in
        // ~/Applications is the host. The sandbox cannot read it (`Trust.unknown`), so it
        // opens unchecked; one that was read and failed never opens.
        if let system = c.systemFolder, let user = c.userFolder,
           !c.known.contains(where: { isDirectly($0, in: system) && verify($0) == .trusted }),
           let url = c.known.first(where: { isDirectly($0, in: user) && ok($0, .userApplications) }) {
            return (url, .userApplications)
        }
        if c.known.count == 1, let only = c.known.first, ok(only, .onlyKnown) { return (only, .onlyKnown) }
        return nil
    }

    /// What the signature check of a candidate found (`HostAppSignature`).
    enum Trust: Equatable {
        /// Validly signed by this input method's team, with the host's bundle ID.
        case trusted
        /// Readable, and not signed that way: never opened.
        case untrusted
        /// Could not be checked: the sandbox does not let the input method read the
        /// bundle (a copy in a home folder, measured 02/11/2026), or this input method has
        /// no Team ID of its own (ad-hoc signed).
        case unknown
    }

    /// A candidate that could not be checked (`Trust.unknown`) is still opened when it is
    /// the running host app, the app this bundle is nested in, or the copy directly in
    /// ~/Applications when /Applications has none that passes (D37; `choose` checks that
    /// condition): the sandbox cannot read a home folder, and the enclosing app is the
    /// bundle this input method came in. Any other candidate must be `trusted`;
    /// `untrusted` never opens.
    static func accepts(_ trust: Trust, reason: Reason) -> Bool {
        switch trust {
        case .trusted: return true
        case .untrusted: return false
        case .unknown: return reason == .running || reason == .enclosing || reason == .userApplications
        }
    }

    /// Opens and activates the host app found by `url`, logging under `logger` (D8:
    /// reason only, the path private). `completion` runs on the main thread with whether
    /// the app opened (false if none fits or opening failed).
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
        // The path may name the home folder (a development build): private, like the
        // error, whose description may carry it too.
        logger.notice("event=host-app-open reason=\(reason.rawValue, privacy: .public) path=\(url.path, privacy: .private)")
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
            if let error {
                let code = (error as NSError).code
                logger.error("event=host-app-open-failed code=\(code, privacy: .public) error=\(String(describing: error), privacy: .private)")
            } else {
                logger.notice("event=host-app-opened")
            }
            let opened = error == nil
            DispatchQueue.main.async { MainActor.assumeIsolated { completion?(opened) } }
        }
    }

    /// The local Applications folder (/Applications). The user domain is left out: in the
    /// sandbox it resolves inside the container, and a home folder copy is not readable.
    static func applicationFolders() -> [URL] {
        FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask)
    }

    /// ~/Applications in the user's real home folder. Not `FileManager`'s user domain or
    /// `homeDirectoryForCurrentUser`: in the sandbox they resolve inside the container.
    /// The password database gives the real home (getpwuid(3)). nil if unknown.
    static func userApplicationsFolder() -> URL? {
        guard let entry = getpwuid(getuid()), let dir = entry.pointee.pw_dir else { return nil }
        let home = String(cString: dir)
        guard !home.isEmpty else { return nil }
        return URL(fileURLWithPath: home, isDirectory: true).appendingPathComponent("Applications", isDirectory: true)
    }

    /// `url` is an item directly inside `folder` (not nested deeper).
    static func isDirectly(_ url: URL, in folder: URL) -> Bool {
        url.standardizedFileURL.deletingLastPathComponent().path == folder.standardizedFileURL.path
    }

    /// First `.app` directly in one of `folders` whose bundle ID is `hostID`, whose
    /// version is `version`, and that `accept` takes (not recursive: only where an
    /// install puts the app).
    static func scan(_ folders: [URL], hostID: String, version: Version,
                     accept: (URL) -> Bool = { _ in true }) -> URL? {
        for folder in folders {
            let items = (try? FileManager.default.contentsOfDirectory(
                at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? []
            for url in items.sorted(by: { $0.path < $1.path }) where url.pathExtension == "app" {
                guard let app = Bundle(url: url), app.bundleIdentifier == hostID else { continue }
                if Version(bundle: app) == version, accept(url) { return url }
            }
        }
        return nil
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

/// The signature check of a host app candidate (`HostApp.url`): the copy must be validly
/// signed, chain to Apple (Developer ID or Apple Development), have the host's bundle ID
/// and a leaf certificate of this input method's own team. A requirement, as the host
/// app checks the input method (`CodeSignature` in Apps/Dau, D37): comparing two Team IDs
/// read from the signatures would take two ad-hoc signatures (no Team ID) for the same
/// team, and the Team ID of an ad-hoc signature is whatever its maker wrote.
///
/// The sandbox: the input method can read bundles in /Applications (measured 02/11/2026
/// for Info.plist) but not in a home folder. The check needs the bundle's files, so a
/// copy whose Info.plist cannot be read is `HostApp.Trust.unknown`, not untrusted; what
/// that allows is decided by `HostApp.accepts`. The Security calls themselves have not
/// been run inside the input method's sandbox yet: if they fail there, a readable copy
/// counts as untrusted and the menu item opens only a running, enclosing or
/// ~/Applications copy.
enum HostAppSignature {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DauInputMethod",
                                       category: "settings")

    /// Trust of the bundle at `url` for host bundle ID `hostID`, against this process's
    /// own Team ID.
    static func trust(_ url: URL, hostID: String) -> HostApp.Trust {
        trust(url, hostID: hostID, teamID: ownTeamID)
    }

    /// Trust of the bundle at `url` for `hostID` and `teamID` (nil: this process has no
    /// Team ID, nothing can be checked).
    static func trust(_ url: URL, hostID: String, teamID: String?) -> HostApp.Trust {
        guard isReadable(url) else { return .unknown }
        guard let teamID, let requirement = requirementText(identifier: hostID, teamID: teamID) else { return .unknown }
        return isValid(url, requirement: requirement) ? .trusted : .untrusted
    }

    /// The bundle's Info.plist can be read (the sandbox lets this process see the copy).
    static func isReadable(_ url: URL) -> Bool {
        (try? Data(contentsOf: url.appendingPathComponent("Contents/Info.plist"))) != nil
    }

    /// The requirement a host app candidate must meet; nil when a value cannot be quoted
    /// safely (only letters, digits, `.`, `-`, `_`).
    static func requirementText(identifier: String, teamID: String) -> String? {
        let allowed = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_")
        guard !identifier.isEmpty, !teamID.isEmpty,
              identifier.allSatisfy(allowed.contains), teamID.allSatisfy(allowed.contains) else { return nil }
        return "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"\(teamID)\""
    }

    /// `url` is validly signed (all architectures, nested code, strict) and meets the
    /// requirement `text`. Any failure (not code, not signed, another signer) is false.
    static func isValid(_ url: URL, requirement text: String) -> Bool {
        var code: SecStaticCode?
        var requirement: SecRequirement?
        guard SecRequirementCreateWithString(text as CFString, [], &requirement) == errSecSuccess, let requirement,
              SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess, let code else {
            logger.error("event=host-app-signature-unreadable")
            return false
        }
        let flags = SecCSFlags(rawValue: SecCSFlags.RawValue(kSecCSCheckAllArchitectures | kSecCSCheckNestedCode | kSecCSStrictValidate))
        let status = SecStaticCodeCheckValidity(code, flags, requirement)
        if status != errSecSuccess {
            // The status only: the path may name the home folder.
            logger.error("event=host-app-signature-invalid status=\(status, privacy: .public)")
        }
        return status == errSecSuccess
    }

    /// This process's Team ID, read once from its own signature; nil when ad-hoc signed.
    static let ownTeamID: String? = {
        var me: SecCode?
        var staticMe: SecStaticCode?
        var info: CFDictionary?
        guard SecCodeCopySelf([], &me) == errSecSuccess, let me,
              SecCodeCopyStaticCode(me, [], &staticMe) == errSecSuccess, let staticMe,
              SecCodeCopySigningInformation(staticMe, SecCSFlags(rawValue: SecCSFlags.RawValue(kSecCSSigningInformation)),
                                            &info) == errSecSuccess,
              let team = (info as? [String: Any])?[kSecCodeInfoTeamIdentifier as String] as? String,
              !team.isEmpty else { return nil }
        return team
    }()
}
