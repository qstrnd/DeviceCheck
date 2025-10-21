//
//  AppTests.swift
//  DeviceCheckServer
//

import XCTVapor
@testable import App

final class AppTests: XCTestCase {
    func testHealthCheck() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.GET, "/health") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func testRootEndpoint() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.GET, "/") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
}

