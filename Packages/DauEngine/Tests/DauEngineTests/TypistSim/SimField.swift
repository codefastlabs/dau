// Text fields the simulated typist types into (TypistSimTests).
import DauEngine

protocol SimField {
    init(_ options: EngineOptions)
    /// One key: "⌫" is Backspace, everything else a typed character.
    mutating func press(_ key: Unicode.Scalar)
    var text: [Unicode.Scalar] { get }
}

/// The engine alone, through the `Typist` helper: ⌫ over a space deletes it in the app,
/// and nothing reads the word before the caret back (that is the input method's job, D20).
struct EngineField: SimField {
    var typist: Typist
    init(_ options: EngineOptions) { typist = Typist(options) }
    mutating func press(_ key: Unicode.Scalar) { typist.type(String(key)) }
    var text: [Unicode.Scalar] { typist.text }
}

/// The engine plus the test model of the input method's D20 reads that
/// `ExternalCasesTests` already uses (`ExternalCasesTests.d20Seed`, a mirror of
/// `InPlaceComposer`): after ⌫ empties the engine, the next letter or mark key reads the
/// word before the caret. Only for the corrections that are outside the engine's scope;
/// it is a model, not the input method (no 50 ms rule, no late answers, no underline).
struct MirrorField: SimField {
    var field: ExternalCasesTests.Field
    let method: EngineOptions.InputMethod

    init(_ options: EngineOptions) {
        field = ExternalCasesTests.Field(engine: VietEngine(options: options))
        method = options.inputMethod
    }

    var text: [Unicode.Scalar] { field.text }

    mutating func press(_ key: Unicode.Scalar) {
        if key == "⌫" {
            let action = field.engine.backspace()
            if case .passThrough = action {
                if !field.text.isEmpty { field.text.removeLast() }
            } else {
                field.apply(action, passing: nil)
            }
            if !field.engine.isComposing { field.knownNoWord = false }
            return
        }
        var action: Action?
        let mark = ExternalCasesTests.isMarkKey(key, method: method)
        if !field.engine.isComposing, !field.knownNoWord, mark || ExternalCasesTests.isLetter(key) {
            action = ExternalCasesTests.d20Seed(&field, key: key, letter: !mark)
            if action == nil { field.engine.reset() }
        }
        field.apply(action ?? field.engine.handle(key), passing: key)
        if !field.engine.isComposing { field.knownNoWord = true }
    }
}
