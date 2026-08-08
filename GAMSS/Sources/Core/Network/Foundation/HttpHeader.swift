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
    
    var fields: [String: String] {
        switch self {
        case .default:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
            
        case .authorization:
            guard let accessToken = TokenStorage.shared.readToken(.accessToken) else {
                return [:]
            }
            
            return [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
        case let .custom(headers):
            return headers
        }
    }
}
