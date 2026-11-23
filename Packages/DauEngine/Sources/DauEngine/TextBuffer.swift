// Fixed-capacity scalar storage and the engine's output type.
// Pure Swift, no Foundation (D10).

/// A short run of Unicode scalars stored inline in a `SIMD32<UInt32>`.
///
/// Inline SIMD storage: no allocation per key (docs/Architecture.md, "DauEngine"; D33).
/// `InlineArray` needs macOS 26, Dấu targets macOS 14 (D1).
///
/// Capacity 32 covers the largest text the engine ever emits: a restore of the
/// keystroke baseline (at most `VietEngine.rawCapacity` = 31 scalars) plus the
/// word-ending key.
public struct TextBuffer: Sendable, RandomAccessCollection, Equatable, CustomStringConvertible {
    public static let capacity = 32

    @usableFromInline var storage = SIMD32<UInt32>()
    @usableFromInline var length: Int = 0

    public init() {}

    public var startIndex: Int { 0 }
    public var endIndex: Int { length }

    public subscript(position: Int) -> Unicode.Scalar {
        precondition(position >= 0 && position < length, "TextBuffer index out of range")
        // Storage only ever holds values that came from valid scalars.
        return Unicode.Scalar(storage[position]) ?? "\u{FFFD}"
    }

    /// Raw scalar value at `position` (no Optional unwrapping).
    @inlinable func value(at position: Int) -> UInt32 { storage[position] }

    @inlinable mutating func append(_ value: UInt32) {
        precondition(length < TextBuffer.capacity, "TextBuffer overflow")
        storage[length] = value
        length += 1
    }

    @inlinable mutating func removeAll() {
        storage = SIMD32<UInt32>()
        length = 0
    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        if lhs.length != rhs.length { return false }
        var i = 0
        while i < lhs.length {
            if lhs.storage[i] != rhs.storage[i] { return false }
            i += 1
        }
        return true
    }

    /// Debug/test description. Not used on the hot path.
    public var description: String {
        var s = String.UnicodeScalarView()
        for scalar in self { s.append(scalar) }
        return String(s)
    }
}

/// What the input method should do with the key it just passed to the engine.
public enum Action: Sendable, Equatable {
    /// Nothing to replace: the key's own character (if any) goes in unchanged; the IMK
    /// layer inserts it (N3).
    case passThrough
    /// Delete `deleteCount` Unicode scalars immediately before the cursor and insert
    /// `insert` in their place, in one `insertText(_:replacementRange:)` call (N3).
    /// The key is consumed (IMK returns `true`); `insert` already contains whatever
    /// the key itself should produce, including a word-ending key such as Space.
    ///
    /// `deleteCount` counts Unicode scalars of the text the engine believes is on
    /// screen. Precomposed Vietnamese letters are all in the BMP, so this equals the
    /// UTF-16 length unless the word was seeded (D20) from decomposed (NFD) text, in
    /// which case the IMK layer must measure the seeded string itself.
    case replace(deleteCount: Int, insert: TextBuffer)
}
