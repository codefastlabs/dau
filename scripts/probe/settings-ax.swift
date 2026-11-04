// Drives System Settings through Accessibility for the probe rounds, so the user does not
// have to click (docs/research/M5-INSTALL.md section 8).
// Side effects: takes the screen
// Presses buttons and selects rows in System Settings only; never changes anything by
// itself beyond what the given command names. Needs Accessibility for the calling process.
//
// Usage (compile: swiftc -O -o build/probe.noindex/bin/settings-ax scripts/probe/settings-ax.swift):
//   settings-ax dialog [timeout]        wait up to timeout s (default 10) for a dialog with
//                                       "Allow"/"Don't Allow"; print its texts, exit 0, or 3
//   settings-ax press <title> [timeout] press the first button whose title or description is
//                                       <title> in any System Settings window or sheet
//   settings-ax rows                    print the rows of the Input Sources sheet's list
//   settings-ax select <text>           select the row whose text contains <text>
//   settings-ax enabled <title>         print whether that button is enabled
import AppKit
import ApplicationServices

func attr(_ e: AXUIElement, _ a: String) -> AnyObject? {
    var v: AnyObject?
    return AXUIElementCopyAttributeValue(e, a as CFString, &v) == .success ? v : nil
}
func children(_ e: AXUIElement) -> [AXUIElement] { attr(e, kAXChildrenAttribute) as? [AXUIElement] ?? [] }
func role(_ e: AXUIElement) -> String { attr(e, kAXRoleAttribute) as? String ?? "" }
func label(_ e: AXUIElement) -> String {
    [kAXTitleAttribute, kAXDescriptionAttribute].compactMap { attr(e, $0) as? String }.first { !$0.isEmpty } ?? ""
}
func texts(_ e: AXUIElement, _ depth: Int = 0) -> [String] {
    var out: [String] = []
    if role(e) == kAXStaticTextRole, let v = attr(e, kAXValueAttribute) as? String, !v.isEmpty { out.append(v) }
    if depth < 30 { for c in children(e) { out += texts(c, depth + 1) } }
    return out
}
func all(_ e: AXUIElement, _ depth: Int = 0, _ match: (AXUIElement) -> Bool) -> [AXUIElement] {
    var out = match(e) ? [e] : []
    if depth < 30 { for c in children(e) { out += all(c, depth + 1, match) } }
    return out
}
func settingsApp() -> AXUIElement? {
    guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.systempreferences").first else { return nil }
    return AXUIElementCreateApplication(app.processIdentifier)
}
func roots() -> [AXUIElement] {
    guard let app = settingsApp() else { return [] }
    return attr(app, kAXWindowsAttribute) as? [AXUIElement] ?? []
}
func buttons(titled t: String) -> [AXUIElement] {
    roots().flatMap { all($0) { role($0) == kAXButtonRole && label($0) == t } }
}
func poll<T>(_ timeout: Double, _ f: () -> T?) -> T? {
    let end = Date().addingTimeInterval(timeout)
    repeat { if let v = f() { return v }; usleep(200_000) } while Date() < end
    return nil
}
func now() -> String { let f = DateFormatter(); f.dateFormat = "HH:mm:ss.SSS"; return f.string(from: Date()) }

guard AXIsProcessTrusted() else { print("HARNESS no Accessibility permission for this process"); exit(2) }
let args = Array(CommandLine.arguments.dropFirst())
switch args.first {
case "dialog":
    let timeout = Double(args.dropFirst().first ?? "10") ?? 10
    let found: AXUIElement? = poll(timeout) {
        for w in roots() {
            let allow = all(w) { role($0) == kAXButtonRole && label($0) == "Allow" }
            let deny = all(w) { role($0) == kAXButtonRole && label($0) == "Don’t Allow" || label($0) == "Don't Allow" }
            if !allow.isEmpty && !deny.isEmpty { return w }
        }
        return nil
    }
    guard let w = found else { print("\(now()) no Allow dialog within \(timeout) s"); exit(3) }
    let t = texts(w).filter { $0.contains("Allow") || $0.contains("developer") }
    print("\(now()) dialog: \(t.joined(separator: " | "))")
case "press":
    guard args.count >= 2 else { print("press <title>"); exit(64) }
    let timeout = Double(args.count > 2 ? args[2] : "5") ?? 5
    guard let b = poll(timeout, { buttons(titled: args[1]).first }) else { print("\(now()) no button \(args[1])"); exit(3) }
    let r = AXUIElementPerformAction(b, kAXPressAction as CFString)
    print("\(now()) press \(args[1]) -> \(r.rawValue)")
    exit(r == .success ? 0 : 1)
case "rows", "select":
    guard let outline = poll(5, { roots().flatMap { all($0) { role($0) == kAXSheetRole } }.flatMap { all($0) { role($0) == kAXOutlineRole } }.first }) else {
        print("\(now()) no Input Sources sheet"); exit(3)
    }
    let rows = children(outline).filter { role($0) == kAXRowRole }
    let named = rows.map { r in (r, all(r) { !label($0).isEmpty }.map(label).first ?? "") }
    if args.first == "rows" { for (_, n) in named where !n.isEmpty { print(n) }; exit(0) }
    guard args.count >= 2, let hit = named.first(where: { $0.1.contains(args[1]) }) else { print("\(now()) no row \(args.dropFirst().first ?? "")"); exit(3) }
    let r = AXUIElementSetAttributeValue(outline, kAXSelectedRowsAttribute as CFString, [hit.0] as CFArray)
    print("\(now()) select \(hit.1) -> \(r.rawValue)")
    exit(r == .success ? 0 : 1)
case "enabled":
    guard args.count >= 2, let b = buttons(titled: args[1]).first else { print("no button"); exit(3) }
    print((attr(b, kAXEnabledAttribute) as? Bool).map { $0 ? "enabled" : "disabled" } ?? "?")
default:
    print("usage: settings-ax dialog|press|rows|select|enabled …"); exit(64)
}
