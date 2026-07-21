//
//  AuthService.swift
//  GAMSS
//
//  Created by 이건준 on 7/13/26.
//

import AuthenticationServices

import FirebaseAuth

final class DefaultAuthRepository: AuthRepository {
    private let networkManager: NetworkRequesting
    
    init(networkManager: NetworkRequesting) {
        self.networkManager = networkManager
    }
    
    // FIXME: - 로그인 시 올바른 응답값으로 수정 필요
    func login(
        with socialType: SocialType,
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws {
        switch socialType {
        case .apple:
            try await loginWithApple(credential: credential, nonce: nonce)
        }
    }
    
    private func loginWithApple(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws {
        guard let identityToken = credential.identityToken,
              let idToken = String(
                data: identityToken,
                encoding: .utf8
              )
        else { return }
        
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        Log.debug("토큰: \(idToken), 이름: \(credential.fullName), 암호: \(nonce)")
    }
}
