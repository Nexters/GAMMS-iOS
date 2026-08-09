//
//  HttpHeader.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

enum HTTPHeader {
    case `default`
    case authorization
    case custom([String: String])
    
    private var commonFields: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var fields: [String: String] {
        switch self {
        case .default:
            return commonFields
            
        case .authorization:
            var fields = commonFields
            
            if let accessToken = TokenStorage.shared.readToken(.accessToken) {
                fields["Authorization"] = "Bearer \(accessToken)"
            }
            
            return fields
            
        case let .custom(headers):
            return headers
        }
    }
}
