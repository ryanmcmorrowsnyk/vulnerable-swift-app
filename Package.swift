// swift-tools-version:5.0
import PackageDescription

// 30+ vulnerable Swift Package Manager dependencies from 2019
// Expected 200+ total vulnerabilities including transitive dependencies

let package = Package(
    name: "VulnerableSwiftApp",
    dependencies: [
        // Vapor framework (old vulnerable version from 2019)
        .package(url: "https://github.com/vapor/vapor.git", .exact("3.3.0")),
        .package(url: "https://github.com/vapor/fluent.git", .exact("3.1.3")),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", .exact("3.0.0")),
        .package(url: "https://github.com/vapor/fluent-mysql.git", .exact("3.0.1")),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", .exact("1.0.0")),

        // Authentication/Security (old versions)
        .package(url: "https://github.com/vapor/jwt.git", .exact("3.1.0")),
        .package(url: "https://github.com/vapor/auth.git", .exact("2.0.3")),
        .package(url: "https://github.com/vapor/crypto.git", .exact("3.3.2")),

        // HTTP/Networking (vulnerable versions)
        .package(url: "https://github.com/vapor/http.git", .exact("3.1.10")),
        .package(url: "https://github.com/vapor/websocket.git", .exact("1.1.2")),
        .package(url: "https://github.com/vapor/engine.git", .exact("3.1.0")),

        // Data/JSON processing
        .package(url: "https://github.com/vapor/core.git", .exact("3.7.3")),
        .package(url: "https://github.com/vapor/validation.git", .exact("2.1.1")),

        // Redis/Caching
        .package(url: "https://github.com/vapor/redis.git", .exact("3.4.1")),

        // Additional vulnerable dependencies
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .exact("4.3.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("4.9.0")),
        .package(url: "https://github.com/SwiftGen/SwiftGen.git", .exact("6.1.0")),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", .exact("5.0.1")),
        .package(url: "https://github.com/Carthage/Commandant.git", .exact("0.16.0")),

        // Logging
        .package(url: "https://github.com/vapor/console.git", .exact("3.1.1")),
        .package(url: "https://github.com/vapor/service.git", .exact("1.0.1")),

        // Template engines
        .package(url: "https://github.com/vapor/leaf.git", .exact("3.0.2")),

        // Multipart/File upload
        .package(url: "https://github.com/vapor/multipart.git", .exact("3.0.4")),

        // URL routing
        .package(url: "https://github.com/vapor/routing.git", .exact("3.0.2"))
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "Vapor",
                "FluentSQLite",
                "FluentMySQL",
                "FluentPostgreSQL",
                "JWT",
                "Authentication",
                "Crypto",
                "Redis",
                "SwiftyJSON",
                "Alamofire",
                "Leaf"
            ]
        )
    ]
)
