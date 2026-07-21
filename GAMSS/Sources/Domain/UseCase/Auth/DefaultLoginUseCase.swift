//
//  DefaultLoginUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 7/19/26.
//

import AuthenticationServices

final class DefaultLoginUseCase: LoginUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func login(
        with socialType: SocialType,
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws {
        try await authRepository.login(
            with: socialType,
            credential: credential,
            nonce: nonce
        )
    }
}
