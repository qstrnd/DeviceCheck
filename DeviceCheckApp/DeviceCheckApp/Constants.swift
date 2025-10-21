//
//  Constants.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import Foundation

struct Constants {
    // Backend configuration
    static let baseURL = "http://localhost:8080"
    
    // Device Identification endpoints
    static let deviceIdentificationQueryURL = "\(baseURL)/api/device/query"
    static let deviceIdentificationUpdateURL = "\(baseURL)/api/device/update"
    static let deviceIdentificationValidateURL = "\(baseURL)/api/device/validate"
    
    // App Attest endpoints
    static let appAttestValidateURL = "\(baseURL)/api/attest/validate"
    static let appAttestAssertionURL = "\(baseURL)/api/attest/assertion"
}

