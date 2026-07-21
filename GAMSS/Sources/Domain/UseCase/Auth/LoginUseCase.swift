//
//  LoginUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 7/13/26.
//

import AuthenticationServices

protocol LoginUseCase {
    func login(
        with socialType: SocialType,
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws
}
