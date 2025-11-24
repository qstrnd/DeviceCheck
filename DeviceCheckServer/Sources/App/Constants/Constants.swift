//
//  Constants.swift
//  DeviceCheckServer
//

import Foundation

struct Constants {
    // App configuration
    static let bundleID = "com.yourcompany.DeviceCheck"
    
    // Apple DeviceCheck API Environment
    enum APIEnvironment: Equatable {
        case development
        case production
        
        var baseURL: String {
            switch self {
            case .development:
                return "https://api.development.devicecheck.apple.com/v1"
            case .production:
                return "https://api.devicecheck.apple.com/v1"
            }
        }
    }
    
    // Set to .development or .production
    static let apiEnvironment: APIEnvironment = .development
    
    // Computed property for the API URL
    static var deviceCheckAPIURL: String {
        return apiEnvironment.baseURL
    }
    
    // MARK: - Authentication Configuration
    // 
    // ⚠️ Sensitive authentication data is stored in PrivateConstants.swift
    // Copy PrivateConstants.swift.example to PrivateConstants.swift and fill in your values.
    // PrivateConstants.swift is NOT tracked by git for security reasons.
    //
    // These properties delegate to PrivateConstants for the actual values:
    
    static var authKeyPath: String {
        return PrivateConstants.authKeyPath
    }
    
    static var authKeyID: String {
        return PrivateConstants.authKeyID
    }
    
    static var teamID: String {
        return PrivateConstants.teamID
    }
}

