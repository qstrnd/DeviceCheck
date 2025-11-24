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
    @Published var deviceToken: String?
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
            deviceToken = token.base64EncodedString()
            
            // Send to backend
            let response: DeviceQueryResponse = try await NetworkService.performRequest(
                url: Constants.deviceIdentificationQueryURL,
                method: "POST",
                body: DeviceQueryRequest(device_token: deviceToken!)
            )
            
            // Update bits from response (handle nil values)
            associatedBit0 = response.bit0 != nil ? (response.bit0! ? 1 : 0) : nil
            associatedBit1 = response.bit1 != nil ? (response.bit1! ? 1 : 0) : nil
            
            if response.bit0 == nil && response.bit1 == nil {
                statusMessage = "Query successful (no bits set)"
            } else {
                statusMessage = "Query successful"
            }
            isError = false
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
            deviceToken = token.base64EncodedString()
            
            // Send to backend with selected bit values
            try await NetworkService.performRequest(
                url: Constants.deviceIdentificationUpdateURL,
                method: "POST",
                body: DeviceUpdateRequest(
                    device_token: deviceToken!,
                    bit0: selectedBit0 == 1,
                    bit1: selectedBit1 == 1
                )
            )
            
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
            deviceToken = token.base64EncodedString()
            
            // Send to backend
            let response: DeviceValidationResponse = try await NetworkService.performRequest(
                url: Constants.deviceIdentificationValidateURL,
                method: "POST",
                body: DeviceValidationRequest(device_token: deviceToken!)
            )
            
            statusMessage = response.isValid ? "Device is valid" : "Device is not valid"
            isError = !response.isValid
        } catch {
            statusMessage = "Validation failed: \(error.localizedDescription)"
            isError = true
        }
        
        isValidationRequestInProgress = false
        isLoading = false
    }
    
}

