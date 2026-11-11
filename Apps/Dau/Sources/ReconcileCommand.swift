import Foundation

/// `Dau --reconcile-input-method`, in Debug and Release builds: runs what the app runs at
/// launch (`InputMethodInstaller.reconcile`, D37), prints one line to standard output and
/// exits, without opening a window. Install scripts call it after they put a new Dấu.app
/// in place.
///
/// Run the binary inside the bundle directly (not through `open`), so the line and the
/// exit status reach the caller. The exit status says what happened
/// (`Status`; docs/Architecture.md lists the values).
enum ReconcileCommand {
    static let flag = "--reconcile-input-method"

    /// The exit statuses. 2 is left out: a command line that cannot be read, as in the
    /// debug commands.
    enum Status: Int32, CaseIterable, Sendable {
        /// The installed input method already is the one inside this copy.
        case alreadyCurrent = 0
        /// An error: nothing inside the app to install, or the copy, the signature check
        /// of the new bundle or the swap failed. A registration that fails after the swap
        /// is not one: `reconcile` logs its status and still reports `replaced`.
        case failed = 1
        /// The installed input method differed and was replaced.
        case replaced = 3
        /// No input method is installed, or it went away while the command ran: nothing
        /// done (the first install is the user's).
        case notInstalled = 4
        /// This copy of Dấu is not the owner copy: nothing read, nothing touched.
        case notOwnerCopy = 5
        /// The installed input method's signature is wrong: not replaced.
        case badSignature = 6
        /// The installed bundle has another identity or cannot be read: not replaced.
        case skipped = 7

        /// The word the printed line starts with.
        var word: String {
            switch self {
            case .alreadyCurrent: "already-current"
            case .failed: "failed"
            case .replaced: "replaced"
            case .notInstalled: "not-installed"
            case .notOwnerCopy: "not-owner-copy"
            case .badSignature: "bad-signature"
            case .skipped: "skipped"
            }
        }
    }

    struct Report: Equatable, Sendable {
        let status: Status
        /// The one line printed: "reconcile-input-method: <word>: <what it means>".
        let line: String
    }

    /// Whether the arguments (the first is the program) ask for the command.
    static func isRequested(_ arguments: [String]) -> Bool {
        arguments.dropFirst().contains(flag)
    }

    static func report(_ result: Result<ReconcileOutcome, Error>) -> Report {
        let (status, meaning): (Status, String)
        switch result {
        case .success(.alreadyCurrent):
            (status, meaning) = (.alreadyCurrent, "the installed input method is the one inside this copy of Dấu")
        case .success(.replaced):
            (status, meaning) = (.replaced, "the installed input method was replaced by the one inside this copy of Dấu")
        case .success(.notInstalled):
            (status, meaning) = (.notInstalled, "no input method is installed; nothing done")
        case .success(.notOwnerCopy):
            (status, meaning) = (.notOwnerCopy, "this copy of Dấu is not the one in the Applications folder; nothing done")
        case .success(.badSignature):
            (status, meaning) = (.badSignature, "the installed input method's signature is invalid or from another team; not replaced")
        case .success(.skipped(let why)):
            (status, meaning) = (.skipped, "not replaced (\(why))")
        case .failure(let error):
            (status, meaning) = (.failed, String(describing: error))
        }
        // One line, whatever an error's text holds.
        let text = meaning.split(whereSeparator: \.isNewline).joined(separator: " ")
        return Report(status: status, line: "reconcile-input-method: \(status.word): \(text)")
    }

    @MainActor
    static func run(_ installer: InputMethodInstaller) async -> Report {
        do {
            return report(.success(try await installer.reconcile()))
        } catch {
            return report(.failure(error))
        }
    }

    /// Runs the command if `arguments` contain the flag; never returns in that case.
    @MainActor
    static func runIfRequested(_ arguments: [String] = CommandLine.arguments) {
        guard isRequested(arguments) else { return }
        Task { @MainActor in
            let report = await run(SystemInputMethodInstaller.standard())
            print(report.line)
            exit(report.status.rawValue)
        }
        // No NSApplication: no window, no Dock icon. The main run loop runs the main
        // actor's jobs (the installer's waits), and `NSRunningApplication` updates what
        // changes over time (the input method has exited) only while the main run loop
        // runs (https://developer.apple.com/documentation/appkit/nsrunningapplication).
        RunLoop.main.run()
        // Only reached if the run loop had nothing to wait on.
        dispatchMain()
    }
}
