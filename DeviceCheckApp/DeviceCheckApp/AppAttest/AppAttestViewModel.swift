//
//  AppAttestViewModel.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import Foundation
import Combine
import DeviceCheck

@MainActor
class AppAttestViewModel: ObservableObject {
    @Published var challenge: String?
    @Published var keyId: String?
    @Published var statusMessage: String = ""
    @Published var isError: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFetchChallengeInProgress = false
    @Published var isGenerateKeyIdInProgress = false
    @Published var isAttestKeyInProgress = false
    @Published var isCreateAssertionInProgress = false
    
    private let appAttestService = DCAppAttestService.shared
    
    private var currentChallenge: String?
    
    func fetchChallenge() async {
        guard appAttestService.isSupported else {
            statusMessage = "App Attest is not supported on this device"
            isError = true
            return
        }
        
        isFetchChallengeInProgress = true
        isLoading = true
        statusMessage = ""
        isError = false
        
        do {
            let response = try await sendChallengeRequest()
            if let challengeValue = response["challenge"] as? String {
                challenge = challengeValue
                currentChallenge = challengeValue
                statusMessage = "Challenge fetched successfully"
                isError = false
            } else {
                statusMessage = "Invalid response from server"
                isError = true
            }
        } catch {
            statusMessage = "Failed to fetch challenge: \(error.localizedDescription)"
            isError = true
        }
        
        isFetchChallengeInProgress = false
        isLoading = false
    }
    
    func generateKeyId() async {
        guard appAttestService.isSupported else {
            statusMessage = "App Attest is not supported on this device"
            isError = true
            return
        }
        
        isGenerateKeyIdInProgress = true
        isLoading = true
        statusMessage = ""
        isError = false
        
        do {
            let generatedKeyId = try await appAttestService.generateKey()
            keyId = generatedKeyId
            statusMessage = "Key ID generated successfully"
            isError = false
        } catch {
            statusMessage = "Failed to generate key ID: \(error.localizedDescription)"
            isError = true
        }
        
        isGenerateKeyIdInProgress = false
        isLoading = false
    }
    
    func attestKey() async {
        guard appAttestService.isSupported else {
            statusMessage = "App Attest is not supported on this device"
            isError = true
            return
        }
        
        guard let keyId = keyId else {
            statusMessage = "Please generate a key ID first"
            isError = true
            return
        }
        
        guard let challenge = currentChallenge ?? challenge else {
            statusMessage = "Please fetch a challenge first"
            isError = true
            return
        }
        
        isAttestKeyInProgress = true
        isLoading = true
        statusMessage = ""
        isError = false
        
        do {
            // Convert challenge from base64 string to Data
            guard let challengeData = Data(base64Encoded: challenge) else {
                statusMessage = "Invalid challenge format"
                isError = true
                isAttestKeyInProgress = false
                isLoading = false
                return
            }
            
            // Generate attestation
            let attestationObject = try await appAttestService.attestKey(keyId, clientDataHash: challengeData)
            
            // Send to backend for validation
            let response = try await sendAttestationRequest(
                keyId: keyId,
                attestation: attestationObject,
                challenge: challenge
            )
            
            if let success = response["success"] as? Bool, success {
                statusMessage = response["message"] as? String ?? "Attestation validated successfully"
                isError = false
            } else {
                statusMessage = response["message"] as? String ?? "Attestation validation failed"
                isError = true
            }
        } catch {
            statusMessage = "Failed to attest key: \(error.localizedDescription)"
            isError = true
        }
        
        isAttestKeyInProgress = false
        isLoading = false
    }
    
    func createAssertion() async {
        guard appAttestService.isSupported else {
            statusMessage = "App Attest is not supported on this device"
            isError = true
            return
        }
        
        guard let keyId = keyId else {
            statusMessage = "Please generate a key ID first"
            isError = true
            return
        }
        
        guard let challenge = currentChallenge ?? challenge else {
            statusMessage = "Please fetch a challenge first"
            isError = true
            return
        }
        
        isCreateAssertionInProgress = true
        isLoading = true
        statusMessage = ""
        isError = false
        
        do {
            // Convert challenge from base64 string to Data
            guard let challengeData = Data(base64Encoded: challenge) else {
                statusMessage = "Invalid challenge format"
                isError = true
                isCreateAssertionInProgress = false
                isLoading = false
                return
            }
            
            // Generate assertion
            let assertionObject = try await appAttestService.generateAssertion(keyId, clientDataHash: challengeData)
            
            // Create client data JSON
            let clientDataDict: [String: Any] = [
                "challenge": challenge,
                "type": "webauthn.create"
            ]
            let clientDataJSON = try JSONSerialization.data(withJSONObject: clientDataDict)
            
            // Send to backend for validation
            let response = try await sendAssertionRequest(
                keyId: keyId,
                assertion: assertionObject,
                clientData: clientDataJSON.base64EncodedString()
            )
            
            if let success = response["success"] as? Bool, success {
                let counter = response["counter"] as? Int ?? 0
                let message = response["message"] as? String ?? "Assertion validated successfully"
                statusMessage = "\(message)\nCounter: \(counter)"
                isError = false
            } else {
                statusMessage = response["message"] as? String ?? "Assertion validation failed"
                isError = true
            }
        } catch {
            statusMessage = "Failed to create assertion: \(error.localizedDescription)"
            isError = true
        }
        
        isCreateAssertionInProgress = false
        isLoading = false
    }
    
    // MARK: - Network Requests
    
    private func sendChallengeRequest() async throws -> [String: Any] {
        guard let url = URL(string: Constants.appAttestChallengeURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
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
    
    private func sendAttestationRequest(keyId: String, attestation: Data, challenge: String) async throws -> [String: Any] {
        guard let url = URL(string: Constants.appAttestValidateURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "keyId": keyId,
            "attestation": attestation.base64EncodedString(),
            "challenge": challenge
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
    
    private func sendAssertionRequest(keyId: String, assertion: Data, clientData: String) async throws -> [String: Any] {
        guard let url = URL(string: Constants.appAttestAssertionURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "keyId": keyId,
            "assertion": assertion.base64EncodedString(),
            "clientData": clientData
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

