import Foundation
import Testing
@testable import DauShared

/// The input method decodes the settings at every activation and at every change
/// notification, which any process can post: loading many app rules must stay cheap.
@Suite("App rules at scale")
struct AppRuleLoadTests {
    @Test("the init keeps one rule per bundle ID: the later wins, in the first one's place")
    func mergeOrder() {
        let settings = DauSettings(appRules: [
            AppRule(bundleID: "a", underline: false),
            AppRule(bundleID: "b"),
            AppRule(bundleID: "a", underline: true),
            AppRule(bundleID: "c"),
            AppRule(bundleID: "b", displayName: "B"),
        ])
        #expect(settings.appRules.map(\.bundleID) == ["a", "b", "c"])
        #expect(settings.rule(for: "a")?.underline == true)
        #expect(settings.rule(for: "b")?.displayName == "B")
        // Same result as upserting one rule at a time.
        var upserted = DauSettings()
        for rule in [AppRule(bundleID: "a"), AppRule(bundleID: "b"), AppRule(bundleID: "a", underline: true)] {
            upserted.upsert(rule)
        }
        #expect(upserted.appRules == DauSettings(appRules: [AppRule(bundleID: "a"), AppRule(bundleID: "b"),
                                                            AppRule(bundleID: "a", underline: true)]).appRules)
    }

    @Test("50,000 rules build in well under half a second (O(n), was O(n²))")
    func initIsLinear() {
        let rules = (0..<50_000).map { AppRule(bundleID: "com.example.app\($0)") }
        let clock = ContinuousClock()
        let elapsed = clock.measure { _ = DauSettings(appRules: rules) }
        #expect(elapsed < .milliseconds(500))
        #expect(DauSettings(appRules: rules).appRules.count == 50_000)
    }

    @Test("decoding reads at most maxAppRules elements, fast even for 50,000")
    func decodeCap() throws {
        let rules = (0..<50_000).map { AppRule(bundleID: "com.example.app\($0)") }
        var big = DauSettings()
        for chunk in stride(from: 0, to: rules.count, by: 10_000) {
            // Built through the init so the test does not depend on upsert's cost.
            big = DauSettings(appRules: big.appRules + rules[chunk..<min(chunk + 10_000, rules.count)])
        }
        let data = try JSONEncoder().encode(big)
        let clock = ContinuousClock()
        var decoded = DauSettings()
        let elapsed = try clock.measure { decoded = try JSONDecoder().decode(DauSettings.self, from: data) }
        #expect(elapsed < .milliseconds(500))
        #expect(decoded.appRules.count == DauSettings.maxAppRules)
        #expect(decoded.appRules.first?.bundleID == "com.example.app0")
    }

    @Test("malformed elements are dropped; a non-array or null is empty")
    func decodeLenient() throws {
        let json = #"{"appRules":[{"bundleID":"a"},{"nope":1},{"bundleID":""},{"bundleID":"b"}]}"#
        let settings = try JSONDecoder().decode(DauSettings.self, from: Data(json.utf8))
        #expect(settings.appRules.map(\.bundleID) == ["a", "b"])
        let notArray = try JSONDecoder().decode(DauSettings.self, from: Data(#"{"appRules":{"a":1}}"#.utf8))
        #expect(notArray.appRules.isEmpty)
        let null = try JSONDecoder().decode(DauSettings.self, from: Data(#"{"appRules":null}"#.utf8))
        #expect(null.appRules.isEmpty)
    }
}
