//
//  NetworkService.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        case .encodingError:
            return "Failed to encode request data"
        }
    }
}

struct NetworkService {
    static func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
    }
    
    static func performRequest<TRequest: Encodable, TResponse: Decodable>(
        url: String,
        method: String = "GET",
        body: TRequest? = nil
    ) async throws -> TResponse {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(response)
        
        let decoder = JSONDecoder()
        return try decoder.decode(TResponse.self, from: data)
    }
    
    static func performRequest<TRequest: Encodable>(
        url: String,
        method: String = "POST",
        body: TRequest? = nil
    ) async throws {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(response)
    }
    
    static func performRequest<TResponse: Decodable>(
        url: String,
        method: String = "GET"
    ) async throws -> TResponse {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(response)
        
        let decoder = JSONDecoder()
        return try decoder.decode(TResponse.self, from: data)
    }
}

