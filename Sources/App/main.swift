// Intentionally Vulnerable Swift/Vapor Application
// DO NOT USE IN PRODUCTION - FOR SECURITY TESTING ONLY

import Vapor
import Foundation

// VULNERABILITY: Hardcoded secrets (CWE-798)
struct Constants {
    static let jwtSecret = "super_secret_jwt_key_12345"
    static let adminPassword = "admin123"
    static let dbPassword = "password123"
    static let apiKey = "AKIA_FAKE_SWIFT_KEY_FOR_TESTING_ONLY"
}

struct User: Codable {
    let id: Int
    let username: String
    let password: String
    let email: String
    let role: String
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let email: String
    let role: String?
}

// Global mutable state (not thread-safe - another vulnerability)
var users: [User] = [
    User(id: 1, username: "admin", password: "hashed_password", email: "admin@example.com", role: "admin"),
    User(id: 2, username: "user", password: "hashed_password", email: "user@example.com", role: "user")
]

// Configure routes
func routes(_ app: Application) throws {

    // Home page
    app.get { req -> Response in
        let html = """
        <html>
        <head><title>Vulnerable Swift App</title></head>
        <body>
            <h1>Intentionally Vulnerable Swift/Vapor Application</h1>
            <p>This application contains numerous security vulnerabilities for testing purposes.</p>
            <h2>Available Endpoints:</h2>
            <ul>
                <li>POST /api/login - SQL Injection</li>
                <li>GET /api/exec?cmd=ls - Command Injection</li>
                <li>GET /api/files?filename=test.txt - Path Traversal</li>
                <li>GET /api/search?query=test - XSS</li>
                <li>GET /api/proxy?url=http://example.com - SSRF</li>
                <li>POST /api/register - Mass Assignment</li>
                <li>GET /api/users/:id - IDOR</li>
                <li>DELETE /api/admin/users/:id - Missing Authentication</li>
                <li>GET /api/debug - Sensitive Data Exposure</li>
                <li>GET /api/redirect?url=http://example.com - Open Redirect</li>
            </ul>
        </body>
        </html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }

    // VULNERABILITY: SQL Injection (CWE-89)
    app.post("api", "login") { req -> Response in
        let loginData = try req.content.decode(LoginRequest.self)

        // Vulnerable: String interpolation in SQL query
        let query = "SELECT * FROM users WHERE username = '\(loginData.username)' AND password = '\(loginData.password)'"
        let json = """
        {"query": "\(query)", "vulnerable": true}
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Command Injection (CWE-78)
    app.get("api", "exec") { req -> Response in
        guard let cmd = try? req.query.get(String.self, at: "cmd") else {
            return Response(status: .badRequest)
        }

        // Vulnerable: Direct execution of user input
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", cmd]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        let json = """
        {"success": true, "output": "\(output.replacingOccurrences(of: "\"", with: "\\\""))"}
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Path Traversal (CWE-22)
    app.get("api", "files") { req -> Response in
        guard let filename = try? req.query.get(String.self, at: "filename") else {
            return Response(status: .badRequest)
        }

        // Vulnerable: No sanitization of file path
        let path = "./uploads/\(filename)"

        do {
            let content = try String(contentsOfFile: path)
            let json = """
            {"content": "\(content.replacingOccurrences(of: "\"", with: "\\\""))"}
            """
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
        } catch {
            let json = """
            {"error": "\(error.localizedDescription)"}
            """
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
        }
    }

    // VULNERABILITY: Cross-Site Scripting (XSS) (CWE-79)
    app.get("api", "search") { req -> Response in
        guard let query = try? req.query.get(String.self, at: "query") else {
            return Response(status: .badRequest)
        }

        // Vulnerable: Reflects user input without sanitization
        let html = "<h1>Search Results for: \(query)</h1>"
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }

    // VULNERABILITY: Server-Side Request Forgery (SSRF) (CWE-918)
    app.get("api", "proxy") { req -> Response in
        guard let urlString = try? req.query.get(String.self, at: "url"),
              let url = URL(string: urlString) else {
            return Response(status: .badRequest)
        }

        // Vulnerable: No URL validation
        do {
            let content = try String(contentsOf: url)
            let json = """
            {"data": "\(content.prefix(500).replacingOccurrences(of: "\"", with: "\\\""))"}
            """
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
        } catch {
            let json = """
            {"error": "\(error.localizedDescription)"}
            """
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
        }
    }

    // VULNERABILITY: Mass Assignment (CWE-915)
    app.post("api", "register") { req -> Response in
        let registerData = try req.content.decode(RegisterRequest.self)

        // Vulnerable: Allows setting 'role' field directly
        let newUser = User(
            id: users.count + 1,
            username: registerData.username,
            password: registerData.password,
            email: registerData.email,
            role: registerData.role ?? "user" // Attacker can set role=admin
        )

        users.append(newUser)

        let encoder = JSONEncoder()
        let userData = try encoder.encode(newUser)
        let json = """
        {"success": true, "user": \(String(data: userData, encoding: .utf8)!)}
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Insecure Direct Object Reference (IDOR) (CWE-639)
    app.get("api", "users", ":id") { req -> Response in
        guard let userId = req.parameters.get("id", as: Int.self) else {
            return Response(status: .badRequest)
        }

        // Vulnerable: No authorization check
        let user = users.first { $0.id == userId }

        if let user = user {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            let json = """
            {"user": \(String(data: userData, encoding: .utf8)!)}
            """
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
        } else {
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: "{\"user\": null}"))
        }
    }

    // VULNERABILITY: Missing Authentication (CWE-306)
    app.delete("api", "admin", "users", ":id") { req -> Response in
        guard let userId = req.parameters.get("id", as: Int.self) else {
            return Response(status: .badRequest)
        }

        // Vulnerable: No authentication or authorization required
        users.removeAll { $0.id == userId }

        let json = """
        {"success": true, "deleted": \(userId)}
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Sensitive Data Exposure (CWE-200)
    app.get("api", "debug") { req -> Response in
        let encoder = JSONEncoder()
        let usersData = try encoder.encode(users)
        let json = """
        {
            "jwt_secret": "\(Constants.jwtSecret)",
            "admin_password": "\(Constants.adminPassword)",
            "db_password": "\(Constants.dbPassword)",
            "api_key": "\(Constants.apiKey)",
            "users": \(String(data: usersData, encoding: .utf8)!)
        }
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Open Redirect (CWE-601)
    app.get("api", "redirect") { req -> Response in
        guard let url = try? req.query.get(String.self, at: "url") else {
            return Response(status: .badRequest)
        }

        // Vulnerable: No validation of redirect URL
        return Response(status: .found, headers: ["Location": url])
    }

    // VULNERABILITY: Weak Cryptography (CWE-327)
    app.post("api", "hash") { req -> Response in
        struct HashRequest: Codable {
            let password: String
        }

        let hashData = try req.content.decode(HashRequest.self)

        // Vulnerable: Using weak hashing (simple hash for demonstration)
        let hash = String(hashData.password.hashValue)

        let json = """
        {"hash": "\(hash)", "algorithm": "hashValue (weak)"}
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Insecure Randomness (CWE-330)
    app.get("api", "generate-token") { req -> Response in
        // Vulnerable: Using predictable random
        let token = String(Int.random(in: 0...Int.max))

        let json = """
        {"token": "\(token)", "algorithm": "Int.random (predictable)"}
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Hardcoded Credentials (CWE-798)
    app.post("api", "admin-login") { req -> Response in
        struct AdminLogin: Codable {
            let password: String
        }

        let loginData = try req.content.decode(AdminLogin.self)

        // Vulnerable: Hardcoded admin password
        if loginData.password == Constants.adminPassword {
            let json = """
            {"success": true, "role": "admin"}
            """
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
        } else {
            let json = """
            {"success": false}
            """
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
        }
    }

    // VULNERABILITY: Information Exposure Through Error Messages (CWE-209)
    app.get("api", "database-connect") { req -> Response in
        // Vulnerable: Detailed error messages exposed
        let errorMsg = "Connection failed: Access denied for user 'root'@'localhost' using password '\(Constants.dbPassword)'"

        let json = """
        {"error": "\(errorMsg)", "stackTrace": "Simulated stack trace with sensitive info"}
        """
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: json))
    }

    // VULNERABILITY: Missing Rate Limiting (CWE-770)
    app.post("api", "brute-force-target") { req -> Response in
        struct BruteForce: Codable {
            let password: String
        }

        let bruteData = try req.content.decode(BruteForce.self)

        // Vulnerable: No rate limiting, allows brute force
        if bruteData.password == "correct_password" {
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: "{\"success\": true}"))
        } else {
            return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: "{\"success\": false}"))
        }
    }
}

// Main application entry point
let app = Application()
defer { app.shutdown() }

try routes(app)

print("Starting Vulnerable Swift/Vapor Application...")
print("WARNING: This application is intentionally vulnerable!")
print("Access at: http://localhost:8080")

try app.run()
