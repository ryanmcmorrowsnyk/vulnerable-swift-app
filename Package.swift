// swift-tools-version:5.5
import PackageDescription

// Intentionally vulnerable Swift/Vapor application
// DO NOT USE IN PRODUCTION - FOR SECURITY TESTING ONLY

let package = Package(
    name: "VulnerableSwiftApp",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // Vapor 4 - compatible with modern Swift
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        // SwiftyJSON for JSON processing (vulnerable old version)
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .exact("4.3.0")),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                "SwiftyJSON",
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=minimal"])
            ]
        )
    ]
)
