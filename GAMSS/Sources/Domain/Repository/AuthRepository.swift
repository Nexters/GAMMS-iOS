//
//  AuthRepository.swift
//  GAMSS
//
//  Created by 이건준 on 7/19/26.
//

import AuthenticationServices

// FIXME: - 로그인 시 올바른 응답값으로 수정 필요
protocol AuthRepository {
    func login(
        with socialType: SocialType,
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws 
}
