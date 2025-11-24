//
//  DeviceIdentificationController.swift
//  DeviceCheckServer
//

import Vapor

struct DeviceIdentificationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let device = routes.grouped("api", "device")
        
        device.post("query", use: queryDevice)
        device.post("update", use: updateDevice)
        device.post("validate", use: validateDevice)
    }
    
    // Query device bits
    func queryDevice(req: Request) async throws -> DeviceQueryResponse {
        let request = try req.content.decode(DeviceQueryRequest.self)
        
        req.logger.info("Querying device with token: \(request.device_token.prefix(20))...")
        
        // Use DeviceCheckService to query Apple's DeviceCheck API
        let service = DeviceCheckService(app: req.application)
        
        do {
            let response = try await service.queryDeviceBits(deviceToken: request.device_token)
            req.logger.info("Successfully queried device bits: bit0=\(response.bit0?.description ?? "nil"), bit1=\(response.bit1?.description ?? "nil")")
            return response
        } catch DeviceCheckError.missingAuthKey, DeviceCheckError.invalidAuthKey {
            req.logger.warning("DeviceCheck authentication key not configured, returning nil mock data")
            // Fallback to nil mock data if auth key is not configured
            return DeviceQueryResponse(
                bit0: nil,
                bit1: nil,
                last_update_time: nil
            )
        } catch {
            req.logger.error("Error querying device bits: \(error)")
            throw error
        }
    }
    
    // Update device bits
    func updateDevice(req: Request) async throws -> DeviceUpdateResponse {
        let request = try req.content.decode(DeviceUpdateRequest.self)
        
        req.logger.info("Updating device with token: \(request.device_token.prefix(20))...")
        req.logger.info("Setting bit0=\(request.bit0), bit1=\(request.bit1)")
        
        // In a real implementation, you would:
        // 1. Send the device token and bit values to Apple's DeviceCheck API
        // 2. Update the two bits
        // 3. Handle any errors from Apple's API
        
        // For this demo, we'll simulate success
        return DeviceUpdateResponse(success: true)
    }
    
    // Validate device
    func validateDevice(req: Request) async throws -> DeviceValidationResponse {
        let request = try req.content.decode(DeviceValidationRequest.self)
        
        req.logger.info("Validating device with token: \(request.device_token.prefix(20))...")
        
        // In a real implementation, you would:
        // 1. Send the device token to Apple's DeviceCheck API
        // 2. Check if the device has been previously flagged
        // 3. Apply your custom validation logic
        
        // For this demo, we'll simulate a valid device
        return DeviceValidationResponse(
            isValid: true,
            message: "Device validation successful (demo mode)"
        )
    }
}

