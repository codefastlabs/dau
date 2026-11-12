// Text fields the simulated typist types into (TypistSimTests).
@testable import DauEngine

protocol SimField {
    init(_ options: EngineOptions, variant: SimVariant)
    /// One key: "⌫" is Backspace, everything else a typed character.
    mutating func press(_ key: Unicode.Scalar)
    var text: [Unicode.Scalar] { get }
}

/// Changes to Dấu that exist only here, to measure them in the simulator before anything
/// is decided (docs/research/EditingTypedText.md, section 4). Empty: Dấu as it is.
/// Nothing in Sources knows about them; they act on the engine's state from outside
/// (`@testable`) and on the test model of the input method (`ImkField`).
struct SimVariant: OptionSet, Hashable, Sendable {
    let rawValue: Int

    /// (b) Narrow H1. When a word-ending character made D4 restore a word, remember the
    /// text Dấu left (the keys). Kept through that character and at most one more
    /// word-ending character, then the ⌫ over them, then ⌫ inside the word (each drops
    /// the last remembered key); forgotten at any other key, a reset or an activation.
    /// At the first letter or mark key, inside the D20 read that key already makes: if
    /// the word read is exactly the remembered text, the remembered keys plus this key
    /// are typed again into a fresh engine; if that gives a valid prefix (D30) that
    /// differs from the keys as letters, the word is replaced with it (the D20
    /// `insertText`) and the engine goes on from those keys. Otherwise D20 as today.
    /// Not in underline mode, fields that ignore the replacement range (D43) or bursts
    /// (the model has none of those).
    static let restoredKeys = SimVariant(rawValue: 1)
    /// (b′) as (b), and also rewrite at the ⌫ itself when the remembered keys left form a
    /// full valid syllable (D31): "ddungsg␣⌫⌫" shows "đúng". Costs a read, a
    /// `selectedRange` and an `insertText` on that ⌫ (N3).
    static let rewriteOnBackspace = SimVariant(rawValue: 2)
    /// (c) H4 "tail typed straight": ⌫ that deletes a character added (passed through)
    /// while the word is locked by spelling (D30) puts the engine back as it was before
    /// that key, raw keys included (only the last raw key is dropped). Any other ⌫: D32.
    static let tailStraight = SimVariant(rawValue: 4)
    // (d), ⌫ that deletes the letter a double key added releases D26's lock, was measured
    // here and is Dấu's rule since 12/11/2026 (D26): it is in the engine, not a variant.

    var label: String {
        if isEmpty { return "a" }
        var parts: [String] = []
        if contains(.rewriteOnBackspace) { parts.append("b′") } else if contains(.restoredKeys) { parts.append("b") }
        if contains(.tailStraight) { parts.append("c") }
        return parts.joined(separator: "+")
    }

    /// The options of section 4, in table order.
    static let options: [SimVariant] = [
        [], [.restoredKeys], [.restoredKeys, .rewriteOnBackspace], [.tailStraight],
        [.restoredKeys, .tailStraight], [.restoredKeys, .rewriteOnBackspace, .tailStraight],
    ]
}

/// The engine alone, through the `Typist` helper: ⌫ over a space deletes it in the app,
/// and nothing reads the word before the caret back (that is the input method's job, D20).
/// Ignores `variant`.
struct EngineField: SimField {
    var typist: Typist
    init(_ options: EngineOptions, variant: SimVariant = []) { typist = Typist(options) }
    mutating func press(_ key: Unicode.Scalar) { typist.type(String(key)) }
    var text: [Unicode.Scalar] { typist.text }
}

/// The engine plus the test model of the input method's D20 reads that
/// `ExternalCasesTests` already uses (`ExternalCasesTests.d20Seed`, a port of
/// `InPlaceComposer.addMarks`/`seedWord`/`continueForeignWord`): after ⌫ empties the
/// engine, the next letter or mark key reads the word before the caret. The field is
/// synchronous (position and text always current), the caret always at the end.
///
/// Checked against the input method: `TypistSimTests.matrixRows` replays the rows of
/// docs/research/EditingTypedText.md, section 2, measured with the real `InPlaceComposer`
/// and a fake client, and expects the same text.
/// Not modelled: the 50 ms rule (`InPlaceComposer.settleInterval`, every read counts as
/// settled), apps that answer late or give no text, autocorrect (D20 "Từ hệ thống vừa
/// sửa"), underline mode (D13), fields that ignore the replacement range (D43), arrows
/// and clicks.
struct ImkField: SimField {
    var field: ExternalCasesTests.Field
    let method: EngineOptions.InputMethod
    let variant: SimVariant

    /// (b): the restored word, while the ⌫ over the characters after it have not all come
    /// (`after` of them left), then while inside it.
    enum Memory: Equatable {
        case ended(word: [Unicode.Scalar], after: Int)
        case inside([Unicode.Scalar])
    }
    var memory: Memory?
    /// (c): the engine before each character typed straight on a word locked by spelling.
    var tail: [VietEngine] = []

    /// False: the engine alone, as `Typist` drives it (no D20 read), with the variant.
    var reads = true

    init(_ options: EngineOptions, variant: SimVariant = []) {
        field = ExternalCasesTests.Field(engine: VietEngine(options: options))
        method = options.inputMethod
        self.variant = variant
    }

    var text: [Unicode.Scalar] { field.text }

    static func isBoundary(_ key: Unicode.Scalar) -> Bool {
        Letters.decompose(key.value) == nil && key.value >= 0x20 && key.value != 0x7F
    }

    mutating func press(_ key: Unicode.Scalar) {
        if key == "⌫" { backspace(); return }
        if key == "←" {
            // An arrow: D4 reset, the caret stays at the end here.
            field.engine.reset()
            field.knownNoWord = false
            memory = nil
            tail.removeAll()
            return
        }
        if key == "⏎" {
            field.apply(field.engine.endWord(), passing: nil)
            field.text.append("\n")
            field.knownNoWord = false
            memory = nil
            tail.removeAll()
            return
        }
        let before = field.engine
        let textBefore = field.text
        let remembered = memory
        memory = nil
        let mark = ExternalCasesTests.isMarkKey(key, method: method)
        var done = false

        if case .ended(let word, let after) = remembered, Self.isBoundary(key), after < 2 {
            memory = .ended(word: word, after: after + 1)
        }
        if reads, case .inside(let keys) = remembered, !field.engine.isComposing, !field.knownNoWord,
           mark || ExternalCasesTests.isLetter(key) {
            done = replay(keys, key)
        }

        if !done {
            var action: Action?
            if reads, !field.engine.isComposing, !field.knownNoWord, mark || ExternalCasesTests.isLetter(key) {
                action = ExternalCasesTests.d20Seed(&field, key: key, letter: !mark)
                if action == nil { field.engine.reset() }
            }
            field.apply(action ?? field.engine.handle(key), passing: key)
        }
        if !field.engine.isComposing { field.knownNoWord = true }

        // (b): a word-ending character that made D4 restore the word.
        if variant.contains(.restoredKeys), before.isComposing, before.lastShown != nil,
           !field.engine.isComposing, Self.isBoundary(key), field.text.last == key {
            let word = Array(ExternalCasesTests.trailingWord(Array(field.text.dropLast())))
            if word != before.shown, !word.isEmpty { memory = .ended(word: word, after: 1) }
        }
        // (c): a character typed straight on a word locked by spelling.
        if variant.contains(.tailStraight), field.engine.isSpellingLocked,
           field.text.count == textBefore.count + 1, field.text.last == key,
           field.text.starts(with: textBefore) {
            tail.append(before)
        } else {
            tail.removeAll()
        }

    }

    /// (b) at the D20 read: the remembered keys and `key` typed into a fresh engine.
    mutating func replay(_ keys: [Unicode.Scalar], _ key: Unicode.Scalar) -> Bool {
        let window = Array(field.text.suffix(16))
        guard keys.count < window.count || keys.count == field.text.count,
              ExternalCasesTests.trailingWord(window) == keys else { return false }
        var e = VietEngine(options: field.engine.options)
        for k in keys { _ = e.handle(k) }
        _ = e.handle(key)
        guard e.isComposing, !e.isSpellingLocked, e.lastShown != nil, e.shown != keys + [key] else { return false }
        field.text.removeLast(keys.count)
        field.text.append(contentsOf: e.shown)
        field.engine = e
        return true
    }

    mutating func backspace() {
        let remembered = memory
        memory = nil
        if variant.contains(.tailStraight), field.engine.isSpellingLocked, let snapshot = tail.popLast() {
            field.engine = snapshot
            if !field.text.isEmpty { field.text.removeLast() }
            if !field.engine.isComposing { field.knownNoWord = false }
            return
        }
        tail.removeAll()
        let composing = field.engine.isComposing
        let action = field.engine.backspace()
        if case .passThrough = action {
            if !field.text.isEmpty { field.text.removeLast() }
        } else {
            field.apply(action, passing: nil)
        }
        if !field.engine.isComposing { field.knownNoWord = false }

        guard !composing else { return }
        switch remembered {
        case .ended(let word, let after):
            memory = after > 1 ? .ended(word: word, after: after - 1) : .inside(word)
        case .inside(var keys):
            keys.removeLast()
            guard !keys.isEmpty else { return }
            memory = .inside(keys)
            if variant.contains(.rewriteOnBackspace) { rewriteAtBackspace(keys) }
        case nil:
            break
        }
    }

    /// (b′): the keys left form a full syllable: show it now.
    mutating func rewriteAtBackspace(_ keys: [Unicode.Scalar]) {
        guard ExternalCasesTests.trailingWord(Array(field.text.suffix(16))) == keys else { return }
        var e = VietEngine(options: field.engine.options)
        for k in keys { _ = e.handle(k) }
        guard e.isComposing, !e.isSpellingLocked, e.lastShown != nil, e.shown != keys else { return }
        var end = e
        guard case .passThrough = end.endWord() else { return }
        field.text.removeLast(keys.count)
        field.text.append(contentsOf: e.shown)
        field.engine = e
        memory = nil
    }
}
