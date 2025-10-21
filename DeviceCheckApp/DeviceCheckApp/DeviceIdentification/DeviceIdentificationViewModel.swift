//
//  DeviceIdentificationViewModel.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import Foundation
import Combine
import DeviceCheck

@globalActor
actor BackgroundActor {
    static var shared = BackgroundActor()
}

@MainActor
class DeviceIdentificationViewModel: ObservableObject {
    @Published var associatedBit0: Int?
    @Published var associatedBit1: Int?
    @Published var statusMessage: String = ""
    @Published var isError: Bool = false
    @Published var isLoading: Bool = false
    @Published var isQueryRequestInProgress = false
    @Published var isUpdateRequestInProgress = false
    @Published var isValidationRequestInProgress = false
    @Published var showBitPicker: Bool = false
    @Published var selectedBit0: Int = 0
    @Published var selectedBit1: Int = 0
    
    @BackgroundActor
    private let deviceCheckService = DCDevice.current
    
    func queryRequest() async {
        guard await deviceCheckService.isSupported else {
            statusMessage = "Device Check is not supported on this device"
            isError = true
            return
        }
        
        isLoading = true
        isQueryRequestInProgress = true
        statusMessage = ""
        isError = false
        
        do {
            // Generate device token
            let token = try await deviceCheckService.generateToken()
            
            // Send to backend
            let response = try await sendQueryRequest(token: token)
            
            // Update bits from response
            if let bit0 = response["bit0"] as? Bool,
               let bit1 = response["bit1"] as? Bool {
                associatedBit0 = bit0 ? 1 : 0
                associatedBit1 = bit1 ? 1 : 0
                statusMessage = "Query successful"
                isError = false
            } else {
                statusMessage = "Invalid response from server"
                isError = true
            }
        } catch {
            statusMessage = "Query failed: \(error.localizedDescription)"
            isError = true
        }
        
        isQueryRequestInProgress = false
        isLoading = false
    }
    
    func showUpdatePicker() {
        showBitPicker = true
    }
    
    func updateRequest() async {
        guard await deviceCheckService.isSupported else {
            statusMessage = "Device Check is not supported on this device"
            isError = true
            return
        }
        
        isUpdateRequestInProgress = true
        isLoading = true
        statusMessage = ""
        isError = false
        
        do {
            // Generate device token
            let token = try await deviceCheckService.generateToken()
            
            // Send to backend with selected bit values
            try await sendUpdateRequest(token: token, bit0: selectedBit0 == 1, bit1: selectedBit1 == 1)
            
            associatedBit0 = selectedBit0
            associatedBit1 = selectedBit1
            statusMessage = "Update successful"
            isError = false
        } catch {
            statusMessage = "Update failed: \(error.localizedDescription)"
            isError = true
        }
        
        isUpdateRequestInProgress = false
        isLoading = false
    }
    
    func deviceValidation() async {
        guard await deviceCheckService.isSupported else {
            statusMessage = "Device Check is not supported on this device"
            isError = true
            return
        }
        
        isValidationRequestInProgress = true
        isLoading = true
        statusMessage = ""
        isError = false
        
        do {
            // Generate device token
            let token = try await deviceCheckService.generateToken()
            
            // Send to backend
            let response = try await sendValidationRequest(token: token)
            
            if let isValid = response["isValid"] as? Bool {
                statusMessage = isValid ? "Device is valid" : "Device is not valid"
                isError = !isValid
            } else {
                statusMessage = "Invalid response from server"
                isError = true
            }
        } catch {
            statusMessage = "Validation failed: \(error.localizedDescription)"
            isError = true
        }
        
        isValidationRequestInProgress = false
        isLoading = false
    }
    
    // MARK: - Network Requests
    
    private func sendQueryRequest(token: Data) async throws -> [String: Any] {
        guard let url = URL(string: Constants.deviceIdentificationQueryURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "device_token": token.base64EncodedString()
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.invalidData
        }
        
        return json
    }
    
    private func sendUpdateRequest(token: Data, bit0: Bool, bit1: Bool) async throws {
        guard let url = URL(string: Constants.deviceIdentificationUpdateURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "device_token": token.base64EncodedString(),
            "bit0": bit0,
            "bit1": bit1
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
    }
    
    private func sendValidationRequest(token: Data) async throws -> [String: Any] {
        guard let url = URL(string: Constants.deviceIdentificationValidateURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "device_token": token.base64EncodedString()
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.invalidData
        }
        
        return json
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        }
    }
}

