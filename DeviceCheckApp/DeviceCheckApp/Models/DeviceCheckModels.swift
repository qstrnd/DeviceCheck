//
//  DeviceCheckModels.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import Foundation

// MARK: - Device Identification Models

struct DeviceQueryRequest: Codable {
    let device_token: String
}

struct DeviceQueryResponse: Codable {
    let bit0: Bool?
    let bit1: Bool?
    let last_update_time: String?
}

struct DeviceUpdateRequest: Codable {
    let device_token: String
    let bit0: Bool
    let bit1: Bool
}

struct DeviceUpdateResponse: Codable {
    let success: Bool
}

struct DeviceValidationRequest: Codable {
    let device_token: String
}

struct DeviceValidationResponse: Codable {
    let isValid: Bool
    let message: String
}

// MARK: - App Attest Models

struct AttestationRequest: Codable {
    let keyId: String
    let attestation: String
    let challenge: String
}

struct AttestationResponse: Codable {
    let success: Bool
    let message: String
}

struct AssertionRequest: Codable {
    let keyId: String
    let assertion: String
    let clientData: String
}

struct AssertionResponse: Codable {
    let success: Bool
    let counter: Int?
    let message: String
}

struct ChallengeResponse: Codable {
    let challenge: String
}

