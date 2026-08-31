//
//  LoginState.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

enum LoginState {
    /// 로그인 안되어 있음
    case notLoggedIn
    /// refreshToken은 있으나 accessToken이 없어, 로그인 API로 세션 복구가 필요함
    case autoLoginPending
    /// 로그인 되어있음
    case loggedIn
    
    /// 현재 로그인 상태 반환
    static var current: Self {
        guard TokenStorage.shared.readToken(.refreshToken) != nil else {
            return .notLoggedIn
        }
        
        guard TokenStorage.shared.readToken(.accessToken) != nil else {
            return .autoLoginPending
        }
        
        return .loggedIn
    }
}
