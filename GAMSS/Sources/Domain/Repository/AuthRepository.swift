//
//  AuthRepository.swift
//  GAMSS
//
//  Created by 이건준 on 7/19/26.
//

import AuthenticationServices

protocol AuthRepository {
    func login(
        with socialType: SocialType,
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws

    /// Firebase에 남아 있는 세션으로 ID 토큰을 받아 로그인 API를 다시 호출한다.
    func autoLogin() async throws
    
    func logout() async throws
}
