import Foundation
import notify

/// How the host app asks the running input method to quit (D7, D16, D37): after the
/// bundle in ~/Library/Input Methods was replaced (upgrade) or before it is moved to the
/// Trash (uninstall). The host posts a Darwin notification; the input method commits
/// the word it shows (underline mode) and exits, and macOS launches the new bundle at
/// the next key. No signal to any system process (`imklaunchagent` and the like are
/// never touched, docs/research/INPUT-METHOD-INSTALL.md section 3).
///
/// The name is derived from the input method's bundle ID, which never changes between
/// versions (D37), so an old input method hears a new host app.
///
/// Any process of the user can post a Darwin notification, and it says nothing about the
/// sender. So the input method quits only when its bundle on disk is no longer the one it
/// was launched from (`BundleFile`): replaced by an upgrade, or moved to the Trash by an
/// uninstall (the host app moves it first, then asks). A request out of the blue is
/// ignored instead of breaking the word being typed every time it is posted.
public enum InputMethodLifecycle {
    /// Which file a path points to: inode and modification time of the executable. A
    /// bundle swapped in by `renamex_np` or moved away no longer matches.
    public struct BundleFile: Equatable, Sendable {
        let inode: UInt64
        let modified: Int64

        /// nil when nothing is at `path`.
        public static func at(_ path: String) -> BundleFile? {
            var info = stat()
            guard stat(path, &info) == 0 else { return nil }
            return BundleFile(inode: UInt64(info.st_ino),
                              modified: Int64(info.st_mtimespec.tv_sec) * 1_000_000_000 + Int64(info.st_mtimespec.tv_nsec))
        }
    }

    /// Whether a quit request should be honoured: the executable at launch is no longer
    /// the one on disk (replaced or gone). Unknown at launch: honour it (old behaviour).
    public static func shouldQuit(launchedFrom launch: BundleFile?, now current: BundleFile?) -> Bool {
        guard let launch else { return true }
        return current != launch
    }

    public static func quitNotificationName(inputMethodBundleID: String) -> String {
        inputMethodBundleID + ".quitRequested"
    }

    /// Asks the input method with this bundle ID to quit.
    public static func requestQuit(inputMethodBundleID: String) {
        notify_post(quitNotificationName(inputMethodBundleID: inputMethodBundleID))
    }

    /// Calls `handler` on `queue` whenever a quit is requested. Keep the returned object
    /// alive; `nil` if the system refuses the registration.
    public static func observeQuitRequests(
        inputMethodBundleID: String,
        on queue: DispatchQueue,
        handler: @escaping @Sendable () -> Void
    ) -> SettingsChangeObserver? {
        SettingsChangeObserver(name: quitNotificationName(inputMethodBundleID: inputMethodBundleID),
                               queue: queue, handler: handler)
    }
}
