//
//  DeviceCheckService.swift
//  DeviceCheckServer
//

import Foundation
import Vapor
import JWTKit

struct DeviceCheckService {
    let app: Application
    
    // Generate JWT token for Apple DeviceCheck API
    func generateJWT() throws -> String {
        // Validate configuration
        guard Constants.teamID != "YOUR_TEAM_ID" else {
            app.logger.error("❌ Team ID not configured. Please set Constants.teamID")
            throw DeviceCheckError.invalidAuthKey
        }
        
        guard Constants.authKeyID != "YOUR_KEY_ID" else {
            app.logger.error("❌ Auth Key ID not configured. Please set Constants.authKeyID")
            throw DeviceCheckError.invalidAuthKey
        }
        
        // Load the private key
        let keyPath = Constants.authKeyPath
        guard let keyData = try? Data(contentsOf: URL(fileURLWithPath: keyPath)) else {
            app.logger.error("❌ Auth key file not found at: \(keyPath)")
            throw DeviceCheckError.missingAuthKey
        }
        
        guard let keyString = String(data: keyData, encoding: .utf8) else {
            app.logger.error("❌ Unable to read auth key file as UTF-8")
            throw DeviceCheckError.invalidAuthKey
        }
        
        // Parse the PEM format key using ECDSAKey
        let privateKey = try ECDSAKey.private(pem: keyString)
        
        // Create JWT payload
        let now = Date()
        let iat = Int(now.timeIntervalSince1970)
        let exp = iat + 3600 // 1 hour expiration
        
        let payload = DeviceCheckJWTPayload(
            iss: Constants.teamID,
            iat: iat,
            exp: exp,
            aud: "devicecheck.apple.com"
        )
        
        app.logger.info("🔑 Generating JWT with Team ID: \(Constants.teamID), Key ID: \(Constants.authKeyID)")
        app.logger.info("🔑 JWT payload: iss=\(Constants.teamID), iat=\(iat), exp=\(exp), aud=devicecheck.apple.com")
        
        // Sign the JWT
        let signers = JWTSigners()
        let kid = JWKIdentifier(string: Constants.authKeyID)
        signers.use(.es256(key: privateKey), kid: kid)
        
        // Sign the payload
        let token = try signers.sign(payload, kid: kid)
        
        // Verify JWT structure (should be Base64 URL-encoded)
        // JWT format: header.payload.signature (all Base64 URL-encoded)
        let parts = token.split(separator: ".")
        guard parts.count == 3 else {
            app.logger.error("❌ Invalid JWT structure: expected 3 parts, got \(parts.count)")
            throw DeviceCheckError.invalidAuthKey
        }
        
        // Decode and log header to verify it contains alg and kid
        // Base64 URL decoding: replace - with +, _ with /, and add padding
        let headerBase64 = String(parts[0])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = String(repeating: "=", count: (4 - headerBase64.count % 4) % 4)
        if let headerData = Data(base64Encoded: headerBase64 + padding) {
            if let headerJSON = try? JSONSerialization.jsonObject(with: headerData) as? [String: Any] {
                app.logger.info("🔑 JWT Header: \(headerJSON)")
                if let alg = headerJSON["alg"] as? String {
                    app.logger.info("🔑 JWT Algorithm: \(alg) (should be ES256)")
                    if alg != "ES256" {
                        app.logger.error("❌ JWT Algorithm mismatch: expected ES256, got \(alg)")
                    }
                }
                if let kid = headerJSON["kid"] as? String {
                    app.logger.info("🔑 JWT Key ID: \(kid) (should match \(Constants.authKeyID))")
                    if kid != Constants.authKeyID {
                        app.logger.error("❌ JWT Key ID mismatch: expected \(Constants.authKeyID), got \(kid)")
                    }
                } else {
                    app.logger.error("❌ JWT Header missing 'kid' field")
                }
            }
        }
        
        // Log JWT token structure
        app.logger.info("🔑 JWT token structure verified: \(parts[0].count) chars header, \(parts[1].count) chars payload, \(parts[2].count) chars signature")
        app.logger.info("🔑 Generated JWT token (first 100 chars): \(token.prefix(100))...")
        
        return token
    }
    
    // Query device bits from Apple's DeviceCheck API
    func queryDeviceBits(deviceToken: String) async throws -> DeviceQueryResponse {
        // Generate JWT token
        app.logger.info("🔐 Starting JWT generation for DeviceCheck API")
        let jwt = try generateJWT()
        app.logger.info("✅ JWT generated successfully")
        
        // Generate a unique transaction ID (UUID)
        let transactionId = UUID().uuidString
        
        // Generate timestamp in milliseconds since Unix epoch
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        
        // Prepare the request
        let url = "\(Constants.deviceCheckAPIURL)/query_two_bits"
        
        app.logger.info("📤 Calling Apple DeviceCheck API: \(url)")
        app.logger.info("📤 Request body: device_token=\(deviceToken.prefix(20))..., transaction_id=\(transactionId), timestamp=\(timestamp)")
        let envString = Constants.apiEnvironment == .development ? "development" : "production"
        app.logger.info("📤 API Environment: \(envString)")
        
        // Create request body struct
        struct AppleDeviceCheckQueryRequest: Content {
            let device_token: String
            let transaction_id: String
            let timestamp: Int64
        }
        
        let requestBody = AppleDeviceCheckQueryRequest(
            device_token: deviceToken,
            transaction_id: transactionId,
            timestamp: timestamp
        )
        
        // Make the HTTP request
        // Ensure JWT is properly formatted for Authorization header
        let authHeader = "Bearer \(jwt)"
        app.logger.info("🔑 Authorization header length: \(authHeader.count) characters")
        app.logger.info("🔑 Authorization header (first 100 chars): \(authHeader.prefix(100))...")
        
        let response = try await app.client.post(URI(string: url)) { req in
            req.headers.add(name: "Authorization", value: authHeader)
            req.headers.add(name: "Content-Type", value: "application/json")
            try req.content.encode(requestBody)
        }
        
        // Log response status
        app.logger.info("📥 Apple DeviceCheck API response status: \(response.status.code)")
        
        // Check response status
        guard response.status == .ok else {
            let body = response.body?.getString(at: 0, length: response.body?.readableBytes ?? 0) ?? "Unknown error"
            app.logger.error("❌ Apple DeviceCheck API error: \(response.status.code) - \(body)")
            throw DeviceCheckError.apiError("Apple DeviceCheck API returned status \(response.status.code): \(body)")
        }
        
        // Parse the response
        let deviceCheckResponse: AppleDeviceCheckQueryResponse
        do {
            deviceCheckResponse = try response.content.decode(AppleDeviceCheckQueryResponse.self)
            
            // Log response data
            app.logger.info("📥 Apple DeviceCheck API response: bit0=\(deviceCheckResponse.bit0?.description ?? "nil"), bit1=\(deviceCheckResponse.bit1?.description ?? "nil"), last_update_time=\(deviceCheckResponse.last_update_time ?? "nil")")
        } catch {
            // If decoding fails, try to decode as string and log it
            app.logger.warning("❌ Failed to decode DeviceCheck response as expected format")
            
            if let bodyString = response.body?.getString(at: 0, length: response.body?.readableBytes ?? 0) {
                app.logger.warning("📥 Raw response body: \(bodyString)")
            } else {
                app.logger.error("📥 Could not read response body as string")
            }
            
            // Return nil values to the client
            app.logger.warning("⚠️ Returning nil values to client due to decoding error")
            return DeviceQueryResponse(
                bit0: nil,
                bit1: nil,
                last_update_time: nil
            )
        }
        
        // Convert to our response format (preserve nil values)
        let clientResponse = DeviceQueryResponse(
            bit0: deviceCheckResponse.bit0,
            bit1: deviceCheckResponse.bit1,
            last_update_time: deviceCheckResponse.last_update_time
        )
        
        app.logger.info("📤 Returning to client: bit0=\(clientResponse.bit0?.description ?? "nil"), bit1=\(clientResponse.bit1?.description ?? "nil"), last_update_time=\(clientResponse.last_update_time ?? "nil")")
        
        return clientResponse
    }
}

// MARK: - JWT Payload

struct DeviceCheckJWTPayload: JWTPayload {
    let iss: String  // Issuer (Team ID)
    let iat: Int     // Issued at
    let exp: Int     // Expiration
    let aud: String  // Audience
    
    func verify(using signer: JWTSigner) throws {
        // JWTKit will verify the signature and expiration automatically
    }
}

// MARK: - Apple API Response Models

struct AppleDeviceCheckQueryResponse: Content {
    let bit0: Bool?
    let bit1: Bool?
    let last_update_time: String?
}

// MARK: - Errors

enum DeviceCheckError: Error {
    case missingAuthKey
    case invalidAuthKey
    case invalidResponse
    case apiError(String)
    
    var description: String {
        switch self {
        case .missingAuthKey:
            return "DeviceCheck authentication key file not found"
        case .invalidAuthKey:
            return "Invalid DeviceCheck authentication key format"
        case .invalidResponse:
            return "Invalid response from Apple DeviceCheck API"
        case .apiError(let message):
            return message
        }
    }
}

