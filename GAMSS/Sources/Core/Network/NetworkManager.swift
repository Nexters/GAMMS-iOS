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
        
        let (data, response) = try await session.data(
            for: request
        )
        
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= response.statusCode else {
            throw NetworkError.httpError(
                statusCode: response.statusCode
            )
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
