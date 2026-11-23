// swift-tools-version: 6.0
// DauInputMethodCore: the input method's helpers that need no InputMethodKit (key routing,
// cursor tracking, the in-place and underline composers, settings → engine options, host app
// lookup), kept apart from the controller so `swift test` covers them without an app bundle.

import PackageDescription

let package = Package(
    name: "DauInputMethodCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "DauInputMethodCore", targets: ["DauInputMethodCore"]),
    ],
    dependencies: [
        .package(path: "../DauEngine"),
        .package(path: "../DauShared"),
    ],
    targets: [
        .target(name: "DauInputMethodCore", dependencies: ["DauEngine", "DauShared"]),
        .testTarget(
            name: "DauInputMethodCoreTests",
            dependencies: ["DauInputMethodCore", "DauEngine", "DauShared"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
