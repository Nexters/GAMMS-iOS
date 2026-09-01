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

    func autoLogin() async throws
    
    func logout() async throws
}
