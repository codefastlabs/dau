import Foundation
import Testing
import DauEngine

/// Replays every typed example the website shows (`site/src/data/TypingExamples.json`)
/// so the site cannot show text the engine does not produce.
@Suite("Website typing examples")
struct WebsiteExamplesTests {
    struct Example: Decodable, Sendable, CustomTestStringConvertible {
        struct Settings: Decodable, Sendable {
            let tonePlacement: String?
        }

        let id: String
        let method: String
        let keys: String
        let expected: String
        let settings: Settings?
        let typedWord: String?
        let frames: [String]?

        var testDescription: String { id }

        var options: EngineOptions {
            var options = EngineOptions()
            options.inputMethod = method == "vni" ? .vni : .telex
            if settings?.tonePlacement == "classic" { options.tonePlacement = .classic }
            return options
        }
    }

    struct File: Decodable {
        let examples: [Example]
    }

    static let fileURL: URL = {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { url.deleteLastPathComponent() }
        return url.appendingPathComponent("site/src/data/TypingExamples.json")
    }()

    static let examples: [Example] = {
        do {
            return try JSONDecoder().decode(File.self, from: Data(contentsOf: fileURL)).examples
        } catch {
            Issue.record("cannot load \(fileURL.path): \(error)")
            return []
        }
    }()

    @Test func fileHasUniqueIds() {
        #expect(!Self.examples.isEmpty)
        let ids = Self.examples.map(\.id)
        #expect(Set(ids).count == ids.count, "duplicate ids in TypingExamples.json")
    }

    @Test(arguments: examples)
    func engineProducesExpectedText(_ example: Example) {
        var field = Typist(example.options)
        if let word = example.typedWord {
            let seeded = field.seed(word)
            #expect(seeded, "engine cannot take typedWord \"\(word)\"")
        }
        field.type(example.keys)
        #expect(
            field.text.map(\.value) == scalars(example.expected),
            "\(example.id): \"\(example.keys)\" gave \"\(field.string)\", expected \"\(example.expected)\""
        )
    }

    @Test(arguments: examples.filter { $0.frames != nil })
    func framesMatchFieldAfterEachKey(_ example: Example) {
        guard let frames = example.frames else { return }
        var field = Typist(example.options)
        if let word = example.typedWord { _ = field.seed(word) }
        var typedFrames: [String] = []
        for key in example.keys.unicodeScalars {
            field.type(String(key))
            typedFrames.append(field.string)
        }
        #expect(typedFrames.map { scalars($0) } == frames.map { scalars($0) }, "\(example.id): frames differ from the field after each key: \(typedFrames)")
        #expect(frames.last == example.expected, "\(example.id): last frame is not expected")
    }
}
