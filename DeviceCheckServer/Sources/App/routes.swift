//
//  routes.swift
//  DeviceCheckServer
//

import Vapor

func routes(_ app: Application) throws {
    // Health check endpoint
    app.get { req async in
        return [
            "message": "DeviceCheck Server is running",
            "version": "1.0.0"
        ]
    }
    
    app.get("health") { req async in
        return ["status": "ok"]
    }
    
    // Register controllers
    try app.register(collection: DeviceIdentificationController())
    try app.register(collection: AppAttestController())
}

