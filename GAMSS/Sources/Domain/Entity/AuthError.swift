//
//  AuthError.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

enum AuthError: Error {

    /// Apple에서 전달받은 Identity Token이 존재하지 않음
    case missingIdentityToken
    
    /// Identity Token 변환 실패
    case invalidIdentityToken
    
    /// Firebase 인증 실패
    case firebaseSignInFailed(Error)
    
    /// 서버 로그인 실패
    case serverLoginFailed(Error)
}
