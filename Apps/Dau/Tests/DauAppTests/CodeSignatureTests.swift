import Foundation
import Testing
import Security
@testable import Dau

// D37: the installed input method must meet a code requirement (Apple-issued certificate,
// this app's team, the input method's identifier), not merely carry the same Team ID as
// the app: two ad-hoc signatures both have no Team ID. The binaries are temp copies of
// /usr/bin/true, signed ad hoc here.

/// A temp copy of /usr/bin/true signed ad hoc with `identifier`.
private func adHocBinary(identifier: String) throws -> (url: URL, folder: URL) {
    let folder = FileManager.default.temporaryDirectory.appendingPathComponent("dau-sig-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    let url = folder.appendingPathComponent("tool")
    try FileManager.default.copyItem(at: URL(fileURLWithPath: "/usr/bin/true"), to: url)
    let codesign = Process()
    codesign.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
    codesign.arguments = ["--force", "--sign", "-", "--identifier", identifier, url.path]
    codesign.standardError = FileHandle.nullDevice
    try codesign.run()
    codesign.waitUntilExit()
    #expect(codesign.terminationStatus == 0)
    return (url, folder)
}

@Suite("Code signature requirement (D37)")
struct CodeSignatureTests {
    @Test func requirementNamesIdentifierTeamAndApple() {
        let text = CodeSignature.requirementText(identifier: "com.codefastlabs.dau.inputmethod.Dau", teamIDs: ["M58DANM3ZP"])
        #expect(text == "anchor apple generic and identifier \"com.codefastlabs.dau.inputmethod.Dau\" and certificate leaf[subject.OU] = \"M58DANM3ZP\"")
    }

    @Test(arguments: [("", "TEAM"), ("com.x", ""), ("com.x\" or true", "TEAM"), ("com.x", "TE AM"), ("com.x", "T\"")])
    func requirementRefusesValuesItCannotQuote(identifier: String, team: String) {
        #expect(CodeSignature.requirementText(identifier: identifier, teamIDs: [team]) == nil)
    }

    @Test func noRequirementIsNeverValid() throws {
        let tool = try adHocBinary(identifier: "com.codefastlabs.dau.inputmethod.Dau")
        defer { try? FileManager.default.removeItem(at: tool.folder) }
        #expect(!CodeSignature.isValid(tool.url, requirement: nil))
    }

    /// The case a Team ID comparison would let through: an ad-hoc signature with the right
    /// identifier has no Team ID, like an ad-hoc host app.
    @Test func adHocSignatureFailsTheRequirement() throws {
        let identifier = "com.codefastlabs.dau.inputmethod.Dau"
        let tool = try adHocBinary(identifier: identifier)
        defer { try? FileManager.default.removeItem(at: tool.folder) }
        let requirement = CodeSignature.requirementText(identifier: identifier, teamIDs: ["M58DANM3ZP"])
        #expect(!CodeSignature.isValid(tool.url, requirement: requirement))
    }

    /// Control: the same binary meets a requirement it does satisfy, so the failure above
    /// is the requirement, not an unreadable signature.
    @Test func adHocSignatureMeetsItsOwnIdentifier() throws {
        let tool = try adHocBinary(identifier: "test.dau.adhoc")
        defer { try? FileManager.default.removeItem(at: tool.folder) }
        #expect(CodeSignature.isValid(tool.url, requirement: "identifier \"test.dau.adhoc\""))
        #expect(!CodeSignature.isValid(tool.url, requirement: "identifier \"other\""))
    }

    @Test func unsignedFileIsNotValid() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("dau-sig-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("plain")
        try Data("not code".utf8).write(to: url)
        #expect(!CodeSignature.isValid(url, requirement: "identifier \"x\""))
    }
}

/// D37, "Danh tính phát hành trước": a host signed by another team than the Personal Team
/// that signed earlier releases takes an input method of that Personal Team for an older
/// build of itself; any other team still gets the banner.
@Suite("Signing teams of the input method (D37)")
struct InputMethodSigningTeamsTests {
    static let personalTeam = "M58DANM3ZP"
    static let developerIDTeam = "ABCDE12345"

    @Test func previousReleaseTeamIsThePersonalTeam() {
        #expect(InputMethodSigningTeams.previousReleaseTeamID == "M58DANM3ZP")
    }

    @Test("installed input method trusted or not, by host team and installed team", arguments: [
        ("ABCDE12345", "M58DANM3ZP", true),
        ("ABCDE12345", "ABCDE12345", true),
        ("ABCDE12345", "ZZZZZ99999", false),
        ("M58DANM3ZP", "M58DANM3ZP", true),
        ("M58DANM3ZP", "ABCDE12345", false),
        ("M58DANM3ZP", "ZZZZZ99999", false),
    ])
    func installedTrust(host: String, installedBy team: String, trusted: Bool) {
        #expect(InputMethodSigningTeams(hostTeamID: host).installed.contains(team) == trusted)
    }

    @Test("the staged copy is the embedded one: the host's team only, whatever the host", arguments: ["ABCDE12345", "M58DANM3ZP"])
    func stagedIsHostOnly(host: String) {
        #expect(InputMethodSigningTeams(hostTeamID: host).staged == [host])
    }

    @Test func hostOnPersonalTeamChangesNothing() {
        #expect(InputMethodSigningTeams(hostTeamID: Self.personalTeam).installed == [Self.personalTeam])
    }

    @Test func requirementOfTwoTeamsTakesEitherLeaf() throws {
        let identifier = "com.codefastlabs.dau.inputmethod.Dau"
        let teams = InputMethodSigningTeams(hostTeamID: Self.developerIDTeam).installed
        let text = try #require(CodeSignature.requirementText(identifier: identifier, teamIDs: teams))
        #expect(text == "anchor apple generic and identifier \"\(identifier)\" and "
                + "(certificate leaf[subject.OU] = \"ABCDE12345\" or certificate leaf[subject.OU] = \"M58DANM3ZP\")")
        var requirement: SecRequirement?
        #expect(SecRequirementCreateWithString(text as CFString, [], &requirement) == errSecSuccess)
    }

    @Test func requirementRefusesNoTeamOrOneTeamItCannotQuote() {
        #expect(CodeSignature.requirementText(identifier: "com.x", teamIDs: []) == nil)
        #expect(CodeSignature.requirementText(identifier: "com.x", teamIDs: ["TEAM", "T\" or true"]) == nil)
    }

    /// An invalid signature (ad hoc, no team) meets neither team.
    @Test func adHocSignatureFailsTheTwoTeamRequirement() throws {
        let identifier = "com.codefastlabs.dau.inputmethod.Dau"
        let tool = try adHocBinary(identifier: identifier)
        defer { try? FileManager.default.removeItem(at: tool.folder) }
        let teams = InputMethodSigningTeams(hostTeamID: Self.developerIDTeam).installed
        #expect(!CodeSignature.isValid(tool.url, requirement: CodeSignature.requirementText(identifier: identifier, teamIDs: teams)))
    }

    /// Control for the grouping the two-team requirement relies on: the "and" before the
    /// parentheses holds for every branch of the "or".
    @Test func parenthesizedOrBindsUnderAnd() throws {
        let tool = try adHocBinary(identifier: "test.dau.adhoc")
        defer { try? FileManager.default.removeItem(at: tool.folder) }
        #expect(CodeSignature.isValid(tool.url, requirement: "identifier \"test.dau.adhoc\" and (identifier \"x\" or identifier \"test.dau.adhoc\")"))
        #expect(!CodeSignature.isValid(tool.url, requirement: "identifier \"x\" and (identifier \"y\" or identifier \"test.dau.adhoc\")"))
    }
}
