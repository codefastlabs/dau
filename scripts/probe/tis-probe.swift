// Read-only probe for the "new input source without logging out" experiments (docs/research/M5-INSTALL.md 8.2).
// Side effects: none
//
//   tis-probe            prints ONE line of JSON and exits
//   tis-probe --watch    prints one snapshot line first, then one per distributed notification
//                        (kTISNotifyEnabledKeyboardInputSourcesChanged, kTISNotifySelectedKeyboardInputSourceChanged)
//
// Always run it as a fresh process: the TIS flags of a process that called Register are not
// trusted (measured on macOS 27.2). Cross-check "recordedThirdParty" (the record System Settings
// keeps in com.apple.inputsources) against the TIS "enabled" flags.
// Built by scripts/probe/step.sh with swiftc; it never registers, enables, selects or disables.
import AppKit
import Carbon
import Foundation

func stringProperty(_ source: TISInputSource, _ key: CFString) -> String? {
    guard let raw = TISGetInputSourceProperty(source, key) else { return nil }
    return Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
}

func boolProperty(_ source: TISInputSource, _ key: CFString) -> Bool {
    guard let raw = TISGetInputSourceProperty(source, key) else { return false }
    return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(raw).takeUnretainedValue())
}

func iso(_ date: Date) -> String {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    f.timeZone = TimeZone.current
    return f.string(from: date)
}

/// Turns a property list value into something JSONSerialization accepts.
func jsonSafe(_ value: Any) -> Any {
    switch value {
    case let d as Date: return iso(d)
    case let dict as [String: Any]: return dict.mapValues(jsonSafe)
    case let array as [Any]: return array.map(jsonSafe)
    case let data as Data: return "data:\(data.count)"
    case is String, is NSNumber: return value
    default: return String(describing: value)
    }
}

func bundlePath(for source: TISInputSource, bundleID: String?) -> String? {
    if let raw = TISGetInputSourceProperty(source, kTISPropertyIconImageURL) {
        let url = Unmanaged<CFURL>.fromOpaque(raw).takeUnretainedValue() as URL
        let path = url.path
        if let range = path.range(of: ".app/") ?? path.range(of: ".app", options: .backwards), path.hasPrefix("/") {
            return String(path[..<range.lowerBound]) + ".app"
        }
    }
    if let bundleID, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
        return url.path
    }
    return nil
}

func sources() -> [[String: Any]] {
    guard let list = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else { return [] }
    var out: [[String: Any]] = []
    for source in list {
        guard let id = stringProperty(source, kTISPropertyInputSourceID), id.contains("dau.inputmethod") else { continue }
        let bundleID = stringProperty(source, kTISPropertyBundleID)
        var item: [String: Any] = [
            "id": id,
            "type": stringProperty(source, kTISPropertyInputSourceType) ?? "",
            "localizedName": stringProperty(source, kTISPropertyLocalizedName) ?? "",
            "enabled": boolProperty(source, kTISPropertyInputSourceIsEnabled),
            "enableCapable": boolProperty(source, kTISPropertyInputSourceIsEnableCapable),
            "selectCapable": boolProperty(source, kTISPropertyInputSourceIsSelectCapable),
            "selected": boolProperty(source, kTISPropertyInputSourceIsSelected),
        ]
        if let bundleID { item["bundleID"] = bundleID }
        if let path = bundlePath(for: source, bundleID: bundleID) { item["bundlePath"] = path }
        out.append(item)
    }
    return out.sorted { ($0["id"] as? String ?? "") < ($1["id"] as? String ?? "") }
}

func recordedThirdParty() -> [[String: Any]] {
    let value = CFPreferencesCopyAppValue("AppleEnabledThirdPartyInputSources" as CFString, "com.apple.inputsources" as CFString)
    let entries = (value as? [[String: Any]]) ?? []
    return entries.filter { entry in
        entry.values.contains { v in
            guard let s = v as? String else { return false }
            return s.contains("DauProbe") || s.contains("dau.inputmethod")
        }
    }.map { jsonSafe($0) as? [String: Any] ?? [:] }
}

func updateTime() -> Any {
    for domain in ["com.apple.inputsources", "com.apple.HIToolbox"] {
        if let v = CFPreferencesCopyAppValue("AppleInputSourceUpdateTime" as CFString, domain as CFString) {
            return ["domain": domain, "value": jsonSafe(v)] as [String: Any]
        }
    }
    return NSNull()
}

func cacheFiles() -> [[String: Any]] {
    var buffer = [Int8](repeating: 0, count: Int(PATH_MAX))
    guard confstr(_CS_DARWIN_USER_CACHE_DIR, &buffer, buffer.count) > 0 else { return [] }
    let dir = String(cString: buffer) + "/com.apple.Keyboard-Settings.extension"
    let names = (try? FileManager.default.contentsOfDirectory(atPath: dir)) ?? []
    return names.filter { $0.hasPrefix("com.apple.IntlDataCache.le") }.sorted().compactMap { name in
        let path = dir + "/" + name
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
              let date = attrs[.modificationDate] as? Date else { return nil }
        return ["file": name, "mtime": iso(date), "size": (attrs[.size] as? NSNumber) ?? 0]
    }
}

func probeProcesses() -> [[String: Any]] {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/ps")
    task.arguments = ["-axww", "-o", "pid=,command="]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = FileHandle.nullDevice
    guard (try? task.run()) != nil else { return [] }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()
    var out: [[String: Any]] = []
    for line in String(decoding: data, as: UTF8.self).split(separator: "\n") {
        let trimmed = line.drop { $0 == " " }
        guard let space = trimmed.firstIndex(of: " "), let pid = Int(trimmed[..<space]) else { continue }
        let command = String(trimmed[trimmed.index(after: space)...])
        // The executable path of a variant, not any command line that merely mentions the name.
        if command.contains("DauProbe"), command.contains("/Contents/MacOS/DauProbe") {
            out.append(["pid": pid, "path": command])
        }
    }
    return out
}

func snapshot(event: String?) -> String {
    var object: [String: Any] = [
        "time": iso(Date()),
        "sources": sources(),
        "recordedThirdParty": recordedThirdParty(),
        "updateTime": updateTime(),
        "cacheFiles": cacheFiles(),
        "processes": probeProcesses(),
    ]
    if let event { object["event"] = event }
    let data = (try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])) ?? Data("{}".utf8)
    return String(decoding: data, as: UTF8.self)
}

setvbuf(stdout, nil, _IOLBF, 0)
let arguments = Array(CommandLine.arguments.dropFirst())
if arguments.isEmpty {
    print(snapshot(event: nil))
} else if arguments == ["--watch"] {
    print(snapshot(event: "start"))
    let center = DistributedNotificationCenter.default()
    var tokens: [NSObjectProtocol] = []
    for name in [kTISNotifyEnabledKeyboardInputSourcesChanged, kTISNotifySelectedKeyboardInputSourceChanged] {
        let label = (name as String?) ?? ""
        tokens.append(center.addObserver(forName: Notification.Name(label), object: nil, queue: .main) { _ in
            print(snapshot(event: label))
        })
    }
    withExtendedLifetime(tokens) { RunLoop.main.run() }
} else {
    FileHandle.standardError.write(Data("usage: tis-probe [--watch]\n".utf8))
    exit(2)
}
