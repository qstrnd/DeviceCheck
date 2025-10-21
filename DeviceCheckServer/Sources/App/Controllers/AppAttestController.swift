//
//  AppAttestController.swift
//  DeviceCheckServer
//

import Vapor

struct AppAttestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let attest = routes.grouped("api", "attest")
        
        attest.get("challenge", use: getChallenge)
        attest.post("validate", use: validateAttestation)
        attest.post("assertion", use: validateAssertion)
    }
    
    // Generate a challenge for the client
    func getChallenge(req: Request) async throws -> ChallengeResponse {
        // Generate a random challenge (32 bytes)
        let challengeBytes = [UInt8].random(count: 32)
        let challenge = Data(challengeBytes).base64EncodedString()
        
        // In production, you should store this challenge associated with the session
        req.logger.info("Generated challenge: \(challenge)")
        
        return ChallengeResponse(challenge: challenge)
    }
    
    // Validate attestation from the device
    func validateAttestation(req: Request) async throws -> AttestationResponse {
        let request = try req.content.decode(AttestationRequest.self)
        
        req.logger.info("Validating attestation for keyId: \(request.keyId)")
        
        // In a real implementation, you would:
        // 1. Decode the attestation object
        // 2. Verify the attestation statement
        // 3. Verify the authenticator data
        // 4. Verify the challenge matches what you sent
        // 5. Verify the app ID matches your bundle ID
        // 6. Store the public key for future assertion validation
        
        // For this demo, we'll simulate a successful validation
        guard let attestationData = Data(base64Encoded: request.attestation) else {
            throw Abort(.badRequest, reason: "Invalid attestation data")
        }
        
        guard let challengeData = Data(base64Encoded: request.challenge) else {
            throw Abort(.badRequest, reason: "Invalid challenge data")
        }
        
        req.logger.info("Attestation data size: \(attestationData.count) bytes")
        req.logger.info("Challenge data size: \(challengeData.count) bytes")
        
        // Simulated validation logic
        // In production, implement proper CBOR parsing and cryptographic verification
        
        return AttestationResponse(
            success: true,
            message: "Attestation validated successfully (demo mode)"
        )
    }
    
    // Validate assertion from the device
    func validateAssertion(req: Request) async throws -> AssertionResponse {
        let request = try req.content.decode(AssertionRequest.self)
        
        req.logger.info("Validating assertion for keyId: \(request.keyId)")
        
        // In a real implementation, you would:
        // 1. Retrieve the stored public key for this keyId
        // 2. Decode the assertion object
        // 3. Verify the signature using the public key
        // 4. Verify the authenticator data
        // 5. Check the counter to prevent replay attacks
        // 6. Verify the client data hash
        
        guard let assertionData = Data(base64Encoded: request.assertion) else {
            throw Abort(.badRequest, reason: "Invalid assertion data")
        }
        
        guard let clientData = Data(base64Encoded: request.clientData) else {
            throw Abort(.badRequest, reason: "Invalid client data")
        }
        
        req.logger.info("Assertion data size: \(assertionData.count) bytes")
        req.logger.info("Client data size: \(clientData.count) bytes")
        
        // Simulated validation logic
        // In production, implement proper signature verification and counter checking
        
        return AssertionResponse(
            success: true,
            counter: 1,
            message: "Assertion validated successfully (demo mode)"
        )
    }
}

extension Array where Element == UInt8 {
    static func random(count: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        for i in 0..<count {
            bytes[i] = UInt8.random(in: 0...255)
        }
        return bytes
    }
}

