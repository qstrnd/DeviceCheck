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
            let response: ChallengeResponse = try await NetworkService.performRequest(
                url: Constants.appAttestChallengeURL,
                method: "GET"
            )
            challenge = response.challenge
            currentChallenge = response.challenge
            statusMessage = "Challenge fetched successfully"
            isError = false
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
            let response: AttestationResponse = try await NetworkService.performRequest(
                url: Constants.appAttestValidateURL,
                method: "POST",
                body: AttestationRequest(
                    keyId: keyId,
                    attestation: attestationObject.base64EncodedString(),
                    challenge: challenge
                )
            )
            
            statusMessage = response.message
            isError = !response.success
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
            struct ClientData: Codable {
                let challenge: String
                let type: String
            }
            let clientData = ClientData(challenge: challenge, type: "webauthn.create")
            let clientDataJSON = try JSONEncoder().encode(clientData)
            
            // Send to backend for validation
            let response: AssertionResponse = try await NetworkService.performRequest(
                url: Constants.appAttestAssertionURL,
                method: "POST",
                body: AssertionRequest(
                    keyId: keyId,
                    assertion: assertionObject.base64EncodedString(),
                    clientData: clientDataJSON.base64EncodedString()
                )
            )
            
            let counter = response.counter ?? 0
            statusMessage = "\(response.message)\nCounter: \(counter)"
            isError = !response.success
        } catch {
            statusMessage = "Failed to create assertion: \(error.localizedDescription)"
            isError = true
        }
        
        isCreateAssertionInProgress = false
        isLoading = false
    }
    
}

