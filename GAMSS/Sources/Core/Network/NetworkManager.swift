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
        try await request(endpoint, responseType: responseType, isRetryAfterReissue: false)
    }

    /// `isRetryAfterReissue`가 true면 이미 한 번 토큰을 재발급받고 재시도하는 중이라는 뜻 —
    /// 여기서 또 EXPIRED_TOKEN이 나도 다시 재발급을 시도하지 않는다(무한 루프 방지).
    private func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        responseType: T.Type,
        isRetryAfterReissue: Bool
    ) async throws -> T {

        let urlRequest = try endpoint.asURLRequest()

        let bodyString = urlRequest.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "-"
        Log.debug("📤 \(endpoint.method.rawValue) \(endpoint.path) body: \(bodyString)")

        let (data, response) = try await session.data(
            for: urlRequest
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

            if apiError?.code == "EXPIRED_TOKEN", !isRetryAfterReissue {
                do {
                    try await TokenStorage.shared.reissueToken()
                } catch {
                    Log.error("Token reissue failed: \(error)")
                    throw NetworkError.expiredToken
                }

                // 재발급된 토큰은 HttpHeader가 요청을 다시 만들 때 Keychain에서 새로 읽어오므로,
                // 원래 요청을 그대로 한 번 더 시도하면 된다.
                return try await request(endpoint, responseType: responseType, isRetryAfterReissue: true)
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
