//
//  AuthEndpoint.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login(LoginRequestDTO)
    case logout
    case reissueToken(ReissueTokenRequestDTO)
    
    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
        case .logout:
            return "/api/auth/logout"
        case .reissueToken:
            return "/api/auth/reissue"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .logout:
            return .post
        case .reissueToken:
            return .post
        }
    }
    
    var parameters: [RequestParameter] {
        switch self {
        case .login(let request):
            return [.body(request)]
        case .logout:
            return []
        case .reissueToken(let request):
            return [.body(request)]
        }
    }
    
    var header: HTTPHeader {
        switch self {
        case .login, .reissueToken:
            return .default
        case .logout:
            return .authorization
        }
    }
}
