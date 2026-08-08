//
//  Endpoint.swift
//  GAMSS
//
//  Created by 이건준 on 7/19/26.
//

import Foundation

protocol Endpoint {
    var baseURLString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
}

extension Endpoint {
    var baseURLString: String {
        return Environment.baseURL
    }
    
    var headers: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        if let accessToken = TokenStorage.shared.readToken(.accessToken) {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        return headers
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(
            string: "\(baseURLString)\(path)"
        ) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers.forEach {
            request.setValue(
                $1,
                forHTTPHeaderField: $0
            )
        }
        
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
