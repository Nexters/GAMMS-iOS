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
    var parameters: [RequestParameter] { get }
    var header: HTTPHeader { get }
}

extension Endpoint {
    var baseURLString: String {
        return Environment.baseURL
    }
    
    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(
            string: "\(baseURLString)\(path)"
        ) else {
            throw NetworkError.invalidURL
        }
        
        var httpBody: Data?
        
        for parameter in parameters {
            switch parameter {
            case let .query(query):
                components.queryItems = (components.queryItems ?? []) + query.map {
                    URLQueryItem(
                        name: $0.key,
                        value: $0.value
                    )
                }
                
            case let .body(body):
                httpBody = try JSONEncoder().encode(body)
            }
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        
        header.fields.forEach {
            request.setValue(
                $1,
                forHTTPHeaderField: $0
            )
        }
        
        return request
    }
}
