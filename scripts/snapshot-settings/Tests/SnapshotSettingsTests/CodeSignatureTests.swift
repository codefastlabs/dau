import Foundation
import Testing
@testable import SnapshotSettings

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
        let text = CodeSignature.requirementText(identifier: "com.codefastlabs.dau.inputmethod.Dau", teamID: "M58DANM3ZP")
        #expect(text == "anchor apple generic and identifier \"com.codefastlabs.dau.inputmethod.Dau\" and certificate leaf[subject.OU] = \"M58DANM3ZP\"")
    }

    @Test(arguments: [("", "TEAM"), ("com.x", ""), ("com.x\" or true", "TEAM"), ("com.x", "TE AM"), ("com.x", "T\"")])
    func requirementRefusesValuesItCannotQuote(identifier: String, team: String) {
        #expect(CodeSignature.requirementText(identifier: identifier, teamID: team) == nil)
    }

    @Test func noRequirementIsNeverValid() throws {
        let tool = try adHocBinary(identifier: "com.codefastlabs.dau.inputmethod.Dau")
        defer { try? FileManager.default.removeItem(at: tool.folder) }
        #expect(!CodeSignature.isValid(tool.url, requirement: nil))
    }

    /// The case the old Team ID comparison let through: an ad-hoc signature with the right
    /// identifier has no Team ID, like an ad-hoc host app.
    @Test func adHocSignatureFailsTheRequirement() throws {
        let identifier = "com.codefastlabs.dau.inputmethod.Dau"
        let tool = try adHocBinary(identifier: identifier)
        defer { try? FileManager.default.removeItem(at: tool.folder) }
        let requirement = CodeSignature.requirementText(identifier: identifier, teamID: "M58DANM3ZP")
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
