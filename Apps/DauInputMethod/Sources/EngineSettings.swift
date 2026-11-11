import DauEngine
import DauShared

/// Applies settings to one controller's engine. Pure, unit tested.
enum EngineSettings {
    /// Gives `engine` the options of `settings`. When they differ, the word being typed
    /// is dropped first (`reset()`): its letters were built under the old rules (another
    /// typing method, tone placement…), and continuing it under the new ones could
    /// replace text the user never typed that way. Nothing is restored (D4: only a word
    /// boundary restores).
    ///
    /// Returns true if the options changed (and the engine was reset).
    @discardableResult
    static func apply(_ settings: DauSettings, to engine: inout VietEngine) -> Bool {
        let options = settings.engineOptions
        guard engine.options != options else { return false }
        engine.reset()
        engine.options = options
        return true
    }
}

/// Coalesces change notifications that come in a burst into one reload (D18 spirit: any
/// process may post the settings change notification, as often as it likes, and each
/// reload decodes the settings). The first change schedules a reload after `delay`;
/// changes until it runs are folded into it. The reload clears the mark before it reads,
/// so a change that comes while it reads schedules the next one: no change is lost.
///
/// Pure value type, unit tested in DauInputMethodTests.
struct ChangeCoalescer {
    /// Time from the first change of a burst to the reload: short enough that a change
    /// made in the Settings app shows by the next key a person types after it.
    static let delay: Double = 0.1

    /// A reload is scheduled and has not run yet.
    private(set) var isScheduled = false

    /// A change came. True when the caller must schedule a reload (none is scheduled).
    mutating func noteChange() -> Bool {
        guard !isScheduled else { return false }
        isScheduled = true
        return true
    }

    /// The scheduled reload runs now (call before reading the settings).
    mutating func willReload() {
        isScheduled = false
    }
}
