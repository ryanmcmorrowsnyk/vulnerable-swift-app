// swift-tools-version:5.0
import PackageDescription
let package = Package(
    name: "VulnerableSwiftApp",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .exact("3.3.0")),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", .exact("3.0.0")),
        .package(url: "https://github.com/vapor/jwt.git", .exact("3.1.0"))
    ],
    targets: [.target(name: "App", dependencies: ["Vapor", "FluentSQLite", "JWT"])]
)
