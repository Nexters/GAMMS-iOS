//
//  MemberEndpoint.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

enum MemberEndpoint: Endpoint {
    case fetchMyProfile
    case updateNickname(UpdateNicknameRequestDTO)
    case deleteAccount
    case fetchMyTokenUsage
    
    var path: String {
        switch self {
        case .fetchMyProfile:
            return "/api/members/me"
        case .updateNickname:
            return "/api/members/me/nickname"
        case .deleteAccount:
            return "/api/members/me"
        case .fetchMyTokenUsage:
            return "/api/members/me/token-usage"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchMyProfile:
            return .get
        case .updateNickname:
            return .patch
        case .deleteAccount:
            return .delete
        case .fetchMyTokenUsage:
            return .get
        }
    }
    
    var parameters: [RequestParameter] {
        switch self {
        case .fetchMyProfile:
            return []
        case .updateNickname(let request):
            return [.body(request)]
        case .deleteAccount:
            return []
        case .fetchMyTokenUsage:
            return []
        }
    }
    
    var header: HTTPHeader { .authorization }
}
