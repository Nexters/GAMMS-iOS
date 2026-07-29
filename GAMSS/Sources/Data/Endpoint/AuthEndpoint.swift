//
//  AuthEndpoint.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login(LoginRequestDTO)
    
    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
    
    var body: Encodable? {
        switch self {
        case let .login(request):
            return request
        }
    }
}
