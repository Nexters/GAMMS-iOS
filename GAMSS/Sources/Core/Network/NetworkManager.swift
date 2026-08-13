//
//  NetworkManager.swift
//  GAMSS
//
//  Created by 이건준 on 7/19/26.
//

import Foundation

protocol NetworkRequesting {
    func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T
}

final class NetworkManager: NetworkRequesting {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        
        let request = try endpoint.asURLRequest()

        let bodyString = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "-"
        Log.debug("📤 \(endpoint.method.rawValue) \(endpoint.path) body: \(bodyString)")

        let (data, response) = try await session.data(
            for: request
        )

        if let jsonString = String(data: data, encoding: .utf8) {
            Log.debug("📦 \(endpoint.path) response: \(jsonString)")
        }

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= response.statusCode else {
            let apiError = try? decoder.decode(
                APIResponse<EmptyResponseDTO>.self,
                from: data
            ).error
            
            if apiError?.code == "EXPIRED_TOKEN" {
                do {
                    try await TokenStorage.shared.reissueToken()
                } catch {
                    Log.error("Token reissue failed: \(error)")
                }
                
                throw NetworkError.expiredToken
            }
            
            Log.error("""
                    ❌ API Error
                    StatusCode: \(response.statusCode)
                    Code: \(apiError?.code ?? "UNKNOWN")
                    Message: \(apiError?.message ?? "No error message")
                    """)
            
            throw NetworkError.httpError(statusCode: response.statusCode)
        }
        
        do {
            return try decoder.decode(
                T.self,
                from: data
            )
        } catch {
            throw NetworkError.decodingError
        }
    }
}
