//
//  DeviceCheckModels.swift
//  DeviceCheckServer
//

import Vapor

// MARK: - Device Identification Models

struct DeviceQueryRequest: Content {
    let device_token: String
}

struct DeviceQueryResponse: Content {
    let bit0: Bool
    let bit1: Bool
    let last_update_time: String
}

struct DeviceUpdateRequest: Content {
    let device_token: String
    let bit0: Bool
    let bit1: Bool
}

struct DeviceUpdateResponse: Content {
    let success: Bool
}

struct DeviceValidationRequest: Content {
    let device_token: String
}

struct DeviceValidationResponse: Content {
    let isValid: Bool
    let message: String
}

// MARK: - App Attest Models

struct AttestationRequest: Content {
    let keyId: String
    let attestation: String
    let challenge: String
}

struct AttestationResponse: Content {
    let success: Bool
    let message: String
}

struct AssertionRequest: Content {
    let keyId: String
    let assertion: String
    let clientData: String
}

struct AssertionResponse: Content {
    let success: Bool
    let counter: Int?
    let message: String
}

struct ChallengeResponse: Content {
    let challenge: String
}

