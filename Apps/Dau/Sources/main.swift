import Foundation

// The interface follows the macOS language list (D41): the bundle's development
// language is English and macOS picks the first language Dấu has, else English. A
// -AppleLanguages argument on the command line still picks the language, for checks.

// `--reconcile-input-method` (Debug and Release): what the app does to the installed
// input method at launch (D37), without a window; prints one line and exits.
ReconcileCommand.runIfRequested()

#if DEBUG
// Debug checks that run in the built app without opening a window: each
// prints one value and exits.
DebugSettingsCommand.runIfRequested()
if CommandLine.arguments.contains("--print-localizations") {
    print(Bundle.main.preferredLocalizations)
    exit(0)
}
if CommandLine.arguments.contains("--print-input-source-name") {
    // Dấu's input source as macOS names it, in the system's languages (D41).
    print(SystemUINames.system().dauInputSource)
    exit(0)
}
#endif

DauApp.main()
