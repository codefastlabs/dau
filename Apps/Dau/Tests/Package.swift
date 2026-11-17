// swift-tools-version: 6.0
// The host app's unit tests. The app's code is compiled straight from Apps/Dau/Sources
// (symlink "Dau/App"), minus its entry point, with the app's String Catalog (symlink
// "Dau/Localizable.xcstrings"), so the tests run with `swift test`: no Xcode project, no
// signing. No test puts a window on screen.
//
//   swift test --package-path Apps/Dau/Tests   (DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
//   when xcode-select points at the Command Line Tools)

import PackageDescription

let package = Package(
    name: "DauAppTests",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../../../Packages/DauShared"),
    ],
    targets: [
        .target(
            name: "Dau",
            dependencies: [.product(name: "DauShared", package: "DauShared")],
            path: "Dau",
            // SparkleUpdater.swift imports Sparkle, which this package does not fetch; the
            // update logic it backs is tested through `UpdaterBackend` (Updater.swift).
            exclude: ["App/main.swift", "App/DauApp.swift", "App/SparkleUpdater.swift"],
            resources: [.process("Localizable.xcstrings")]
        ),
        .testTarget(
            name: "DauAppTests",
            dependencies: ["Dau", .product(name: "DauShared", package: "DauShared")],
            path: "DauAppTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
