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
}

extension Endpoint {
    var baseURLString: String {
        return ""
    }
    
    var headers: [String: String] {
        return [:]
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
