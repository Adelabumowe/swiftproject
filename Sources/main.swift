import Vapor
import SQLiteKit

func routes(_ app: Application) throws {
    
    // SQL Injection vulnerability
    app.get("user", ":username") { req -> EventLoopFuture<String> in
        let db = req.db as! SQLiteDatabase
        let username = req.parameters.get("username") ?? ""
        let query = "SELECT * FROM users WHERE username = '\(username)'"
        
        return db.raw(SQLQueryString(query)).all().map { rows in
            if let row = rows.first {
                return "Username: \(row.column("username")?.string ?? ""), Email: \(row.column("email")?.string ?? "")"
            } else {
                return "User not found"
            }
        }
    }
    
    // XSS vulnerability
    app.get("greet") { req -> String in
        let name = req.query[String.self, at: "name"] ?? "Guest"
        return "<h1>Hello \(name)</h1>"
    }
    
    // Insecure deserialization vulnerability
    app.post("load") { req -> HTTPStatus in
        struct Input: Content {
            var data: String
        }
        
        let input = try req.content.decode(Input.self)
        print(input.data)
        return .ok
    }
    
    // Hardcoded password vulnerability
    app.post("login") { req -> String in
        struct Credentials: Content {
            var username: String
            var password: String
        }
        
        let credentials = try req.content.decode(Credentials.self)
        if credentials.username == "admin" && credentials.password == "admin123" {
            return "Login successful"
        } else {
            return "Login failed"
        }
    }
}

public func configure(_ app: Application) throws {
    app.databases.use(.sqlite(.memory), as: .sqlite)
    app.migrations.add(CreateUser())
    try app.autoMigrate().wait()
    try routes(app)
}

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("email", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}

import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
