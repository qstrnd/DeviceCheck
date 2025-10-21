//
//  Constants.swift
//  DeviceCheckServer
//

import Foundation

struct Constants {
    // App configuration
    static let bundleID = "com.yourcompany.DeviceCheck"
    static let teamID = "YOUR_TEAM_ID"
    
    // Apple DeviceCheck API
    static let deviceCheckAPIURL = "https://api.development.devicecheck.apple.com/v1"
    
    // Authentication
    // Place your .p8 key file path here
    static let authKeyPath = "./AuthKey.p8"
    static let authKeyID = "YOUR_KEY_ID"
}

